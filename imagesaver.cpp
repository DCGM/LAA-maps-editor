/**************************************************************************
 *   Butaca
 *   Copyright (C) 2011 - 2012 Simon Pena <spena@igalia.com>
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 **************************************************************************/

//#include <QObject>
#include <QPixmap>
#include <QQuickPaintedItem>
#include <QQuickItem>
//#include <QGraphicsObject>
//#include <QPainter>
//#include <QStyleOptionGraphicsItem>
#include <QQuickView>
#include "imagesaver.h"


ImageSaver::ImageSaver(QObject *parent) :
    QObject(parent)
{

}

void ImageSaver::save(QQuickItem* item, const QUrl& url)
{

    QString filename = url.toLocalFile();
    if (item) {
        QQuickWindow *window = item->window();
        if (window == NULL) {
            qDebug() << "ImageSaver::save() window == NULL";
            return;
        }
        QImage grabbed = window->grabWindow();
        QPointF poi = item->mapToScene(QPointF(0,0));
        QRectF rf(poi.x(), poi.y(), item->width(), item->height());
        rf = rf.intersected(QRectF(0,0, grabbed.width(), grabbed.height()));

        QImage result = grabbed.copy(rf.toAlignedRect());

        qDebug() << "saving image into: " << filename;
        result.save(filename);
    } else {
        qDebug() << "ImageSaver::save Item == NULL";
    }


//    QQuickView* view = new QQuickView();
//    view->rootObject()

//    QImage img = currentView_->grabWindow();
//    img.save(path);

//    qDebug() << "ImageSave::save " << item << filename;


}
