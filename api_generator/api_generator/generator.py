from .config import Config, GeneratedLanguage
from .schema.preprocessing import schema_preprocessing
from .schema.modeling import build_objects
from .generators import DocumentationGenerator, Generator, SwiftGenerator


def __build_generator(config: Config) -> Generator:
    lang = config.generation.lang
    generator_dict = {
        GeneratedLanguage.DOCUMENTATION: DocumentationGenerator,
        GeneratedLanguage.SWIFT: SwiftGenerator
    }
    generator = generator_dict.get(lang, None)
    if generator is None:
        raise NotImplementedError
    return generator(config)


def generate_api(config: Config):
    root_directory = schema_preprocessing(config)
    objects = build_objects(root_directory, config.generation)

    generator = __build_generator(config)
    generator.generate(objects)
