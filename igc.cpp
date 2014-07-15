#include "igc.h"

#include <QtCore>
#include <QtAlgorithms>
#include <QDebug>
#include <QFile>



QHash<int,QByteArray> IgcFile::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[typeRole] = "type";
    roles[timeRole] = "time";
    roles[latRole] = "lat";
    roles[lonRole] = "lon";
    roles[altRole] = "alt";
    roles[pressureAltRole] = "pressureAlt";
    roles[validRole] = "valid";
    return roles;
}


IgcFile::IgcFile(QObject* object) : QAbstractListModel(object) {
    //IgcFile::IgcFile(QObject* parent) : QObject(parent) {

}

int IgcFile::rowCount(const QModelIndex &parent) const {
    Q_UNUSED(parent)
    return eventList.count();

}

QVariant IgcFile::data(const QModelIndex &index, int role) const {
    if (index.row() < 0 || index.row() > eventList.count()) {
        return QVariant();
    }

    const IgcEvent* item = eventList[index.row()];

    if (item->getEventType() != IgcEvent::FIX)  {
        switch(role) {
        case typeRole:
            return item->getEventType();
            break;
        case timeRole:
            return item->getTimestamp();
            break;
        default:
            return QVariant();
        }

    }

    Fix const* igcFix = static_cast<Fix const *>(item);

    if (!igcFix->getValid()) {
        if (role == validRole) {
            return QVariant(false);
        } else {
            return QVariant();
        }
    }

    switch (role) {
    case typeRole: return igcFix->getEventType();
    case timeRole: return igcFix->getTimestamp();
    case latRole: return igcFix->getLat();
    case lonRole: return igcFix->getLon();
    case altRole: return igcFix->getAlt();
    case pressureAltRole: return igcFix->getPressureAlt();
    case validRole: return igcFix->getValid();
    }


    return QVariant();
}


/// Open a file with given path and
/// load it.
bool IgcFile::load(const QString& path, QTextCodec* codec) {
    QUrl url(path);

    QFile f(url.path());

    if (!f.open(QIODevice::ReadOnly)) {
        qDebug() << "Couldn't open " << path << ".";
        return false;
    }

    return load(&f, codec);
}

/// Load a file from opened QIODevice.
bool IgcFile::load(QIODevice *dev, QTextCodec* codec) {

    clear();

    file = dev;
    previousRecord = '\0';

    if (codec) {
        activeCodec = codec;
    } else {
        activeCodec = QTextCodec::codecForName("Latin1");
    }

    if (!loadOneRecord()) {
        clear();
        return false;
    }

    if (previousRecord != 'A') {
        qDebug() << "IGC file must start with A record.";
        clear();
        return false;
    }

    while (!file->atEnd()) {
        if (!loadOneRecord()) {
            clear();
            return false;
        }
    }

    qSort(eventList.begin(), eventList.end(), eventLessThan);

    emit eventsChanged();

    return true;
}

/// Delete all loaded data.
void IgcFile::clear() {
    altimeterSetting_ = 0;
    competitionClass_ = QString();
    competitionId_ = QString();
    date_ = QDate();
    manufacturer_ = QString();
    frType_ = QString();
    gliderId_ = QString();
    gps_ = QString();
    gliderType_ = QString();
    pilot_ = QString();

    foreach(IgcEvent const* ev, eventList) {
        delete ev;
    }

    eventList.clear();
    emit eventsChanged();
}

bool IgcFile::loadOneRecord() {
    buffer = file->readLine().trimmed();

    if (buffer.size() == 0 && !file->atEnd()) {
        qDebug() << "Error reading file (" << file->errorString() << ")";
        return false;
    }

    bool ret = parseOneRecord();

    previousRecord = buffer[0];

    return ret;
}

bool IgcFile::parseOneRecord() {
    switch (buffer[0]) {
    case 'B':
        return processRecordB();
    case 'H':
        return processRecordH();
    case 'L':
        return processRecordL();
    default:
        /* We ignore unknown record types. */
        return true;
    }
}

QTime IgcFile::parseTimestamp(QByteArray bytes, bool* ok) {
    if (bytes.size() != 6) {
        *ok = false;
        return QTime();
    }

    int h = bytes.mid(0, 2).toInt(ok);
    if (!*ok) {
        return QTime();
    }

    int m = bytes.mid(2, 2).toInt(ok);
    if (!*ok) {
        return QTime();
    }

    int s = bytes.mid(4, 2).toInt(ok);
    if (!*ok) {
        return QTime();
    }

    return QTime(h, m, s);
}

qreal IgcFile::parseLatLon(QByteArray bytes, bool* ok) {
    if (bytes.size() != 8 && bytes.size() != 9) {
        *ok = false;
        return 0;
    }

    int degreesSize = (bytes.size() == 8) ? 2 : 3;

    int d = bytes.mid(0, degreesSize).toInt(ok);
    if (!*ok) {
        return 0;
    }

    int m = bytes.mid(degreesSize, 2).toInt(ok);
    if (!*ok) {
        return 0;
    }

    int mDecimal = bytes.mid(degreesSize + 2, 3).toInt(ok);
    if (!*ok) {
        return 0;
    }

    qreal ret = d + m / 60.0 + mDecimal / 60000.0;

    char lastChar = bytes[bytes.size() - 1];
    if (lastChar == 'S' || lastChar == 'W') {
        return -ret;
    } else if (lastChar == 'N' || lastChar == 'E') {
        return ret;
    } else {
        *ok = false;
        return 0;
    }
}

qreal IgcFile::parseDecimal(QByteArray bytes, bool* ok) {
    if (bytes.size() < 3) {
        *ok = false;
        return 0;
    }

    int whole = bytes.left(bytes.size() - 2).toInt(ok);
    if (!*ok) {
        return 0;
    }

    int decimal = bytes.right(2).toInt(ok);
    if (!*ok) {
        return 0;
    }

    return whole + decimal / 100.0;
}

QDate IgcFile::parseDate(QByteArray bytes, bool* ok) {
    if (bytes.size() != 6) {
        *ok = false;
        return QDate();
    }

    int y = bytes.mid(4, 2).toInt(ok) + 2000;
    if (!*ok) {
        return QDate();
    }

    int m = bytes.mid(2, 2).toInt(ok);
    if (!*ok) {
        return QDate();
    }

    /// \bug Date field in igc files has only two digits for year.
    ///   Now we're just adding 2000 to it, but maybe there is some
    ///   smarter way around?
    int d = bytes.mid(0, 2).toInt(ok);
    if (!*ok) {
        return QDate();
    }

    return QDate(y, m, d);
}

bool IgcFile::processRecordB() {
    bool ok = true;

    Fix* ret = new Fix;
    eventList.append(ret);

    ret->setEventType(IgcEvent::FIX);

    ret->setTimestamp(parseTimestamp(buffer.mid(1, 6), &ok));
    if (!ok) {
        return false;
    }

    ret->setLat(parseLatLon(buffer.mid(7, 8), &ok));
    if (!ok) {
        return false;
    }

    ret->setLon(parseLatLon(buffer.mid(15, 9), &ok));
    if (!ok) {
        return false;
    }

    if (buffer[24] != 'A' && buffer[24] != 'V') {
        return false;
    }
    ret->setValid((buffer[24] == 'A'));

    ret->setPressureAlt(buffer.mid(25, 5).toInt(&ok));
    if (!ok) {
        return false;
    }

    ret->setAlt(buffer.mid(30, 5).toInt(&ok));
    if (!ok) {
        return false;
    }

    return true;
}

bool IgcFile::processRecordH() {
    // char dataSource = buffer[1];
    QByteArray subtype = buffer.mid(2, 3);
    QByteArray data = buffer.mid(5);

    int colonPos = data.indexOf(':');
    QByteArray value;

    if (colonPos != -1) {
        value = data.mid(colonPos + 1);
    }

    if (subtype == "ATS") {
        bool ok;
        altimeterSetting_ = parseDecimal(value, &ok);
        if (!ok) {
            return false;
        }
    } else if (subtype == "CCL") {
        competitionClass_ = activeCodec->toUnicode(value);
    } else if (subtype == "CID") {
        competitionId_ = activeCodec->toUnicode(value);
    } else if (subtype == "DTE") {
        bool ok;
        date_ = parseDate(data, &ok);
        if (!ok) {
            return false;
        }
    } else if (subtype == "DTM") {
        if (data.left(3) != "100") {
            qDebug() << "We only support WGS84!";
            return false;
        }
    } else if (subtype == "FTY") {
        QList<QByteArray> list = value.split(',');
        if (list.size() == 1) {
            frType_ = activeCodec->toUnicode(list[0]);
        } else {
            manufacturer_ = activeCodec->toUnicode(list[0]);
            frType_ = activeCodec->toUnicode(list[1]);
        }
    } else if (subtype == "GID") {
        gliderId_ = activeCodec->toUnicode(value);
    } else if (subtype == "GPS") {
        gps_ = activeCodec->toUnicode(value.split(',')[0]);
    } else if (subtype == "GTY") {
        gliderType_ = activeCodec->toUnicode(value);
    } else if (subtype == "PLT") {
        pilot_ = activeCodec->toUnicode(value);
    }

    return true;
}

bool IgcFile::processRecordL() {
    if (buffer.mid(1, 4) == "CU::") {
        // This is a special seeyou comment.
        // Causes the rest of line to be read as a new record.
        // Used for saving values from user interface (security record
        // disregard L records)
        buffer = buffer.mid(5);
        return parseOneRecord();
    }

    return true;
}

// see http://bsauts-en.blogspot.cz/2011/09/listmodel-in-c-exposed-to-qml.html
QVariant IgcFile::get(int row)
{
    QModelIndex myidx = index(row);

    QMap<QString, QVariant> itemData;
    QHashIterator<int, QByteArray> hashItr(roleNames());
    while(hashItr.hasNext()){
        hashItr.next();      
        itemData.insert(hashItr.value(),myidx.data(hashItr.key()).toString());

    }
    // Edit:
    // My C++ is sometimes a bit rusty, I was deleting item...
    // DO NOT delete item... otherwise you remove the item from the ListModel
    // delete item;
    return QVariant(itemData);
}


/// Comparator function for sorting events in the list according to timestamp.
bool IgcFile::eventLessThan(const IgcEvent *e1, const IgcEvent *e2) {
    return e1->getTimestamp() < e2->getTimestamp();
}

IgcEvent::IgcEvent(): QObject(0) {

}


