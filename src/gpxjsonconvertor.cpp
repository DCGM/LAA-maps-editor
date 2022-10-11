#include <QtCore>
#include <QtXml>

#include "gpxjsonconvertor.h"

GpxJsonConvertor::GpxJsonConvertor(QObject *parent) : QObject(parent) {}

QString GpxJsonConvertor::gpxToJSONString(QUrl filename) {
  return gpxToJSONString_local(filename.toLocalFile());
}

QString GpxJsonConvertor::gpxToJSONString_local(QString filename) {

  QFile file(filename);

  if (!file.open(QIODevice::ReadOnly)) {
    qDebug() << "cannot open " << filename;
    return "{}";
  }

  QString points;
  QString poly;

  QDomDocument doc("gpx");
  doc.setContent(&file);

  QDomElement root = doc.documentElement();

  QDomNodeList wpts = root.elementsByTagName("wpt");
  for (int i = 0; i < wpts.length(); i++) {
    QDomElement e = wpts.at(i).toElement();

    QString latitude = e.attribute("lat");
    QString longitude = e.attribute("lon");

    QDomNodeList elevation_list = e.elementsByTagName("ele");
    QString elevation = elevation_list.at(0).toElement().text();

    QDomNodeList name_list = e.elementsByTagName("name");
    QString name = name_list.at(0).toElement().text();

    QString str =
        QString("{\"lat\": %1,\"lon\":%2, \"alt\": %3, \"name\":\"%4\"},")
            .arg(latitude)
            .arg(longitude)
            .arg(elevation.toFloat())
            .arg(encodeString(name));
    points = points + str;
  }

  points.remove(points.count() - 1, 1);

  QDomNodeList trks = root.elementsByTagName("trk");

  for (int i = 0; i < trks.length(); i++) {
    QDomElement e = trks.at(i).toElement();
    QDomNodeList names = e.elementsByTagName("name");
    QString name = names.at(0).toElement().text();

    QDomNodeList pts = e.elementsByTagName("trkpt");

    QString color = "FF0000";

    QString str = "";

    for (int j = 0; j < pts.length(); j++) {
      QDomElement je = pts.at(j).toElement();

      QString latitude = je.attribute("lat");
      QString longitude = je.attribute("lon");

      QDomNodeList elevation_list = je.elementsByTagName("ele");
      QString elevation = elevation_list.at(0).toElement().text();

      QDomNodeList time_list = je.elementsByTagName("time");
      QString time = time_list.at(0).toElement().text();

      str = str +
            QString("{\"lat\": %1,\"lon\":%2},").arg(latitude).arg(longitude);
    }
    str.remove(str.count() - 1, 1);
    poly =
        poly + QString("{\"name\": \"%1\", \"color\":\"%2\", \"points\":[%3]},")
                   .arg(encodeString(name))
                   .arg(color)
                   .arg(str);
  }

  poly.remove(poly.count() - 1, 1);

  return QString("{\"points\": [%1], \"poly\": [%2]}").arg(points).arg(poly);
}

QString GpxJsonConvertor::encodeString(const QString &value) {
  QString result = "";
  for (int i = 0; i < value.count(); i++) {
    ushort chr = value.at(i).unicode();
    if (chr < 32) {
      switch (chr) {
      case '\b':
        result.append("\\b");
        break;
      case '\f':
        result.append("\\f");
        break;
      case '\n':
        result.append("\\n");
        break;
      case '\r':
        result.append("\\r");
        break;
      case '\t':
        result.append("\\t");
        break;
      default:
        result.append("\\u");
        result.append(QString::number(chr, 16).rightJustified(4, '0'));
      } // End switch
    } else if (chr > 255) {
      result.append("\\u");
      result.append(QString::number(chr, 16).rightJustified(4, '0'));
    } else {
      result.append(value.at(i));
    }
  }
  //    result.append('"');
  QString displayResult =
      result; // For debug, since "result" often doesn't show
  Q_UNUSED(displayResult);
  return result;
}
