import streamlit as st
import httpx
import os
from dotenv import load_dotenv

# Charger les variables d'environnement depuis .env
load_dotenv()

# Configuration
API_URL = os.getenv("API_URL", "http://api-service:8000")

st.title("🎯 Gestion des Clients")
st.markdown("---")

# Sidebar pour la navigation
page = st.sidebar.selectbox("Navigation", ["📋 Liste des clients", "➕ Ajouter un client", "🔍 Rechercher par ID"])

# Page 1: Liste des clients
if page == "📋 Liste des clients":
    st.header("Liste des clients")
    
    if st.button("🔄 Rafraîchir"):
        st.rerun()
    
    try:
        response = httpx.get(f"{API_URL}/clients", timeout=5)
        if response.status_code == 200:
            clients = response.json()
            
            if clients:
                st.success(f"✅ {len(clients)} clients trouvés")
                
                for client in clients:
                    with st.expander(f"👤 {client['first_name']} {client['last_name']} (ID: {client['id']})"):
                        st.write(f"**Email:** {client['email']}")
                        st.write(f"**ID:** {client['id']}")
                        
                        if st.button(f"🗑️ Supprimer", key=f"delete_{client['id']}"):
                            delete_response = httpx.delete(f"{API_URL}/clients/{client['id']}")
                            if delete_response.status_code == 200:
                                st.success(f"✅ Client {client['id']} supprimé !")
                                st.rerun()
                            else:
                                st.error(f"❌ Erreur lors de la suppression")
            else:
                st.info("ℹ️ Aucun client dans la base de données")
        else:
            st.error(f"❌ Erreur API: {response.status_code}")
    except Exception as e:
        st.error(f"❌ Erreur de connexion à l'API: {str(e)}")

# Page 2: Ajouter un client
elif page == "➕ Ajouter un client":
    st.header("Ajouter un nouveau client")
    
    with st.form("add_client_form"):
        first_name = st.text_input("Prénom")
        last_name = st.text_input("Nom")
        email = st.text_input("Email")
        
        submitted = st.form_submit_button("➕ Ajouter")
        
        if submitted:
            if first_name and last_name and email:
                try:
                    data = {
                        "first_name": first_name,
                        "last_name": last_name,
                        "email": email
                    }
                    response = httpx.post(f"{API_URL}/clients", json=data, timeout=5)
                    
                    if response.status_code == 200:
                        client = response.json()
                        st.success(f"✅ Client créé avec l'ID {client['id']} !")
                        st.json(client)
                    else:
                        st.error(f"❌ Erreur: {response.status_code}")
                except Exception as e:
                    st.error(f"❌ Erreur: {str(e)}")
            else:
                st.warning("⚠️ Tous les champs sont obligatoires")

# Page 3: Rechercher par ID
elif page == "🔍 Rechercher par ID":
    st.header("Rechercher un client par ID")
    
    client_id = st.number_input("ID du client", min_value=1, step=1)
    
    if st.button("🔍 Rechercher"):
        try:
            response = httpx.get(f"{API_URL}/clients/{client_id}", timeout=5)
            
            if response.status_code == 200:
                client = response.json()
                st.success("✅ Client trouvé !")
                
                col1, col2 = st.columns(2)
                with col1:
                    st.metric("Prénom", client['first_name'])
                    st.metric("Nom", client['last_name'])
                with col2:
                    st.metric("Email", client['email'])
                    st.metric("ID", client['id'])
                
                if st.button("🗑️ Supprimer ce client"):
                    delete_response = httpx.delete(f"{API_URL}/clients/{client_id}")
                    if delete_response.status_code == 200:
                        st.success("✅ Client supprimé !")
                    else:
                        st.error("❌ Erreur lors de la suppression")
            elif response.status_code == 404:
                st.warning(f"⚠️ Aucun client trouvé avec l'ID {client_id}")
            else:
                st.error(f"❌ Erreur: {response.status_code}")
        except Exception as e:
            st.error(f"❌ Erreur: {str(e)}")

# Footer
st.markdown("---")
st.markdown("🚀 **API Backend:** " + API_URL)

# Health check dans la sidebar
with st.sidebar:
    st.markdown("---")
    st.subheader("🏥 État de l'API")
    try:
        health_response = httpx.get(f"{API_URL}/health", timeout=2)
        if health_response.status_code == 200:
            st.success("✅ API opérationnelle")
        else:
            st.error("❌ API en erreur")
    except:
        st.error("❌ API inaccessible")
