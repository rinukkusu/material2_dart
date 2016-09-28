// TODO(kara): Revisit why error messages are not being properly set.

/**
 * Wrapper around Error that sets the error message.
 */
class MdError extends Error {
  final String message;

  MdError(this.message);

  @override
  String toString() => message;
}
