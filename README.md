<h1 align="center">
    Car Rental Application
</h1>

<p align="center">
    <img src="https://img.shields.io/badge/swift-5.8-orange.svg" alt="Swift 5.8" />
    <img src="https://img.shields.io/badge/platform-SwiftUI-blue.svg" alt="Swift UI" title="Swift UI" />
</p>

## Installation

Clone the repository or download and unpack the ZIP archive

```
git clone https://github.com/MEClemenkowff/CarRentalApplication.git
```

### Setting up the Python environment

Inside the project directory, open a command line and setup the virtual environment and install dependencies:

```
python -m venv env
source env/bin/activate  # Mac/Linux
env\Scripts\activate  # Windows
pip install -r requirements.txt
```

#### Using MySQL

When using the application with a MySQL database, make sure you can install `mysqlclient` ([https://pypi.org/project/mysqlclient/](https://pypi.org/project/mysqlclient/)), otherwise feel free to comment it out of `requirements.txt`.

### Setting up the database

By default the application works with an auto-generated SQLite database. When using a MySQL or any other Django-compatible database change the `DATABASES` section in `car_rental/car_rental/settings.py`. After your database is set up, make and apply migrations:


```
cd car_rental
python manage.py makemigrations rentals
python manage.py migrate
```

### Run the server

```
python manage.py runserver
```

### Building the Swift application

Open the `CarRentalApplication.xcodeproj` in XCode and build the executable. Then simply run the executable.
