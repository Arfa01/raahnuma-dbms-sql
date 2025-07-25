import streamlit as st
import pandas as pd
import sqlite3
import plotly.express as px
import plotly.graph_objects as go
from datetime import datetime, timedelta
import time

# Configure page
st.set_page_config(
    page_title="Raahnuma - University Guide",
    page_icon="🎓",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for aesthetic styling
st.markdown("""
<style>
    .main-header {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 2rem;
        border-radius: 10px;
        color: white;
        text-align: center;
        margin-bottom: 2rem;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    }

    .metric-card {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        padding: 1rem;
        border-radius: 10px;
        color: white;
        text-align: center;
        margin: 0.5rem 0;
    }

    .program-card {
        background: white;
        padding: 1.5rem;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        border-left: 4px solid #667eea;
        margin: 1rem 0;
    }

    .fee-badge {
        background: linear-gradient(45deg, #4facfe 0%, #00f2fe 100%);
        color: white;
        padding: 0.25rem 0.75rem;
        border-radius: 20px;
        font-size: 0.8rem;
        font-weight: bold;
    }

    .university-tag {
        background: linear-gradient(45deg, #43e97b 0%, #38f9d7 100%);
        color: white;
        padding: 0.25rem 0.5rem;
        border-radius: 15px;
        font-size: 0.7rem;
        font-weight: bold;
        margin: 0.25rem;
        display: inline-block;
    }

    .sidebar .sidebar-content {
        background: linear-gradient(180deg, #667eea 0%, #764ba2 100%);
    }

    .stSelectbox > div > div {
        background-color: #f8f9fa;
        border-radius: 8px;
    }

    .chat-message {
        background: #f1f3f4;
        padding: 1rem;
        border-radius: 10px;
        margin: 0.5rem 0;
        border-left: 3px solid #667eea;
    }
</style>
""", unsafe_allow_html=True)

# Initialize session state
if 'saved_programs' not in st.session_state:
    st.session_state.saved_programs = []
if 'user_id' not in st.session_state:
    st.session_state.user_id = 1
if 'chat_messages' not in st.session_state:
    st.session_state.chat_messages = []


# Sample data (simulating database queries)
@st.cache_data
def load_sample_data():
    universities = pd.DataFrame({
        'UniversityID': [1, 2, 3, 4, 5],
        'Name': ['COMSATS University', 'LUMS', 'UET Lahore', 'FAST-NUCES', 'ITU Punjab'],
        'Type': ['Public', 'Private', 'Public', 'Private', 'Public'],
        'City': ['Lahore', 'Lahore', 'Lahore', 'Karachi', 'Lahore'],
        'Website': ['comsats.edu.pk', 'lums.edu.pk', 'uet.edu.pk', 'nu.edu.pk', 'itu.edu.pk']
    })

    programs = pd.DataFrame({
        'ProgramID': [1, 2, 3, 4, 5, 6, 7, 8],
        'UniversityID': [1, 1, 2, 3, 4, 5, 2, 3],
        'Name': ['Computer Science', 'Software Engineering', 'Business Administration',
                 'Electrical Engineering', 'Computer Science', 'Data Science',
                 'Economics', 'Mechanical Engineering'],
        'DegreeType': ['BS', 'BS', 'BBA', 'BS', 'BS', 'BS', 'BS', 'BS'],
        'Duration': [4, 4, 4, 4, 4, 4, 4, 4]
    })

    fees = pd.DataFrame({
        'ProgramID': [1, 2, 3, 4, 5, 6, 7, 8],
        'TuitionFee': [120000, 130000, 200000, 110000, 180000, 150000, 220000, 115000],
        'AdmissionFee': [10000, 12000, 15000, 8000, 15000, 12000, 18000, 9000],
        'HostelFee': [30000, 35000, 45000, 28000, 40000, 35000, 50000, 30000]
    })

    eligibility = pd.DataFrame({
        'ProgramID': [1, 2, 3, 4, 5, 6, 7, 8],
        'MinPercentage': [80, 85, 70, 82, 85, 78, 75, 80]
    })

    return universities, programs, fees, eligibility


universities_df, programs_df, fees_df, eligibility_df = load_sample_data()

# Merge data for comprehensive view
program_details = programs_df.merge(universities_df, on='UniversityID') \
    .merge(fees_df, on='ProgramID') \
    .merge(eligibility_df, on='ProgramID')

# Header
st.markdown("""
<div class="main-header">
    <h1>🎓 Raahnuma - Your University Guide</h1>
    <p>Discover the perfect university program for your future</p>
</div>
""", unsafe_allow_html=True)

# Sidebar for navigation and filters
st.sidebar.markdown("## 🔍 Navigation & Filters")
page = st.sidebar.selectbox("Choose a page",
                            ["🏠 Dashboard", "🔍 Search Programs", "💰 Fee Calculator",
                             "💾 Saved Programs", "💬 Chat Groups", "📊 Analytics"])

# Filters
st.sidebar.markdown("### Filter Programs")
selected_city = st.sidebar.selectbox("Select City", ["All"] + list(universities_df['City'].unique()))
selected_degree = st.sidebar.selectbox("Select Degree Type", ["All"] + list(programs_df['DegreeType'].unique()))
fee_range = st.sidebar.slider("Maximum Tuition Fee (PKR)", 0, 300000, 200000, step=10000)
min_percentage = st.sidebar.slider("Your Percentage", 0, 100, 80)

# Apply filters
filtered_data = program_details.copy()
if selected_city != "All":
    filtered_data = filtered_data[filtered_data['City'] == selected_city]
if selected_degree != "All":
    filtered_data = filtered_data[filtered_data['DegreeType'] == selected_degree]
filtered_data = filtered_data[filtered_data['TuitionFee'] <= fee_range]
filtered_data = filtered_data[filtered_data['MinPercentage'] <= min_percentage]

# Main content based on selected page
if page == "🏠 Dashboard":
    # Metrics row
    col1, col2, col3, col4 = st.columns(4)

    with col1:
        st.markdown(f"""
        <div class="metric-card">
            <h3>{len(universities_df)}</h3>
            <p>Universities</p>
        </div>
        """, unsafe_allow_html=True)

    with col2:
        st.markdown(f"""
        <div class="metric-card">
            <h3>{len(programs_df)}</h3>
            <p>Programs</p>
        </div>
        """, unsafe_allow_html=True)

    with col3:
        st.markdown(f"""
        <div class="metric-card">
            <h3>{len(filtered_data)}</h3>
            <p>Matches</p>
        </div>
        """, unsafe_allow_html=True)

    with col4:
        st.markdown(f"""
        <div class="metric-card">
            <h3>{len(st.session_state.saved_programs)}</h3>
            <p>Saved</p>
        </div>
        """, unsafe_allow_html=True)

    st.markdown("---")

    # Charts
    col1, col2 = st.columns(2)

    with col1:
        st.subheader("🏛️ Universities by Type")
        type_counts = universities_df['Type'].value_counts()
        fig_pie = px.pie(values=type_counts.values, names=type_counts.index,
                         color_discrete_sequence=['#667eea', '#764ba2'])
        fig_pie.update_layout(showlegend=True, height=300)
        st.plotly_chart(fig_pie, use_container_width=True)

    with col2:
        st.subheader("💰 Average Fees by University")
        avg_fees = program_details.groupby('Name_y')['TuitionFee'].mean().sort_values(ascending=True)
        fig_bar = px.bar(x=avg_fees.values, y=avg_fees.index, orientation='h',
                         color=avg_fees.values, color_continuous_scale='viridis')
        fig_bar.update_layout(height=300, xaxis_title="Average Tuition Fee (PKR)")
        st.plotly_chart(fig_bar, use_container_width=True)

    # Recent programs
    st.subheader("🔥 Featured Programs")
    for idx, row in filtered_data.head(3).iterrows():
        st.markdown(f"""
        <div class="program-card">
            <div style="display: flex; justify-content: between; align-items: center;">
                <div>
                    <h4>{row['Name_x']}</h4>
                    <p><strong>{row['Name_y']}</strong> • {row['City']} • {row['DegreeType']} • {row['Duration']} years</p>
                    <span class="fee-badge">PKR {row['TuitionFee']:,}</span>
                    <span class="university-tag">{row['MinPercentage']}% required</span>
                </div>
            </div>
        </div>
        """, unsafe_allow_html=True)

elif page == "🔍 Search Programs":
    st.header("🔍 Search University Programs")

    # Search bar
    search_term = st.text_input("🔎 Search programs by name", placeholder="e.g., Computer Science, Engineering...")

    if search_term:
        filtered_data = filtered_data[filtered_data['Name_x'].str.contains(search_term, case=False, na=False)]

    st.markdown(f"**Found {len(filtered_data)} programs matching your criteria**")

    # Display programs
    for idx, row in filtered_data.iterrows():
        col1, col2 = st.columns([3, 1])

        with col1:
            st.markdown(f"""
            <div class="program-card">
                <h4>{row['Name_x']}</h4>
                <p><strong>🏛️ {row['Name_y']}</strong></p>
                <p>📍 {row['City']} • 🎓 {row['DegreeType']} • ⏱️ {row['Duration']} years</p>
                <p>💰 Tuition: <strong>PKR {row['TuitionFee']:,}</strong> | 
                   📊 Required: <strong>{row['MinPercentage']}%</strong></p>
            </div>
            """, unsafe_allow_html=True)

        with col2:
            if st.button(f"💾 Save", key=f"save_{row['ProgramID']}"):
                if row['ProgramID'] not in st.session_state.saved_programs:
                    st.session_state.saved_programs.append(row['ProgramID'])
                    st.success("✅ Program saved!")
                else:
                    st.info("Already saved!")

            if st.button(f"ℹ️ Details", key=f"details_{row['ProgramID']}"):
                st.info(f"Program ID: {row['ProgramID']}\nWebsite: {row['Website']}")

elif page == "💰 Fee Calculator":
    st.header("💰 Fee Calculator")

    st.markdown("### Calculate your total education cost")

    col1, col2 = st.columns(2)

    with col1:
        selected_program = st.selectbox("Select Program",
                                        options=filtered_data['Name_x'].unique())

        if selected_program:
            program_data = filtered_data[filtered_data['Name_x'] == selected_program].iloc[0]

            st.markdown("#### Fee Breakdown")
            tuition = program_data['TuitionFee']
            admission = program_data['AdmissionFee']
            hostel = program_data['HostelFee']

            # Additional costs
            books = st.slider("Books & Supplies (per year)", 0, 50000, 15000)
            transport = st.slider("Transportation (per year)", 0, 100000, 30000)
            misc = st.slider("Miscellaneous (per year)", 0, 50000, 20000)

            # Calculate totals
            annual_cost = tuition + hostel + books + transport + misc
            total_cost = annual_cost * program_data['Duration'] + admission

    with col2:
        if selected_program:
            st.markdown("#### Cost Summary")

            # Create a pie chart for cost breakdown
            costs = {
                'Tuition': tuition,
                'Hostel': hostel,
                'Books': books,
                'Transport': transport,
                'Miscellaneous': misc,
                'Admission': admission
            }

            fig_costs = px.pie(values=list(costs.values()), names=list(costs.keys()),
                               color_discrete_sequence=px.colors.qualitative.Set3)
            st.plotly_chart(fig_costs, use_container_width=True)

            st.markdown(f"""
            **💰 Annual Cost: PKR {annual_cost:,}**  
            **🎓 Total Program Cost: PKR {total_cost:,}**
            """)

elif page == "💾 Saved Programs":
    st.header("💾 Your Saved Programs")

    if st.session_state.saved_programs:
        saved_data = program_details[program_details['ProgramID'].isin(st.session_state.saved_programs)]

        for idx, row in saved_data.iterrows():
            col1, col2 = st.columns([4, 1])

            with col1:
                st.markdown(f"""
                <div class="program-card">
                    <h4>{row['Name_x']}</h4>
                    <p><strong>🏛️ {row['Name_y']}</strong> • 📍 {row['City']}</p>
                    <p>💰 PKR {row['TuitionFee']:,} • 📊 {row['MinPercentage']}% required</p>
                </div>
                """, unsafe_allow_html=True)

            with col2:
                if st.button(f"🗑️ Remove", key=f"remove_{row['ProgramID']}"):
                    st.session_state.saved_programs.remove(row['ProgramID'])
                    st.rerun()
    else:
        st.info("No saved programs yet. Start exploring programs to save your favorites!")

elif page == "💬 Chat Groups":
    st.header("💬 University Chat Groups")

    # Display available chat groups
    st.subheader("Available Groups")

    chat_groups = [
        {"name": "COMSATS CS Students", "members": 45, "program": "Computer Science"},
        {"name": "LUMS Business Hub", "members": 32, "program": "Business Administration"},
        {"name": "UET Engineering", "members": 67, "program": "Electrical Engineering"}
    ]

    for group in chat_groups:
        col1, col2 = st.columns([3, 1])
        with col1:
            st.markdown(f"""
            <div class="program-card">
                <h4>👥 {group['name']}</h4>
                <p>Program: {group['program']} • Members: {group['members']}</p>
            </div>
            """, unsafe_allow_html=True)
        with col2:
            if st.button(f"Join", key=f"join_{group['name']}"):
                st.success("Joined group!")

    # Chat interface
    st.subheader("💬 Group Chat")

    # Display messages
    for message in st.session_state.chat_messages:
        st.markdown(f"""
        <div class="chat-message">
            <strong>{message['user']}:</strong> {message['text']}
            <small style="color: gray;">{message['time']}</small>
        </div>
        """, unsafe_allow_html=True)

    # Message input
    new_message = st.text_input("Type your message...")
    if st.button("Send") and new_message:
        st.session_state.chat_messages.append({
            'user': 'You',
            'text': new_message,
            'time': datetime.now().strftime("%H:%M")
        })
        st.rerun()

elif page == "📊 Analytics":
    st.header("📊 University Analytics")

    # Program distribution
    col1, col2 = st.columns(2)

    with col1:
        st.subheader("Programs by City")
        city_counts = program_details.groupby('City').size()
        fig_city = px.bar(x=city_counts.index, y=city_counts.values,
                          color=city_counts.values, color_continuous_scale='blues')
        st.plotly_chart(fig_city, use_container_width=True)

    with col2:
        st.subheader("Fee Distribution")
        fig_hist = px.histogram(program_details, x='TuitionFee', nbins=10,
                                color_discrete_sequence=['#667eea'])
        fig_hist.update_layout(xaxis_title="Tuition Fee (PKR)")
        st.plotly_chart(fig_hist, use_container_width=True)

    # Detailed table
    st.subheader("📋 Detailed Program Data")
    st.dataframe(
        program_details[['Name_x', 'Name_y', 'City', 'TuitionFee', 'MinPercentage']].rename(columns={
            'Name_x': 'Program',
            'Name_y': 'University',
            'TuitionFee': 'Tuition Fee',
            'MinPercentage': 'Min %'
        }),
        use_container_width=True
    )

# Footer
st.markdown("---")
st.markdown("""
<div style="text-align: center; color: #666; margin-top: 2rem;">
    <p>🎓 Raahnuma - Guiding your educational journey • Made with ❤️ using Streamlit</p>
</div>
""", unsafe_allow_html=True)