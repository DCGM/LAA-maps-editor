#ifndef GPXJSONCONVERTOR_H
#define GPXJSONCONVERTOR_H
#include <QtCore>

class GpxJsonConvertor : public QObject {
  Q_OBJECT

public:
  GpxJsonConvertor(QObject *parent = 0);

  Q_INVOKABLE QString gpxToJSONString(QUrl filename);
  Q_INVOKABLE QString gpxToJSONString_local(QString filename);
  QString encodeString(const QString &value);
};

#endif // GPXJSONCONVERTOR_H
