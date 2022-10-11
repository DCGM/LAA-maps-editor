#include <QtCore>
#include <QtXml>

#include "kmljsonconvertor.h"

KmlJsonConvertor::KmlJsonConvertor(QObject* parent)
    : QObject(parent)
{
}

QString KmlJsonConvertor::kmlToJSONString(QUrl filename)
{
    return kmlToJSONString_local(filename.toLocalFile());
}

QString KmlJsonConvertor::kmlToJSONString_local(QString filename)
{

    QFile file(filename);

    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "cannot open " << filename;
        return "{}";
    }

    QDomDocument doc("mydoc");
    doc.setContent(&file);

    QDomElement root = doc.documentElement();
    QDomNodeList nodes = root.elementsByTagName("Placemark");

    QString points;
    QString poly;

    for (int i = 0; i < nodes.length(); i++) {
        QDomElement placemarkEl = nodes.at(i).toElement();
        QString nodeName = placemarkEl.elementsByTagName("name")
                               .at(0)
                               .childNodes()
                               .at(0)
                               .nodeValue();
        QString coordsString = placemarkEl.elementsByTagName("coordinates")
                                   .at(0)
                                   .childNodes()
                                   .at(0)
                                   .nodeValue();
        QDomNodeList point = placemarkEl.elementsByTagName("Point");
        QDomNodeList linearRing = placemarkEl.elementsByTagName("LinearRing");
        QDomNodeList lineString = placemarkEl.elementsByTagName("LineString");
        QString color = placemarkEl.elementsByTagName("color")
                            .at(0)
                            .childNodes()
                            .at(0)
                            .nodeValue();
        ;
        //        QString color = "FF0000";

        //        qDebug() << nodeName;

        int pos = 0;
        QRegExp rx("([\\d+|\\.]*)\\,([\\d+|\\.]*)\\,?([\\d+|\\.]*)");
        // longitude, latitude, altitude

        if (point.length() > 0) {
            if ((pos = rx.indexIn(coordsString, pos)) != -1) {
                //                qDebug() << rx.cap(1) << rx.cap(2) << rx.cap(3);
                QString str = QString("{\"lat\": %1,\"lon\":%2, \"alt\": %3, \"name\":\"%4\"},")
                                  .arg(rx.cap(2).toFloat())
                                  .arg(rx.cap(1).toFloat())
                                  .arg(rx.cap(3).toFloat())
                                  .arg(nodeName);
                points = points + str;
            }

        } else if (linearRing.length()) {
            QString str = "";
            while ((pos = rx.indexIn(coordsString, pos)) != -1) {
                //                qDebug() << rx.cap(1) << rx.cap(2) << rx.cap(3);
                str = str + QString("{\"lat\": %1,\"lon\":%2},").arg(rx.cap(2).toFloat()).arg(rx.cap(1).toFloat());
                pos += rx.matchedLength();
            }
            str.remove(str.count() - 1, 1);
            poly = poly + QString("{\"name\": \"%1\", \"color\":\"%2\", "
                                  "\"points\":[%3], \"closed\": true},")
                              .arg(nodeName)
                              .arg(color)
                              .arg(str);
        } else if (lineString.length()) {
            QString str = "";
            while ((pos = rx.indexIn(coordsString, pos)) != -1) {
                //                qDebug() << rx.cap(1) << rx.cap(2) << rx.cap(3);
                str = str + QString("{\"lat\": %1,\"lon\":%2},").arg(rx.cap(2).toFloat()).arg(rx.cap(1).toFloat());
                pos += rx.matchedLength();
            }
            str.remove(str.count() - 1, 1);
            poly = poly + QString("{\"name\": \"%1\", \"color\":\"%2\", \"points\":[%3]},").arg(nodeName).arg(color).arg(str);
        } else {
            qDebug() << nodeName << "unknown node";
        }
    }

    points.remove(points.count() - 1, 1);
    poly.remove(poly.count() - 1, 1);

    return QString("{\"points\": [%1], \"poly\": [%2]}").arg(points).arg(poly);
}
