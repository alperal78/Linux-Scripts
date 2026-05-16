#!/bin/bash

# Configuration - Change this if your container name ever changes
CONTAINER_NAME="ntfy2"

# Colors for clean UI
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

clear
while true; do
    echo -e "${BLUE}==================================================${NC}"
    echo -e "          ${GREEN}ntfy2 User & ACL Management Menu${NC}"
    echo -e "${BLUE}==================================================${NC}"
    echo "1)  List All Users"
    echo "2)  Create a New Admin User"
    echo "3)  Change a User's Role to Admin"
    echo "4)  Delete a User"
    echo "5)  Check Current Access Control Lists (ACLs)"
    echo "6)  Reset a User's Password"
    echo "7)  Create a Limited (Standard) User"
    echo "8)  Deny a User All Access by Default (* -> none)"
    echo "9)  Grant Write-Only Access to a Specific User"
    echo "10) Create a Public Bulletin Board (Open Read & Write)"
    echo "11) Create a Drop Box Topic (Open Write, Private Read)"
    echo "12) Verify Settings (View Permissions)"
    echo "q)  Exit"
    echo -e "${BLUE}==================================================${NC}"
    read -p "Select an option [1-12 or q]: " choice

    case $choice in
        1)
            echo -e "\n${GREEN}--> Fetching user list...${NC}"
            docker exec -it "$CONTAINER_NAME" ntfy user list
            ;;
        2)
            echo -e "\n${GREEN}--> Creating a new Admin User...${NC}"
            read -p "Enter username for the new admin: " admin_name
            if [ -n "$admin_name" ]; then
                docker exec -it "$CONTAINER_NAME" ntfy user add --role=admin "$admin_name"
            else
                echo -e "${RED}Username cannot be empty.${NC}"
            fi
            ;;
        3)
            echo -e "\n${GREEN}--> Elevating User to Admin...${NC}"
            read -p "Enter the username to make admin: " target_user
            if [ -n "$target_user" ]; then
                docker exec -it "$CONTAINER_NAME" ntfy user change-role "$target_user" admin
            else
                echo -e "${RED}Username cannot be empty.${NC}"
            fi
            ;;
        4)
            echo -e "\n${RED}--> Deleting a User...${NC}"
            read -p "Enter the username to delete: " del_user
            if [ -n "$del_user" ]; then
                read -p "Are you sure you want to delete '$del_user'? (y/n): " confirm
                if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                    docker exec -it "$CONTAINER_NAME" ntfy user del "$del_user"
                else
                    echo "Operation canceled."
                fi
            else
                echo -e "${RED}Username cannot be empty.${NC}"
            fi
            ;;
        5)
            echo -e "\n${GREEN}--> Checking current ACL rules...${NC}"
            docker exec -it "$CONTAINER_NAME" ntfy access
            ;;
        6)
            echo -e "\n${GREEN}--> Resetting User Password...${NC}"
            read -p "Enter username to change password: " pass_user
            if [ -n "$pass_user" ]; then
                docker exec -it "$CONTAINER_NAME" ntfy user change-pass "$pass_user"
            else
                echo -e "${RED}Username cannot be empty.${NC}"
            fi
            ;;
        7)
            echo -e "\n${GREEN}--> Creating a Limited Standard User...${NC}"
            read -p "Enter username for the limited user (e.g., automation_poster): " lim_user
            if [ -n "$lim_user" ]; then
                docker exec -it "$CONTAINER_NAME" ntfy user add --role=user "$lim_user"
            else
                echo -e "${RED}Username cannot be empty.${NC}"
            fi
            ;;
        8)
            echo -e "\n${GREEN}--> Restricting Global Access (Deny All by Default)...${NC}"
            read -p "Enter username to isolate (e.g., automation_poster): " restrict_user
            if [ -n "$restrict_user" ]; then
                docker exec -it "$CONTAINER_NAME" ntfy access "$restrict_user" "*" none
                echo -e "${GREEN}Global permissions set to 'none' for $restrict_user.${NC}"
            else
                echo -e "${RED}Username cannot be empty.${NC}"
            fi
            ;;
        9)
            echo -e "\n${GREEN}--> Granting Write-Only Access to User...${NC}"
            read -p "Enter username: " write_user
            read -p "Enter topic name (e.g., server-alerts): " topic_name
            if [ -n "$write_user" ] && [ -n "$topic_name" ]; then
                docker exec -it "$CONTAINER_NAME" ntfy access "$write_user" "$topic_name" write
            else
                echo -e "${RED}Username and Topic Name cannot be empty.${NC}"
            fi
            ;;
        10)
            echo -e "\n${GREEN}--> Creating Public Bulletin Board (Open Read & Write)...${NC}"
            read -p "Enter the topic name to open completely: " pub_topic
            if [ -n "$pub_topic" ]; then
                docker exec -it "$CONTAINER_NAME" ntfy access "*" "$pub_topic" read-write
                echo -e "${GREEN}Topic '$pub_topic' is now open to everyone for reading and writing.${NC}"
            else
                echo -e "${RED}Topic name cannot be empty.${NC}"
            fi
            ;;
        11)
            echo -e "\n${GREEN}--> Creating Drop Box Topic (Open Write, Private Read)...${NC}"
            read -p "Enter the topic name for passwordless log dumps: " drop_topic
            if [ -n "$drop_topic" ]; then
                docker exec -it "$CONTAINER_NAME" ntfy access "*" "$drop_topic" write
                echo -e "${GREEN}Topic '$drop_topic' is now write-only for anonymous guests.${NC}"
            else
                echo -e "${RED}Topic name cannot be empty.${NC}"
            fi
            ;;
        12)
            echo -e "\n${GREEN}--> Verifying active settings...${NC}"
            docker exec -it "$CONTAINER_NAME" ntfy access
            ;;
        q|Q)
            echo -e "\nExiting script. Goodbye!"
            break
            ;;
        *)
            echo -e "\n${RED}Invalid option. Please choose a number between 1 and 12, or q to quit.${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press [Enter] to return to the menu..." clear_key
    clear
done

