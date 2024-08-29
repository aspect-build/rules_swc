/* A basic interface */
export interface Foo {
  // teh name!
  name: string;
}

// Implicit type
export const A = 1;

// Explicit type
export const AF: Foo = {
  name: "bar",
};
