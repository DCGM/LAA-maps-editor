#ifndef KMLJSONCONVERTOR_H
#define KMLJSONCONVERTOR_H
#include <QtCore>

class KmlJsonConvertor : public QObject {
    Q_OBJECT

public:
    KmlJsonConvertor(QObject* parent = 0);

    Q_INVOKABLE QString kmlToJSONString(QUrl filename);
    Q_INVOKABLE QString kmlToJSONString_local(QString filename);
};

#endif // KMLJSONCONVERTOR_H
