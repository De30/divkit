import Foundation

import CommonCore

public enum DivVariableNameTag {}
public typealias DivVariableName = Tagged<DivVariableNameTag, String>

public enum DivVariableValue: Equatable {
  case string(String)
  case number(Double)
  case integer(Int)
  case bool(Bool)
  case color(Color)
  case url(URL)
}

extension DivVariableValue: ExpressionResolverValueProvider {
  public func typedValue<T>() -> T? {
    switch self {
    case let .string(value):
      return value as? T
    case let .number(value):
      return value as? T
    case let .integer(value):
      return value as? T
    case let .bool(value):
      return value as? T
    case let .color(value):
      return value as? T
    case let .url(value):
      return value as? T
    }
  }
}

extension DivVariableValue {
  fileprivate var typeName: String {
    switch self {
    case .string:
      return "string"
    case .number:
      return "number"
    case .integer:
      return "integer"
    case .bool:
      return "bool"
    case .color:
      return "color"
    case .url:
      return "url"
    }
  }
}

public typealias DivVariables = [DivVariableName: DivVariableValue]

public final class DivVariablesStorage {
  public struct Variables {
    var global: DivVariables = [:]
    var local: [DivCardID: DivVariables] = [:]

    func makeVariables(for cardId: DivCardID) -> DivVariables {
      global + (local[cardId] ?? [:])
    }
  }

  public struct ChangeEvent {
    public enum Kind: Equatable {
      case local(DivCardID, Set<DivVariableName>)
      case global(Set<DivVariableName>)
    }

    public struct VariablesValues {
      public let old: Variables
      public let new: Variables

      init(
        old: Variables,
        new: Variables
      ) {
        self.old = old
        self.new = new
      }
    }

    public let kind: Kind
    public let variables: VariablesValues

    init(kind: Kind, variables: VariablesValues) {
      self.kind = kind
      self.variables = variables
    }
  }

  private let changeEventsPipe = SignalPipe<ChangeEvent>()
  public var changeEvents: Signal<ChangeEvent> {
    changeEventsPipe.signal
  }

  private var storage = Variables()

  public init() {}

  public func set(
    cardId: DivCardID,
    variables: DivVariables
  ) {
    let oldVariables = storage
    storage.local[cardId] = variables

    let changedVariables = makeChangedVariables(
      old: oldVariables.local[cardId] ?? [:],
      new: variables
    )
    if changedVariables.isEmpty { return }
    update(with: ChangeEvent(
      kind: .local(cardId, changedVariables),
      variables: ChangeEvent.VariablesValues(old: oldVariables, new: storage)
    ))
  }

  public func append(
    variables newVariables: DivVariables,
    for cardId: DivCardID,
    replaceExisting: Bool
  ) {
    let oldVariables = storage.local[cardId] ?? [:]
    let resultVariables = replaceExisting ?
      oldVariables + newVariables :
      newVariables + oldVariables
    set(cardId: cardId, variables: resultVariables)
  }

  public func set(
    variables: DivVariables,
    triggerUpdate: Bool
  ) {
    let oldVariables = storage
    storage.global = variables
    if triggerUpdate {
      let changedVariables = makeChangedVariables(old: oldVariables.global, new: variables)
      if changedVariables.isEmpty { return }
      update(with: ChangeEvent(
        kind: .global(changedVariables),
        variables: ChangeEvent.VariablesValues(old: oldVariables, new: storage)
      ))
    }
  }
  
  public func append(
    variables: DivVariables,
    triggerUpdate: Bool
  ) {
    set(variables: storage.global + variables, triggerUpdate: triggerUpdate)
  }

  public func makeVariables(for cardId: DivCardID) -> DivVariables {
    storage.makeVariables(for: cardId)
  }

  private func update(with event: ChangeEvent) {
    changeEventsPipe.send(event)
  }
}

private func makeChangedVariables(
  old: DivVariables,
  new: DivVariables
) -> Set<DivVariableName> {
  var result = Set<DivVariableName>()
  for (name, value) in old {
    if new[name] != value {
      result.insert(name)
    }
  }
  return result.union(Set(new.keys).subtracting(Set(old.keys)))
}

extension DivVariablesStorage: DivVariableUpdater {
  public func update(
    cardId: DivCardID,
    name: DivVariableName,
    value: String
  ) {
    if let localValue = storage.local[cardId]?[name] {
      let oldVariables = storage
      let isUpdated = storage.local[cardId]?
        .update(name: name, oldValue: localValue, value: value) ?? false
      if isUpdated {
        update(with: ChangeEvent(
          kind: .local(cardId, [name]),
          variables: ChangeEvent.VariablesValues(old: oldVariables, new: storage)
        ))
      }
    } else if let globalValue = storage.global[name] {
      let oldVariables = storage
      let isUpdated = storage.global.update(name: name, oldValue: globalValue, value: value)
      if isUpdated {
        update(with: ChangeEvent(
          kind: .global([name]),
          variables: ChangeEvent.VariablesValues(old: oldVariables, new: storage)
        ))
      }
    } else {
      DivKitLogger.error("Variable is not declared: \(name)")
    }
  }
}

extension Dictionary where Key == DivVariableName, Value == DivVariableValue {
  fileprivate mutating func update(
    name: DivVariableName,
    oldValue: DivVariableValue,
    value: String
  ) -> Bool {
    let newValue: DivVariableValue?
    switch oldValue {
    case .string:
      newValue = .string(value)
    case .number:
      if let newNumber = Double(value) {
        newValue = .number(newNumber)
      } else {
        newValue = nil
      }
    case .integer:
      if let newInteger = Int(value) {
        newValue = .integer(newInteger)
      } else {
        newValue = nil
      }
    case .bool:
      if let newBool = Int(value) {
        switch newBool {
        case 0:
          newValue = .bool(false)
        case 1:
          newValue = .bool(true)
        default:
          newValue = nil
        }
      } else {
        newValue = nil
      }
    case .color:
      if let newColor = Color.color(withHexString: value) {
        newValue = .color(newColor)
      } else {
        newValue = nil
      }
    case .url:
      if let newURL = URL(string: value) {
        newValue = .url(newURL)
      } else {
        newValue = nil
      }
    }

    if newValue == oldValue {
      return false
    }

    if let newValue = newValue {
      self[name] = newValue
      return true
    }

    DivKitLogger.error("Incorrect value for variable \(name): \(value)")

    return false
  }
}

extension Collection where Element == DivVariable {
  public func extractDivVariableValues() -> DivVariables {
    var variables = DivVariables()
    forEach { variable in
      switch variable {
      case let .stringVariable(stringVariable):
        let name = DivVariableName(rawValue: stringVariable.name)
        if variables.keys.contains(name) { return }
        variables[name] = .string(stringVariable.value)
      case let .numberVariable(numberVariable):
        let name = DivVariableName(rawValue: numberVariable.name)
        if variables.keys.contains(name) { return }
        variables[name] = .number(numberVariable.value)
      case let .integerVariable(integerVariable):
        let name = DivVariableName(rawValue: integerVariable.name)
        if variables.keys.contains(name) { return }
        variables[name] = .integer(integerVariable.value)
      case let .booleanVariable(booleanVariable):
        let name = DivVariableName(rawValue: booleanVariable.name)
        if variables.keys.contains(name) { return }
        variables[name] = .bool(booleanVariable.value)
      case let .colorVariable(colorVariable):
        let name = DivVariableName(rawValue: colorVariable.name)
        if variables.keys.contains(name) { return }
        variables[name] = .color(colorVariable.value)
      case let .urlVariable(urlVariable):
        let name = DivVariableName(rawValue: urlVariable.name)
        if variables.keys.contains(name) { return }
        variables[name] = .url(urlVariable.value)
      }
    }
    return variables
  }
}

extension Dictionary where Key == String {
  public func mapToDivVariables(
    valueTransform: (Value) -> DivVariableValue
  ) -> DivVariables {
    var divVariables = DivVariables()
    forEach { element in
      divVariables[DivVariableName(rawValue: element.key)]
        = valueTransform(element.value)
    }
    return divVariables
  }
}

extension Dictionary where Key == String, Value == Color {
  public func mapToDivVariables() -> DivVariables {
    mapToDivVariables(valueTransform: DivVariableValue.color)
  }
}
