import QtQuick 2.12
import "functions.js" as F
import QtTest 1.12

Item {

    TestCase {
        name: "functions.js tests"

        function test_arrayFromMask() {
            var arr = F.arrayFromMask(0x10000);
            var ref = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true];
            compare(arr, ref);

            var input = 2 | 8;
            compare(F.arrayFromMask(input), [false,true,false,true])
        }

        function test_getFlagsByIndex() {
            //          [0]   [1]   [2]   [3]   [4]
            //          1*0 + 2*1 + 4*0 + 8*1 + 16*0
            var input =       2          |8;
            compare(F.getFlagsByIndex(0, input), false, "flag[0] failed")
            compare(F.getFlagsByIndex(1, input), true,  "flag[1] failed")
            compare(F.getFlagsByIndex(2, input), false, "flag[2] failed")
            compare(F.getFlagsByIndex(3, input), true,  "flag[3] failed")
            compare(F.getFlagsByIndex(4, input), false, "flag[4] failed")
        }

        function test_basename() {
            var refIn = "/home/jmlich/untitled6/tst_quicktest.qml";
            var refOut = "tst_quicktest";
            compare(F.basename(refIn),refOut)
        }

        function test_addSlashes() {
            var refIn  = "qt \"string\" rules"
            var refOut = "qt \\\"string\\\" rules"
            compare(F.addSlashes(refIn), refOut)
        }

        function test_addTimeStrFormat() {
            compare(F.addTimeStrFormat(1000), "00:16:40");
//            compare(F.addTimeStrFormat(-1000), "-00:16:40");
        }
        function test_pad2() {
            compare(F.pad2(4),"04");
            compare(F.pad2(40),"40");
            compare(F.pad2(400),"400");
        }
        function test_getPolyByCid() {

        }
    }
}
