## 1.0.0
- feat!: code generation has been aligned with shelf_router
- feat: added support for parsing the body for any json value
- feat!: creating a single Router for all your Routers has been removed in favor of using
@Route.mount(prefix) on a getter of your service. Therefore the annotation for the prefix is no longer necessary.

## 0.1.0

- Initial version.
