// Pipeline como codigo: Checkout -> Build -> Test, con bloque post.
pipeline {
    agent any

    options {
        skipDefaultCheckout(true)                       // el Checkout se hace en su propia etapa
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '15'))  // guarda solo los ultimos 15 builds
    }

    // Revisa GitHub cada ~2 minutos y lanza el pipeline si hay un push nuevo
    triggers {
        pollSCM('H/2 * * * *')
    }

    environment {
        COMPOSE_PROJECT_NAME = 'ci-productos'   // evita mezclar los contenedores de CI con los locales
        POSTGRES_DB          = 'productos_db'
        API_PORT             = '8090'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Descargando el codigo desde GitHub...'
                checkout scm
                sh 'ls -la'
            }
        }

        stage('Build') {
            steps {
                echo 'Construyendo las imagenes de los dos servicios...'
                // Usuario y contrasena de PostgreSQL vienen de las credenciales de Jenkins
                withCredentials([usernamePassword(credentialsId: 'postgres-credentials',
                                                  usernameVariable: 'POSTGRES_USER',
                                                  passwordVariable: 'POSTGRES_PASSWORD')]) {
                    sh '''
                        docker version
                        docker compose version
                        docker compose config -q
                        docker compose build --pull api-app
                        docker compose pull database
                        docker image ls
                    '''
                }
            }
        }

        stage('Test') {
            steps {
                echo 'Levantando el compose y probando la comunicacion API <-> PostgreSQL...'
                withCredentials([usernamePassword(credentialsId: 'postgres-credentials',
                                                  usernameVariable: 'POSTGRES_USER',
                                                  passwordVariable: 'POSTGRES_PASSWORD')]) {
                    sh 'bash tests/test-comunicacion.sh'
                }
            }
        }
    }

    post {
        always {
            echo 'Limpiando contenedores y volumen de prueba...'
            withCredentials([usernamePassword(credentialsId: 'postgres-credentials',
                                              usernameVariable: 'POSTGRES_USER',
                                              passwordVariable: 'POSTGRES_PASSWORD')]) {
                sh 'docker compose down -v --remove-orphans || true'
            }
        }
        success {
            echo 'BUILD CORRECTO: las imagenes se construyeron y los contenedores se comunican.'
        }
        failure {
            echo 'BUILD FALLIDO: revisa la salida de consola (etapa marcada en rojo).'
        }
    }
}
