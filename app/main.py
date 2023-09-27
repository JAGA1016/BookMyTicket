import psycopg2
import datetime
import pickle
from pathlib import Path
import streamlit as st
import sqlalchemy
#Database Utility Class
from sqlalchemy.engine import create_engine
# Provides executable SQL expression construct
from sqlalchemy.sql import text
sqlalchemy.__version__
from streamlit_extras.switch_page_button import switch_page
from streamlit_extras.stateful_button import button
from streamlit_option_menu import option_menu


import pandas as pd
import streamlit_authenticator as stauth

class PostgresqlDB:
    def __init__(self,user_name,password,host,port,db_name):
        """
        class to implement DDL, DQL and DML commands,
        user_name:- username
        password:- password of the user
        host
        port:- port number
        db_name:- database name
        """
        self.user_name = user_name
        self.password = password
        self.host = host
        self.port = port
        self.db_name = db_name
        self.engine = self.create_db_engine()

    def create_db_engine(self):
        """
        Method to establish a connection to the database, will return an instance of Engine
        which can used to communicate with the database
        """
        try:
            db_uri = f"postgresql+psycopg2://{self.user_name}:{self.password}@{self.host}:{self.port}/{self.db_name}"
            return create_engine(db_uri)
        except Exception as err:
            raise RuntimeError(f'Failed to establish connection -- {err}') from err

    def execute_dql_commands(self,stmnt,values=None):
        """
        DQL - Data Query Language
        SQLAlchemy execute query by default as 

        BEGIN
        ....
        ROLLBACK 

        BEGIN will be added implicitly everytime but if we don't mention commit or rollback explicitly 
        then rollback will be appended at the end.
        We can execute only retrieval query with above transaction block.If we try to insert or update data 
        it will be rolled back.That's why it is necessary to use commit when we are executing 
        Data Manipulation Langiage(DML) or Data Definition Language(DDL) Query.
        """
        print("got in!!!!!!!!")
        try:
            with self.engine.connect() as conn:
                if values is not None:
                    result = conn.execute(text(stmnt),values)
                else:
                    result = conn.execute(text(stmnt))
            return result
        except Exception as err:
            print(f'Failed to execute dql commands -- {err}')
    
    def execute_ddl_and_dml_commands(self,stmnt,values=None):
        """
        Method to execute DDL and DML commands
        here we have followed another approach without using the "with" clause
        """
        connection = self.engine.connect()
        trans = connection.begin()
        try:
            if values is not None:

                result = connection.execute(text(stmnt),values)
            else:
                result = connection.execute(text(stmnt))
            trans.commit()
            connection.close()
            print('Command executed successfully.')
        except Exception as err:
            trans.rollback()
            print(f'Failed to execute ddl and dml commands -- {err}')

def db_credentials(username, password):

    #Defining Db Credentials
    USER_NAME = username
    PASSWORD = password
    PORT = 5432
    # company is the database which we are connecting to
    DATABASE_NAME = 'railway_reservation_system' 
    HOST = 'localhost'
    #Note - Database should be created before executing below operation
    #Initializing SqlAlchemy Postgresql Db Instance
    db = PostgresqlDB(user_name=USER_NAME,
                        password=PASSWORD,
                        host=HOST,port=PORT,
                        db_name=DATABASE_NAME)
    print(username)
    engine = db.engine
    return db, engine
#....................................................................................................................................................

if 'active_page' not in st.session_state:
    st.session_state.active_page = 'user_or_st_master'
    st.session_state.check_user = 0
    st.session_state.check_station_master = 0
    st.session_state.userId=''
st.session_state.update(st.session_state)
def cb_user_home():
    st.session_state.active_page = 'user_home'
def cb_station_master_home():
    st.session_state.active_page = 'station_master_home'
def cb_authentication():
    st.session_state.active_page = 'authentication'
def cb_user_login():
    st.session_state.check_user=1
    st.session_state.check_station_master=0
    st.session_state.active_page = 'authentication'
def cb_station_master_login():
    st.session_state.check_user=0
    st.session_state.check_station_master=1
    st.session_state.active_page = 'authentication'
def cb_user_or_st_master():
    st.session_state.active_page = 'user_or_st_master'
def cb_book_ticket(userId,password,no_passenger):
    st.session_state.active_page = 'book_ticket'
    st.session_state.userId = userId
    st.session_state.password = password
    st.session_state.passenger=no_passenger

def authentication():

    
    # db, engine = db_credentials('postgres','postgres')
    # st.subheader("Login")
    st.sidebar.button("Home page",on_click=cb_user_or_st_master)
    if(st.session_state.check_user):
        st.subheader("Login or Signup")
        listTabs = ["Login", "Sign up"]
        tab1, tab2 = st.tabs([s.center(22, "\u2001") for s in listTabs])
   
        with tab1:

            
    
            username1 = st.text_input("email")
            password1 = st.text_input("Password", type="password")
            # here, there should be a link between frontend and db
         
            # st.write(st.markdown(password_html, unsafe_allow_html=True))
            if(username1 and password1):
                userId = username1
                password = password1
                # db = PostgresqlDB(user_name='postgres',
                #         password='postgres',
                #         host='localhost',port=5432,
                #         db_name='railway_reservation_system ')
                db, engine = db_credentials('anish2','anish2')
                login_user_stmt = "SELECT * FROM users where email_id = '"+ str(userId)+"';"
                res_rows = db.execute_dql_commands(login_user_stmt)
                data= pd.DataFrame(res_rows)
                # st.table(data)
                
                print(data)
                

                if(  userId==data["email_id"][0] and password==data["password"][0]):
                    st.session_state.c_id = data["username"][0]
                    st.session_state.c_email = userId
                    st.session_state.c_pwd = password
                    button = st.button("Login",on_click=cb_user_home)
                    if button:
                        db ,engine = db_credentials(userId,password)
                        st.success(f"Logged in as {userId}")
                        st.button("Home", )
                else:
                    st.error("UserId/Password is incorrect!")
        with tab2:
            st.subheader("Create New Account")
            username =st.text_input("User Name",key="signup_username")
            email =st.text_input("Email")
            password = st.text_input("Password",type ='password',key="signup_password")
            age =st.number_input("Age", min_value=1, max_value=100, value=5, step=1)
            mobile =st.text_input("Mobile")
            if st.button("Sign up"):
                # db, engine = db_credentials('postgres','postgres')
                db, engine = db_credentials('anish2','anish2')
                values= {'username': username, 'email':email ,'password':password,'age': age, 'mobile':mobile}
                result_1 = db.execute_ddl_and_dml_commands("CALL add_user(:username :: VARCHAR(100), :email :: VARCHAR(100),:password :: VARCHAR(100),:age :: INT, :mobile :: VARCHAR(20))",values)
                result_2= db.execute_dql_commands("select * from user_info;")
                st.table(result_2)

                st.write("U are signed in and login to ur acc")


    elif(st.session_state.check_station_master):
        username1 = st.text_input("station_master ID")
        password1 = st.text_input("Password", type="password")
        if(username1 and password1):
            userId2 = username1
            password = password1
            # db ,engine = db_credentials('postgres','postgres')
            db, engine = db_credentials('anish2','anish2')
            login_user_stmt = "SELECT * FROM railway_manager;"
            res_rows = db.execute_dql_commands(login_user_stmt)
            data= pd.DataFrame(res_rows)
            # st.table(data)
            if(data['manager_username'][0]==userId2 and data['password'][0]==password1):
                    st.session_state.c_id = userId2
                    st.session_state.c_pwd = password
                    # db ,engine = db_credentials(userId,password)
                    #     st.success(f"Logged in as {userId}")
                    button = st.button("Login",on_click=cb_station_master_home)
            else:
                st.error("UserId/Password is incorrect!")


def user_home():
    email = st.session_state.c_email
    
    userId = st.session_state.c_id
    password = st.session_state.c_pwd
    db, engine = db_credentials(email,password)
    # st.write("Hello customer!, home sweet home")
    st.sidebar.button("Home",on_click=cb_user_home)
    st.sidebar.button("Logout", on_click=cb_user_or_st_master)
  
    values = {'userId': userId,'password': password}

    # greeting
    st.header(f"Welcome {userId}")
    listTabs = ["Train Schedule", "Book ticket", "cancel Ticket","My Bookings"]



    tab1, tab2, tab3, tab4 = st.tabs([s.center(18, "\u2001") for s in listTabs])
    with tab1:
        src_st = [None,'Bangalore_cantt', 'Palakkad_jn', 'Ernakulam','Chennai_Central', 'Bangalore_cantt', 'Howrah_Jn', 'Lucknow_st']
        dest_st =[None,'Bangalore_cantt', 'Palakkad_jn', 'Ernakulam','Chennai_Central', 'Bangalore_cantt', 'Howrah_Jn', 'Lucknow_st']
        c1, c2, c3 = st.columns(3)
        with c1:
            src = st.selectbox("src_st",src_st)
        with c2:
            dest = st.selectbox("dest_st",dest_st)
        with c3:
            date = st.date_input(f"Date")
            st.write(f"{date}")


        submitButton = st.button("Submit")
        if submitButton:
            values={'src_st':src,'dest_st':dest,'date':date}
            result_2= db.execute_dql_commands("select get_trains(:src_st ::VARCHAR(100),:dest_st ::VARCHAR(100), :date ::DATE)",values)
            data=pd.DataFrame(result_2)
            # data=pd.DataFrame(list(data["get_trains"]),columns=["train_no","train_name","available_AC  ,available_NON-AC","total_seats"])
            l=[]
            for i in range(len(data)):
                train_data= list(data.iloc[i])
                my_list = train_data[0].split(',')
                print(my_list)
                train_no=my_list[0].replace('(',"")
                train_name=my_list[1]
                ac_available=my_list[2].replace('''"(''',"")
                non_ac_available=my_list[3].replace(''')"''',"")
                total_seats=my_list[4].replace(")","")
            
                t=(train_no,train_name,ac_available,non_ac_available,total_seats)
                l.append(t)

    
            data= pd.DataFrame(l,columns=["train_no","train_name","available_AC"  ,"available_NON-AC","total_seats"])
            st.table(data)
        
    with tab2:
        
       
        book_name=[]
        book_age =[]
        book_s_type=[]
        src_book=""
        dest_book=""
        train_name_book=""
        date_book =""
        src_st = [None,'Bangalore_cantt', 'Palakkad_jn', 'Ernakulam','Chennai_Central', 'Bangalore_cantt', 'Howrah_Jn', 'Lucknow_st']
        dest_st =[None,'Bangalore_cantt', 'Palakkad_jn', 'Ernakulam','Chennai_Central', 'Bangalore_cantt', 'Howrah_Jn', 'Lucknow_st']
        c4, c5, c6, c7 = st.columns(4)
        with c4:
            src_book =st.selectbox("src",src_st)
        with c5:
            dest_book = st.selectbox("dest",dest_st)
        with c6:
            train_name_book = st.text_input("train_name",key="train_name_book")
        with c7:
            date_book =  st.date_input(f"date")
        no_passgers = st.number_input("no. of passengers", min_value=0, max_value=6, value=5, step=1)
        for pas in range(no_passgers):
            
            st.write(f"passenger {pas+1}")
            c1, c2, c3= st.columns(3)
            with c1:
                name  = st.text_input("name", key= "name"+str(pas))
                book_name.append(name)
            with c2:
                age = st.number_input("age",key=4+pas, min_value=1, max_value=100, value=5, step=1)
                book_age.append(age)
            with c3:
                seat_type =st.selectbox("Seat_type",["AC","NON-AC"],key = "seat_type"+str(pas))
                book_s_type.append(seat_type)
                # st.write(f"{seat_type}")
        values={'train':train_name_book,'src_st':src_book,'dest_st':dest_book}
        if (train_name_book and src_book and dest_book):
            result_2= db.execute_dql_commands("select get_fare(:train ::VARCHAR(100),:src_st ::VARCHAR(100),:dest_st ::VARCHAR(100))",values)
            cost=pd.DataFrame(result_2)
            fare=cost['get_fare'][0]
            st.subheader(f"Total amount :{fare * no_passgers}")
        
       
        # st.write(f"{book_ticket}")
        submit = st.button("Book")
        if submit and no_passgers>0:
            values ={'book_name':book_name,'book_age':book_age,'book_s_type':book_s_type,'src_book':src_book,'dest_book':dest_book,'train_name_book':train_name_book ,'date_book':date_book}
            result_1 = db.execute_ddl_and_dml_commands("CALL book_tickets(:book_name ::VARCHAR(100)[], :book_age ::INT[], :book_s_type ::SEAT_TYPE[], :src_book ::VARCHAR(100), :dest_book ::VARCHAR(100), :train_name_book ::VARCHAR(100), :date_book ::DATE)",values)

            # result_2=db.execute_dql_commands("select * from booking_details;")
            # data=pd.DataFrame(result_2)  
            # st.table(data) 
            # data=pd.DataFrame(result_2)   
            # data
            st.success("booking successful.. click on view details for the ticket")
            st.button("view details",on_click=cb_book_ticket, args=[email,password,no_passgers])
        else :
            st.error(f"Please enter atleast one passenger details")

    with tab3:
        st.subheader("Cancel your booking")
        pnr = st.number_input("Enter PNR no.", min_value=1000, max_value=10000, value=1000, step=1)
        check = db.execute_dql_commands("select email_id from ticket natural join users where pnr ='"+str(pnr)+"' and email_id ='"+str(email)+"';")
        data  = pd.DataFrame(check)
        # st.table(data)
        if len(data) :
            submit = st.button("cancel Ticket")
            if submit:
                values= {'pnr': pnr}
                result_1 = db.execute_ddl_and_dml_commands("CALL cancel_booking(:pnr :: INT )",values)
                st.write("canceled")
                result_2=db.execute_dql_commands("select * from booking_details where pnr =  '"+str(pnr)+"'")
                data=pd.DataFrame(result_2)  
                st.table(data) 
    with tab4:
    
        result_2=db.execute_dql_commands("select * from booking_details where user_email = '"+ str(email) +"'")
        data=pd.DataFrame(result_2)  
        st.table(data) 

    
def station_master_home():
    username = st.session_state.c_id
    password = st.session_state.c_pwd
    db,engine = db_credentials(username,password)
    st.sidebar.button("Logout", on_click=cb_user_or_st_master)
    st.header("hello Manager")
    listTabs = [ "Add Station", "Add Schedule"]
    tab2, tab3 = st.tabs([s.center(30, "\u2001") for s in listTabs])  
    with tab2:
        c1,c2,c3 = st.columns(3)
        with c1:
            st_name = st.text_input("Station name",key="add station_name")
        with c2:
            city = st.text_input("City")
        with c3:
            state = st.text_input("State")
        submit = st.button("Add station")
        if submit: 
            values ={'st_name': st_name, 'city':city , 'state':state}
            print(values)
            result_1 = db.execute_ddl_and_dml_commands("CALL add_railway_station(:st_name :: VARCHAR(100), :city ::VARCHAR(100), :state ::VARCHAR(100))",values)
            result_2= db.execute_dql_commands("select * from railway_station;")
            data=pd.DataFrame(result_2)
            st.table(data)
            
        
    with tab3:
        seat_type=[]
        fare_list=[]
        arr_time_list=[]
        dept_time_list=[]
        train_name=st.text_input("Train name")
        in_stations=st.multiselect("select stations",['Secunderabad_Jn','Chennai_Central','Bangalore_cantt','Vijayawada_jn','Palakkad_jn','Ernakulam','Ahmedabad_Jn','Guwahati_Jn','Howrah_Jn','Kanpur_Central','Hazrat_Nizamuddin','Lucknow_Jn','Mumbai_central','Jaipur_Jn'])
        # print(stations)
        week_days = st.multiselect("select days",['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'])
        # print(days)
        c1,c2  =st.columns(2)
        with c1:
            ac_seat = st.number_input("Ac seats",min_value=1, max_value=100, value=1, step=1)
            for i in range(ac_seat):
                seat_type.append('AC')
        with c2:
            nonac_seat = st.number_input("NON-Ac seats",min_value=1, max_value=100, value=1, step=1)
            for i in range(nonac_seat):
                seat_type.append('NON-AC')
        seats=[]
        for i in range(len(seat_type)):
            seats.append(i+1)
        for i in range(len(in_stations)):
            st.subheader(in_stations[i]) 
            st.write("Arrival details")
            c1,c2=st.columns(2)
            with c1:
                    day_dur=st.number_input("Day",key="day"+str(i),min_value=1, max_value=100, value=2, step=1)
            with c2:
                    arr_time=st.time_input("arrival time",key="arr_time"+str(i))
            st.write("Depature details")
            arr_time_list.append((day_dur,arr_time.strftime('%H:%M:%S')))
            c1,c2=st.columns(2)
            with c1:
                    day_dep=st.number_input("Day",key="day_dep"+str(i),min_value=1, max_value=100, value=2, step=1)
            with c2:
                    dept_time=st.time_input("Depature time",key="dep_time"+str(i))
            dept_time_list.append((day_dep,dept_time.strftime('%H:%M:%S')))
            fare = st.number_input("Fare",key="Fare"+str(i),min_value=1, max_value=100, value=2, step=1)
            fare_list.append(fare)
        # print(arr_time_list)
        # print(dept_time_list)
        # print(fare_list)
        if(st.button("Add")):
            values={'train_name':train_name,'seats':seats,'seat_type':seat_type,'week_days':week_days ,'in_stations':in_stations,'arr_time_list':arr_time_list,'dept_time_list':dept_time_list,'in_fares':fare_list}
            result_1 = db.execute_ddl_and_dml_commands("CALL add_schedule(:train_name :: VARCHAR(100), :seats ::INT[], :seat_type ::SEAT_TYPE[], :week_days ::DAYS[],:in_stations ::VARCHAR(100)[],:arr_time_list ::DAY_TIME_Format[],:dept_time_list ::DAY_TIME_Format[],:in_fares ::NUMERIC(7, 2)[])",values)
            result_2 =db.execute_dql_commands("select * from train;")
            data=pd.DataFrame(result_2)
            st.table(data)
            st.success("Added");
    # with tab4 :
    #     result_1=db.execute_dql_commands("select * from stations_trains;")
    #     data = pd.DataFrame(result_1)
    #     # data['arrival_time'] = pd.to_numeric(data['arrival_time'].dt.total_seconds())
    #     # data['departure_time'] = pd.to_numeric(data['departure_time'].dt.total_seconds())
    #     # data['delay_time'] = pd.to_numeric(data['delay_time'].dt.total_seconds())
    #     # print(data)
        


def book_ticket():
    email = st.session_state.userId
    password=st.session_state.password
    passenger = st.session_state.passenger
    db ,engine =db_credentials(email,password)
    st.sidebar.button("Home",on_click=cb_user_home)
    

    st.header(f"Tickets booked")
    result_2=db.execute_dql_commands("select * from booking_details order by pnr desc limit '" +str(passenger)+ "'")
    data=pd.DataFrame(result_2)  
    st.table(data) 
def user_or_st_master():
    
    st.title("Railway reservation system")
    st.header("BOOK MY TICKET")
    with st.sidebar:
        selected = option_menu("Railway App", ["PNR Status",'Login'], 
            icons=['search', 'person'], menu_icon="app", default_index=1)
        selected
    if selected == 'PNR Status':
        pnr_no = st.number_input("PNR no.", min_value=1000, max_value=10000, value=1000, step=1)
        # print(pnr_no)
        button1 = button("check Pnr", key = 'check_pnr')
        # print(button)
        if  button1:
            print("----------")
            # db, engine = db_credentials('postgres','postgres')
            # db, engine = db_credentials('postgres','postgres')
            db, engine = db_credentials('anish2','anish2')
            values ={'pnr':pnr_no}
            result_1 = db.execute_dql_commands("select pnr,user_id,train_no,src_station_id,dest_station_id,seat_type,seat_id,booking_status from ticket where pnr = '"+str(pnr_no)+"' ")
            data=pd.DataFrame(result_1)
            st.table(data)
    # if button("Button 1", key="button1"):
    #     if button("Button 2", key="button2"):
    #         if button("Button 3", key="button3"):
    #             st.write("All 3 buttons are pressed")
    if selected == 'Login':
        st.subheader("Are you a user or station master?")
        c1, c2 = st.columns(2)
        with c1:
            st.button("user", on_click=cb_user_login)
        with c2:
            st.button("Railway manager", on_click=cb_station_master_login)
    # if selected == 'Train Status':
    #     # db, engine = db_credentials('postgres','postgres')
    #     # db, engine = db_credentials('postgres','postgres')
    #     db, engine = db_credentials('anish2','anish2')
    #     c1, c2, c3= st.columns(3)
    #     with c1:
    #         train_name  = st.text_input("Train name", key= "trainname")
    #     with c2:
    #         station = st.text_input("station name")
            
        
        # submit =st.button("check status")
        # if submit :

        #     values = { 'train_name': train_name ,'station_name':station}
        #     result_1= db.execute_dql_commands("select get_train_status(:train_name ::VARCHAR(100),:station_name ::VARCHAR(100)) as Status",values)

        #     data=pd.DataFrame([(0, '00:00:00')],columns=['days','H:M:S'])
        #     # data['status'].astype(str)
        #     st.table(data)
            #error
            # result_1 = db.execute_dql_commands("select get_train_status(:train_name ::VARCHAR(100),:station_name ::VARCHAR(100))",values)
            
            # data = pd.DataFrame(result_1)
            # st.write(data)
                

if st.session_state.active_page == 'user_home':
    user_home()

elif st.session_state.active_page == 'station_master_home':
    station_master_home()

elif st.session_state.active_page == 'authentication':
    authentication()
elif(st.session_state.active_page == 'user_or_st_master'):
    user_or_st_master()
elif(st.session_state.active_page == 'book_ticket'):
    book_ticket()


