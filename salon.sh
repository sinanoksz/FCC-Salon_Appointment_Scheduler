#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
MAIN_MENU() {
    SERVICES=$($PSQL "SELECT service_id, name FROM services")
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
      do
    echo "$SERVICE_ID) $NAME"
  done
}
MAIN_MENU

echo -e "\nPlease pick a service"
read SERVICE_ID_SELECTED
#if service that doesn't exist
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  #send to main menu
  MAIN_MENU "That is not a valid number."
else
  #get service availability
  SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  #if service not on list
  if [[ -z $SERVICE_AVAILABILITY ]]
  then
    #send to main menu
    MAIN_MENU "That is not a valid service."
  else
    #get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME_F=$(echo $CUSTOMER_NAME | sed 's/ //')
    #if customer doesn't exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        #get new customer name
        echo -e "\nWhat's your name?"
        read CUSTOMER_NAME
        #insert new customer
        INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
    #ask appointment time
    echo -e "\nWhen would you want to schedule an appointment?"
    read SERVICE_TIME
    #get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    #insert appointment info
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'") 
    SERVICE_NAME_F=$(echo $SERVICE_NAME | sed 's/ //')
    CUSTOMER_NAME_F=$(echo $CUSTOMER_NAME | sed 's/ //')
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo "I have put you down for a $SERVICE_NAME_F at $SERVICE_TIME, $CUSTOMER_NAME_F."
  fi
fi
