<h1 align="center">
    Car Rental Application
</h1>

<p align="center">
    <img src="https://img.shields.io/badge/swift-5.8-orange.svg" alt="Swift 5.8" />
    <img src="https://img.shields.io/badge/platform-SwiftUI-blue.svg" alt="Swift UI" title="Swift UI" />
</p>

## Installation

Inside the project directory, open a command line and setup the virtual environment and install dependencies:

```
python -m venv env
source env/bin/activate  # Mac/Linux
env\Scripts\activate  # Windows
pip install -r requirements.txt
```

Then make and apply migrations:

```
cd car_rental
python manage.py makemigrations rentals
python manage.py migrate
```

And run the server:

```
python manage.py runserver
```
