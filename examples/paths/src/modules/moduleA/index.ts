/* 
    Note: your editor/ide might be complaining about this import path as
    it probably does not interpret .swcrc like it normally would a tsconfig.json,
    you should safely be able to ignore this
*/
import { moduleB } from "@modules/moduleB";

export const moduleA = () => {
  console.log("This is module A");
  moduleB();
};
