

# What are the databases existing for snpEff annotations?
java -jar /home/tmichel/snpEff/snpEff.jar databases | grep "Cucumis"
#Cucumis_melo                                                	Cucumis_melo                                                	          	                              	[https://snpeff.blob.core.windows.net/databases/v5_2/snpEff_v5_2_Cucumis_melo.zip, https://snpeff.blob.core.windows.net/databases/v5_0/snpEff_v5_0_Cucumis_melo.zip, https://snpeff.blob.core.windows.net/databases/v5_1/snpEff_v5_1_Cucumis_melo.zip]
#Cucumis_sativus                                             	Cucumis_sativus                                             	          	                              	[https://snpeff.blob.core.windows.net/databases/v5_2/snpEff_v5_2_Cucumis_sativus.zip, https://snpeff.blob.core.windows.net/databases/v5_0/snpEff_v5_0_Cucumis_sativus.zip, https://snpeff.blob.core.windows.net/databases/v5_1/snpEff_v5_1_Cucumis_sativus.zip]



# Download the genome:
java -jar /home/tmichel/snpEff/snpEff.jar download -v Cucumis_sativus


