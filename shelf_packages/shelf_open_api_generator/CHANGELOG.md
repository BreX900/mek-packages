
## 3.1.0
- feat: added support for class/object documentation

## 3.0.0
- feat: The OpenApi for the entire project are generated directly in the public/* folder
- build: bumped dart sdk version to `^3.8.0`
- build(generator): required analyzer `>=7.4.0 <9.0.0`
- build(generator): switch to analyzer element2 model and build `^3.0.0`
- feat!: routing has been left to the shelf_router and shelf_routing packages so the Routes annotation has been removed
- feat!: now to generate the specs you will need to annotate a class with @OpenApi()
- feat(generator): added support to returns Stream and bytes on routes

## 2.0.0
- feat: The OpenApi for the entire project are generated directly in the public/open_api.yaml file

## 1.1.0
- fix(shelf_open_api_generator): Skip invalid libraries.
- feat: Updated SDK constraint to >=3.0.0 <4.0.0.

## 1.0.0
- feat: First release of shelf_open_api and shelf_open_api_generator
