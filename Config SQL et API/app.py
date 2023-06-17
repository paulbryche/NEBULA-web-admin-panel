from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import IntegrityError
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://myuser:mypassword@localhost/mydatabase'
db = SQLAlchemy(app)

class User(db.Model):
    uid = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)

    def __init__(self, username, password):
        self.username = username
        self.password = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password, password)


class NebulaUser(db.Model):
    user_id = db.Column(db.String(36), primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), nullable=False)
    user_type = db.Column(db.String(100), nullable=False)
    team = db.Column(db.String(100), nullable=False)
    sub_type = db.Column(db.String(100), nullable=False)


class NebulaSubscription(db.Model):
    name = db.Column(db.String(100), primary_key=True)
    price = db.Column(db.Numeric(10, 2), nullable=False)


class NebulaTeamSubscriptions(db.Model):
    name = db.Column(db.String(100), primary_key=True)
    quantity = db.Column(db.Integer, nullable=False)
    price = db.Column(db.Numeric(10, 2), nullable=False)

@app.route('/register', methods=['POST'])
def register():
    username = request.json.get('username')
    password = request.json.get('password')

    if not username or not password:
        return jsonify({'error': 'Missing username or password'}), 400

    try:
        user = User(username=username, password=password)
        db.session.add(user)
        db.session.commit()
        return jsonify({'message': 'User created successfully'}), 201
    except IntegrityError:
        db.session.rollback()
        return jsonify({'error': 'Username already exists'}), 400


@app.route('/login', methods=['POST'])
def login():
    username = request.json.get('username')
    password = request.json.get('password')

    if not username or not password:
        return jsonify({'error': 'Missing username or password'}), 400

    user = User.query.filter_by(username=username).first()

    if user and user.check_password(password):
        return jsonify({'message': 'Login successful'}), 200
    else:
        return jsonify({'error': 'Invalid username or password'}), 401

@app.route('/nebula_users', methods=['GET'])
def get_nebula_users():
    users = NebulaUser.query.all()
    results = []
    for user in users:
        user_data = {
            'UserId': user.user_id,
            'Name': user.name,
            'Email': user.email,
            'UserType': user.user_type,
            'Team': user.team,
            'SubType': user.sub_type
        }
        results.append(user_data)
    return jsonify(results)

@app.route('/nebula_users/without_team', methods=['GET'])
def get_nebula_users_without_team():
    users = NebulaUser.query.filter(NebulaUser.team == "").all()  # Filter users where the team is empty
    results = []
    for user in users:
        user_data = {
            'UserId': user.user_id,
            'Name': user.name,
            'Email': user.email,
            'UserType': user.user_type,
            'Team': user.team,
            'SubType': user.sub_type
        }
        results.append(user_data)
    return jsonify(results)

@app.route('/nebula_users/called_teammembers', methods=['GET'])
def get_teammembers():
    team = request.args.get('Team')
    users = NebulaUser.query.filter(NebulaUser.team == team).all()  # Filter users with the same team
    results = []
    for user in users:
        user_data = {
            'UserId': user.user_id,
            'Name': user.name,
            'Email': user.email,
            'UserType': user.user_type,
            'Team': user.team,
            'SubType': user.sub_type
        }
        results.append(user_data)
    return jsonify(results)


@app.route('/nebula_users', methods=['POST'])
def create_nebula_user():
    user_data = request.get_json()
    new_user = NebulaUser(
        user_id=user_data['UserId'],
        name=user_data['Name'],
        email=user_data['Email'],
        user_type=user_data['UserType'],
        team=user_data['Team'],
        sub_type=user_data['SubType']
    )
    db.session.add(new_user)
    db.session.commit()
    return jsonify({'message': 'NebulaUser created successfully'}), 201


@app.route('/nebula_users/<user_id>', methods=['GET'])
def get_nebula_user(user_id):
    user = NebulaUser.query.get(user_id)
    if not user:
        return jsonify({'message': 'NebulaUser not found'}), 404
    user_data = {
        'UserId': user.user_id,
        'Name': user.name,
        'Email': user.email,
        'UserType': user.user_type,
        'Team': user.team,
        'SubType': user.sub_type
    }
    return jsonify(user_data)


@app.route('/nebula_users', methods=['PUT'])
def update_nebula_user():
    try:
        # Retrieve the user data from the request body
        user_data = request.get_json()

        # Retrieve the existing user record
        user = NebulaUser.query.get(user_data['UserId'])

        # Update the user record with the provided data
        user.name = user_data['Name']
        user.email = user_data['Email']
        user.user_type = user_data['UserType']
        user.team = user_data['Team']
        user.sub_type = user_data['SubType']

        # Commit the changes to the database
        db.session.commit()

        return jsonify({'message': 'NebulaUser updated successfully'})

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/nebula_users/<user_id>', methods=['DELETE'])
def delete_nebula_user(user_id):
    user = NebulaUser.query.get(user_id)
    if not user:
        return jsonify({'message': 'NebulaUser not found'}), 404
    db.session.delete(user)
    db.session.commit()
    return jsonify({'message': 'NebulaUser deleted successfully'})


@app.route('/nebula_subscriptions', methods=['GET'])
def get_nebula_subscriptions():
    subscriptions = NebulaSubscription.query.all()
    results = []
    for subscription in subscriptions:
        subscription_data = {
            'Name': subscription.name,
            'Price': float(subscription.price)
        }
        results.append(subscription_data)
    return jsonify(results)


@app.route('/nebula_subscriptions', methods=['POST'])
def create_nebula_subscription():
    subscription_data = request.get_json()
    new_subscription = NebulaSubscription(
        name=subscription_data['Name'],
        price=subscription_data['Price']
    )
    db.session.add(new_subscription)
    db.session.commit()
    return jsonify({'message': 'NebulaSubscription created successfully'}), 201


@app.route('/nebula_subscriptions/<subscription_name>', methods=['GET'])
def get_nebula_subscription(subscription_name):
    subscription = NebulaSubscription.query.get(subscription_name)
    if not subscription:
        return jsonify({'message': 'NebulaSubscription not found'}), 404
    subscription_data = {
        'Name': subscription.name,
        'Price': float(subscription.price)
    }
    return jsonify(subscription_data)


@app.route('/nebula_subscriptions/<subscription_name>', methods=['PUT'])
def update_nebula_subscription(subscription_name):
    subscription = NebulaSubscription.query.get(subscription_name)
    if not subscription:
        return jsonify({'message': 'NebulaSubscription not found'}), 404
    subscription_data = request.get_json()
    subscription.name = subscription_data['Name']
    subscription.price = subscription_data['Price']
    db.session.commit()
    return jsonify({'message': 'NebulaSubscription updated successfully'})


@app.route('/nebula_subscriptions/<subscription_name>', methods=['DELETE'])
def delete_nebula_subscription(subscription_name):
    subscription = NebulaSubscription.query.get(subscription_name)
    if not subscription:
        return jsonify({'message': 'NebulaSubscription not found'}), 404
    db.session.delete(subscription)
    db.session.commit()
    return jsonify({'message': 'NebulaSubscription deleted successfully'})


@app.route('/nebula_team_subscriptions', methods=['GET'])
def get_nebula_team_subscriptions():
    team_subscriptions = NebulaTeamSubscriptions.query.all()
    results = []
    for team_subscription in team_subscriptions:
        team_subscription_data = {
            'Name': team_subscription.name,
            'Quantity': team_subscription.quantity,
            'Price': float(team_subscription.price)
        }
        results.append(team_subscription_data)
    return jsonify(results)


@app.route('/nebula_team_subscriptions', methods=['POST'])
def create_nebula_team_subscription():
    team_subscription_data = request.get_json()
    new_team_subscription = NebulaTeamSubscriptions(
        name=team_subscription_data['Name'],
        quantity=team_subscription_data['Quantity'],
        price=team_subscription_data['Price']
    )
    db.session.add(new_team_subscription)
    db.session.commit()
    return jsonify({'message': 'NebulaTeamSubscription created successfully'}), 201


@app.route('/nebula_team_subscriptions/<subscription_name>', methods=['GET'])
def get_nebula_team_subscription(subscription_name):
    team_subscription = NebulaTeamSubscriptions.query.get(subscription_name)
    if not team_subscription:
        return jsonify({'message': 'NebulaTeamSubscription not found'}), 404
    team_subscription_data = {
        'Name': team_subscription.name,
        'Quantity': team_subscription.quantity,
        'Price': float(team_subscription.price)
    }
    return jsonify(team_subscription_data)


@app.route('/nebula_team_subscriptions/<subscription_name>', methods=['PUT'])
def update_nebula_team_subscription(subscription_name):
    team_subscription = NebulaTeamSubscriptions.query.get(subscription_name)
    if not team_subscription:
        return jsonify({'message': 'NebulaTeamSubscription not found'}), 404
    team_subscription_data = request.get_json()
    team_subscription.name = team_subscription_data['Name']
    team_subscription.quantity = team_subscription_data['Quantity']
    team_subscription.price = team_subscription_data['Price']
    db.session.commit()
    return jsonify({'message': 'NebulaTeamSubscription updated successfully'})


@app.route('/nebula_team_subscriptions/<subscription_name>', methods=['DELETE'])
def delete_nebula_team_subscription(subscription_name):
    team_subscription = NebulaTeamSubscriptions.query.get(subscription_name)
    if not team_subscription:
        return jsonify({'message': 'NebulaTeamSubscription not found'}), 404
    db.session.delete(team_subscription)
    db.session.commit()
    return jsonify({'message': 'NebulaTeamSubscription deleted successfully'})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)