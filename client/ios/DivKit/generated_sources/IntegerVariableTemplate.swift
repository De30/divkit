// Generated code. Do not modify.

import CommonCore
import Foundation
import Serialization
import TemplatesSupport

public final class IntegerVariableTemplate: TemplateValue, TemplateDeserializable {
  public static let type: String = "integer"
  public let parent: String? // at least 1 char
  public let name: Field<String>? // at least 1 char
  public let value: Field<Int>?

  static let parentValidator: AnyValueValidator<String> =
    makeStringValidator(minLength: 1)

  public convenience init(dictionary: [String: Any], templateToType: TemplateToType) throws {
    do {
      self.init(
        parent: try dictionary.getOptionalField("type", validator: Self.parentValidator),
        name: try dictionary.getOptionalField("name"),
        value: try dictionary.getOptionalField("value")
      )
    } catch let DeserializationError.invalidFieldRepresentation(field: field, representation: representation) {
      throw DeserializationError.invalidFieldRepresentation(field: "integer_variable_template." + field, representation: representation)
    }
  }

  init(
    parent: String?,
    name: Field<String>? = nil,
    value: Field<Int>? = nil
  ) {
    self.parent = parent
    self.name = name
    self.value = value
  }

  private static func resolveOnlyLinks(context: Context, parent: IntegerVariableTemplate?) -> DeserializationResult<IntegerVariable> {
    let nameValue = parent?.name?.resolveValue(context: context, validator: ResolvedValue.nameValidator) ?? .noValue
    let valueValue = parent?.value?.resolveValue(context: context) ?? .noValue
    var errors = mergeErrors(
      nameValue.errorsOrWarnings?.map { .right($0.asError(deserializing: "name", level: .error)) },
      valueValue.errorsOrWarnings?.map { .right($0.asError(deserializing: "value", level: .error)) }
    )
    if case .noValue = nameValue {
      errors.append(.right(FieldError(fieldName: "name", level: .error, error: .requiredFieldIsMissing)))
    }
    if case .noValue = valueValue {
      errors.append(.right(FieldError(fieldName: "value", level: .error, error: .requiredFieldIsMissing)))
    }
    guard
      let nameNonNil = nameValue.value,
      let valueNonNil = valueValue.value
    else {
      return .failure(NonEmptyArray(errors)!)
    }
    let result = IntegerVariable(
      name: nameNonNil,
      value: valueNonNil
    )
    return errors.isEmpty ? .success(result) : .partialSuccess(result, warnings: NonEmptyArray(errors)!)
  }

  public static func resolveValue(context: Context, parent: IntegerVariableTemplate?, useOnlyLinks: Bool) -> DeserializationResult<IntegerVariable> {
    if useOnlyLinks {
      return resolveOnlyLinks(context: context, parent: parent)
    }
    var nameValue: DeserializationResult<String> = parent?.name?.value(validatedBy: ResolvedValue.nameValidator) ?? .noValue
    var valueValue: DeserializationResult<Int> = parent?.value?.value() ?? .noValue
    context.templateData.forEach { key, __dictValue in
      switch key {
      case "name":
        nameValue = deserialize(__dictValue, validator: ResolvedValue.nameValidator).merged(with: nameValue)
      case "value":
        valueValue = deserialize(__dictValue).merged(with: valueValue)
      case parent?.name?.link:
        nameValue = nameValue.merged(with: deserialize(__dictValue, validator: ResolvedValue.nameValidator))
      case parent?.value?.link:
        valueValue = valueValue.merged(with: deserialize(__dictValue))
      default: break
      }
    }
    var errors = mergeErrors(
      nameValue.errorsOrWarnings?.map { Either.right($0.asError(deserializing: "name", level: .error)) },
      valueValue.errorsOrWarnings?.map { Either.right($0.asError(deserializing: "value", level: .error)) }
    )
    if case .noValue = nameValue {
      errors.append(.right(FieldError(fieldName: "name", level: .error, error: .requiredFieldIsMissing)))
    }
    if case .noValue = valueValue {
      errors.append(.right(FieldError(fieldName: "value", level: .error, error: .requiredFieldIsMissing)))
    }
    guard
      let nameNonNil = nameValue.value,
      let valueNonNil = valueValue.value
    else {
      return .failure(NonEmptyArray(errors)!)
    }
    let result = IntegerVariable(
      name: nameNonNil,
      value: valueNonNil
    )
    return errors.isEmpty ? .success(result) : .partialSuccess(result, warnings: NonEmptyArray(errors)!)
  }

  private func mergedWithParent(templates: Templates) throws -> IntegerVariableTemplate {
    guard let parent = parent, parent != Self.type else { return self }
    guard let parentTemplate = templates[parent] as? IntegerVariableTemplate else {
      throw DeserializationError.unknownType(type: parent)
    }
    let mergedParent = try parentTemplate.mergedWithParent(templates: templates)

    return IntegerVariableTemplate(
      parent: nil,
      name: name ?? mergedParent.name,
      value: value ?? mergedParent.value
    )
  }

  public func resolveParent(templates: Templates) throws -> IntegerVariableTemplate {
    return try mergedWithParent(templates: templates)
  }
}
