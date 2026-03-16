#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QtQml>
#include <QQmlContext>

#include "TopicModel.h"
#include "SessionModel.h"
#include "DatabaseManager.h"
#include "FocusController.h"
#include "WindowManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("SyllabusConqueror");
    app.setOrganizationName("DeepFocusStudios");
    app.setApplicationVersion("1.0.0");

    // Enable high-DPI support (Qt 6 default, but explicit for clarity)
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    DatabaseManager db;

    qmlRegisterType<TopicModel>     ("SyllabusConqueror", 1, 0, "TopicModel");
    qmlRegisterType<SessionModel>   ("SyllabusConqueror", 1, 0, "SessionModel");
    qmlRegisterType<FocusController>("SyllabusConqueror", 1, 0, "FocusController");
    qmlRegisterType<WindowManager>  ("SyllabusConqueror", 1, 0, "WindowManager");

    QQmlApplicationEngine engine;

    // Provide DatabaseManager to QML context
    engine.rootContext()->setContextProperty("databaseManager", &db);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("SyllabusConqueror", "Main");

    return app.exec();
}
