// Imported and used as types
import { A, Foo } from "./a";

// Use of imported types
export const B: typeof A = 1;

/** Another use of imported types */
export const BF: Foo = {
  name: "baz",
};
