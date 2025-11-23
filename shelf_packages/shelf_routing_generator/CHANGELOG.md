
## 2.0.1
- build: bumped `analyzer: ^9.0.0`
- build: bumped `build: ^4.0.3`
- build: bumped `source_gen: ^4.1.1`

## 2.0.0
- build: bumped `open_api_specification` to `3.0.0`

## 1.0.1
- build: allow `build: '>=3.0.0 <5.0.0'`
- build: allow `source_gen: '>=3.1.0 <5.0.0'`
- build: bumped `analyzer` dependency to `>=7.4.0 <9.0.0`
- build: bumped `code_builder` dependency to `^4.4.0`

## 1.0.0
- build: bumped dart sdk version to `^3.8.0`
- build(generator): required analyzer `>=7.4.0 <9.0.0`
- build(generator): switch to analyzer element2 model and build `^3.0.0`
- feat!: code generation has been aligned with shelf_router
- feat: added support for parsing the body for any json value
- feat!: creating a single Router for all your Routers has been removed in favor of using
@Route.mount(prefix) on a getter of your service. Therefore the annotation for the prefix is no longer necessary.

## 0.1.0

- Initial version.
