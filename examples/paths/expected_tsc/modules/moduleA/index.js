"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.moduleA = void 0;
var moduleB_1 = require("@modules/moduleB");
var moduleA = function () {
    console.log("This is module A");
    (0, moduleB_1.moduleB)();
};
exports.moduleA = moduleA;
