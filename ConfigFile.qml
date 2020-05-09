// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 2.9
import QtQuick.LocalStorage 2.0

Item {

    property string dbName: "LAA-maps_editor"
    property string dbVersion: "1.0"
    property string dbDisplayName: "LAA-maps_editor"
    property int dbEstimatedSize: 100

    function set(key, value) {
//        console.log(key + " = " + value)

        var db = LocalStorage.openDatabaseSync(dbName, dbVersion, dbDisplayName, dbEstimatedSize);
        try {

            db.transaction(

                        function(tx) {
                            tx.executeSql('CREATE TABLE IF NOT EXISTS Keys(key TEXT, value TEXT)');
                            var rs = tx.executeSql('SELECT * FROM Keys WHERE key==?', [ key ]);

                            if (rs.rows.length === 0){
                                tx.executeSql('INSERT INTO Keys VALUES(?, ?)', [ key, value ]);
                            } else {
                                tx.executeSql('UPDATE Keys SET value=? WHERE key==?', [value, key]);
                            }
                        })
        } catch (err) {
                console.warn("Error set table in database: " + err);
        };
    }

    function get(key, default_value) {

        //console.log(key)

        var db = LocalStorage.openDatabaseSync(dbName, dbVersion, dbDisplayName, dbEstimatedSize);
        var result = "";

        try {
            db.transaction(
                        function(tx) {

                            tx.executeSql('CREATE TABLE IF NOT EXISTS Keys(key TEXT, value TEXT)');
                            var rs = tx.executeSql('SELECT * FROM Keys WHERE key=?', [ key ]);

                            // nefunguje na "" v DB
                            if (rs.rows.length === 1 && rs.rows.item(0).value === null) {
                                result = "";
                            }
                            else {
                                if (rs.rows.length === 1 && rs.rows.item(0).value.length > 0){
                                    result = rs.rows.item(0).value
                                }
                                else {
                                    result = default_value;
                                }
                            }
                        }
                        )
        } catch (err) {
                console.warn("Error get table in database: " + err);
        };
//        console.log(key + " : " + result)
        return result;
    }

}
