<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:head="http://schemas.timbrasil.com.br/mw/envelope/Header" xmlns:crm="http://schemas.timbrasil.com.br/mw/services/esb/CRM_Notify_OrderingStatus">
	<xsl:output method="xml" indent="yes" encoding="iso-8859-1"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:variable name="billingProfileArea">
		<xsl:value-of select="/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO' and (ProductType='VOZ_MOVEL' or ProductType='DADOS_MOVEL' or ProductType='VOZ_FIXO') ]/BillingProfileArea"/>
	</xsl:variable>
	
	<xsl:variable name="areaLength" select="string-length($billingProfileArea)"/>
	
	<xsl:variable name="lastAreaCode" select="substring($billingProfileArea, ($areaLength - 1), 2)"/>
	
	<xsl:variable name="previousBillingProfileArea">
		<xsl:value-of select="/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO' and (ProductType='VOZ_MOVEL' or ProductType='DADOS_MOVEL' or ProductType='VOZ_FIXO') ]/PreviousBillingProfileArea"/>
	</xsl:variable>
	
	<xsl:template name="dataDelivery">
		<xsl:param name="dataDev"></xsl:param>
		<xsl:value-of select="concat((substring($dataDev,1,4)),'/',(substring($dataDev,5,2)),'/',(substring($dataDev,7,2)))"/>		
	</xsl:template>
	
	<xsl:template name="transCod">
		<xsl:param name="codDesc"></xsl:param>
		<xsl:choose>
			<xsl:when test="$codDesc='0'">Parametrizacao do sistema</xsl:when>
			<xsl:when test="$codDesc='1'">Area de risco</xsl:when>
			<xsl:when test="$codDesc='2'">Cliente Ausente</xsl:when>
			<xsl:when test="$codDesc='3'">Cliente mudou-se</xsl:when>
			<xsl:when test="$codDesc='4'">Cliente sem a documentacao exigida</xsl:when>
			<xsl:when test="$codDesc='5'">Cliente desconhecido no endereco</xsl:when>
			<xsl:when test="$codDesc='6'">Endereco nao localizado</xsl:when>
			<xsl:when test="$codDesc='7'">Pedido cancelado pelo cliente</xsl:when>
			<xsl:when test="$codDesc='8'">Estabelecimento  fechado</xsl:when>
			<xsl:when test="$codDesc='9'">Sinistro</xsl:when>
			<xsl:when test="$codDesc='10'">Suspeita de fraude</xsl:when>
			<xsl:when test="$codDesc='11'">Endereco insuficiente</xsl:when>
			<xsl:when test="$codDesc='12'">Mercadoria Fisica em desacordo com a NF</xsl:when>
			<xsl:when test="$codDesc='13'">Cliente desconhece o pedido</xsl:when>
			<xsl:when test="$codDesc='14'">Nao Utilizar</xsl:when>
			<xsl:when test="$codDesc='15'">Problemas operacionais</xsl:when>
			<xsl:when test="$codDesc='16'">Mercadoria apreendida na SEFAZ</xsl:when>
			<xsl:when test="$codDesc='17'">Feriado local</xsl:when>
			<xsl:when test="$codDesc='18'">Troca de nota -Comodato Inter-Estadual</xsl:when>
			<xsl:when test="$codDesc='19'">Zona rural</xsl:when>
			<xsl:when test="$codDesc='20'">Pedido cancelado a pedido do COMERCIAL</xsl:when>
			<xsl:when test="$codDesc='23'">Pedido de Investigacao</xsl:when>
			<xsl:when test="$codDesc='21'">Nao Utilizar</xsl:when>
			<xsl:when test="$codDesc='22'">Aguardando Liberacao da SUFRAMA</xsl:when>
			<xsl:when test="$codDesc='24'">Problemas de doc. Check list/Romaneio</xsl:when>
			<xsl:when test="$codDesc='25'">Forca Maior - Intemperies Naturais</xsl:when>
			<xsl:when test="$codDesc='34'">Mercad em desacordo com pedido de compra</xsl:when>
			<xsl:when test="$codDesc='27'">Cep Generico</xsl:when>
			<xsl:when test="$codDesc='32'">Aguardando Retirada - Correios</xsl:when>
			<xsl:when test="$codDesc='26'">Aguardando Reagendamento</xsl:when>
			<xsl:when test="$codDesc='29'">Pedido Cancelado pela Area de Fraude</xsl:when>
			<xsl:when test="$codDesc='30'">Erro na Ordem de Venda</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:variable name="isOnHold" select="boolean(//StatusReason='On Hold')" />
	
	<xsl:variable name="isDelivery" select="//work-context/isDeliveryRet"/>
	
	<xsl:variable name="previousAreaLength" select="string-length($previousBillingProfileArea)"/>
	
	<xsl:variable name="lastPreviousAreaCode" select="substring($previousBillingProfileArea, ($previousAreaLength - 1), 2)"/>
	
	<xsl:variable name="isExpressRollBack" select="boolean(//work-context[isExpressRollBack='1'])" />
	
	<xsl:variable name="isDiscountControle" select="boolean(//ListOfOrderLineItems/OrderLineItem[ProductCategory='DESCONTO' and ProductType='CONTROLE'])"/>
	
	<xsl:variable name="isFirstNotificationFromDelivery" select="boolean(//ListOfOrderLineItems/OrderLineItem[(ProductCategory='APARELHO' or ProductSubType='TIM_CHIP') and ListOfOrderItemXA/OrderItemXA[Name='Delivery']/Value='Y'])" />
	
	<xsl:variable name="isFirstNotificationFromDeliveryDOC" select="boolean(//work-context[action='DOC'] and //list-parameters/isAcapulcoTelevendasPos != 'true')" />
	
	<!-- Cancelamento de change pos delivery - inicio-->
	<xsl:variable name="cancTrue" select="//work-context/cancel"/>	
	<!-- Cancelamento de change pos delivery - fim-->
	
	<xsl:variable name="concludeRule" select="not(boolean(//work-context[concludeRule='YES']))" />
	
	<xsl:variable name="DeliveryAparelhoId" select="//ListOfOrderLineItems/OrderLineItem[(ProductCategory='APARELHO' or ProductSubType='TIM_CHIP') and ListOfOrderItemXA/OrderItemXA[Name='Delivery']/Value='Y']/Id" />
	
	<xsl:variable name="isAparelhoId" select="//ListOfOrderLineItems/OrderLineItem[(ProductCategory='APARELHO')]/Id" />
	
	<!-- Data da entrega da logistica -delivery - inicio-->
	<xsl:variable name="DeliveryDateEnd" select="//work-context//delivery-date"/>
	<!-- Data da entrega da logistica -delivery - fim-->
	
	<xsl:variable name="isOwnership" select="boolean((/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO' and (ActionCode='Retomar' or ActionCode='Atualizar')] and
		/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/BillingProfileName and
		/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/PreviousBillingProfileName and
		(/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/PreviousBillingProfileName !=
		/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/BillingProfileName) and
		normalize-space(/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/BillingProfileName) !='' and
		normalize-space(/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/PreviousBillingProfileName) != '')
		or
		(/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO' and (ActionCode='Retomar')] and
		/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/BillingProfileName and
		/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/PreviousBillingProfileName and
		(/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/PreviousBillingProfileName !=
		/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/BillingProfileName) and
		normalize-space(/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/BillingProfileName) !='' and
		normalize-space(/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='ACESSO']/PreviousBillingProfileName) != '' and
		$lastAreaCode = $lastPreviousAreaCode and
		/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='TECNICO' and ProductType='NOVO' and ProductSubType='NUMERO' and ActionCode='Nova']))"/>
	
	<xsl:variable name="resultCode">
		<xsl:value-of select="//work-context/result-code"/>
	</xsl:variable>
	
	<xsl:template name="formatdate">
		<xsl:param name="DateTimeStr" />
		<!-- esempio 2014-06-17T12:01:57.934+02:00 -->
		<xsl:variable name="unformattedOrderData" select="$DateTimeStr"/>
		<xsl:variable name="orderDateYYYY" select="substring($unformattedOrderData, 1,4)"/>
		<xsl:variable name="orderDateMM" select="substring($unformattedOrderData, 6,2)"/>
		<xsl:variable name="orderDateDD" select="substring($unformattedOrderData, 9,2)"/>
		<xsl:variable name="orderDateTime" select="substring($unformattedOrderData, 12,8)"/>
		
		<xsl:value-of select="$orderDateMM" />
		<xsl:value-of select="'/'" />
		<xsl:value-of select="$orderDateDD" />
		<xsl:value-of select="'/'" />
		<xsl:value-of select="$orderDateYYYY" />
		<xsl:value-of select="' '" />
		<xsl:value-of select="$orderDateTime" />
		
	</xsl:template>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="not(/ROOT/ECODE)">
				<xsl:call-template name="requestData" >
					<xsl:with-param name="isSggNotification" select="'false'" />
				</xsl:call-template>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="requestData">
		<xsl:param name="isSggNotification"/>
	
		<data>

		<xsl:if test="$isSggNotification = 'true'">
			<xsl:copy-of select="//Order"/>
		</xsl:if>

			<tid>
				<xsl:choose>
					<xsl:when test="/ROOT/sca-request/payload/order-item-status/commercial-order/message-id != ''" >
						<xsl:value-of select="/ROOT/sca-request/payload/order-item-status/commercial-order/message-id" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/OrderNumber" />
					</xsl:otherwise>
				</xsl:choose>
			</tid>
			<order>
				<id>
					<xsl:value-of select="/ROOT/sca-request/payload/order-item-status/commercial-order/@id"/>
				</id>
			</order>
			<asset>
				<external-integration>
					<id>
						<xsl:call-template name="getExternalIntegration" />
					</id>
				</external-integration>
			</asset>
			<root-item>
				<xsl:choose>
					<xsl:when test="//OrderLineItem[ProductCategory='COMPARTILHAMENTO_DE_DADOS' and ProductType='COMPARTILHAMENTO_DE_DADOS']">
						<id>
							<xsl:value-of select="//OrderLineItem[ProductCategory='COMPARTILHAMENTO_DE_DADOS' and ProductType='COMPARTILHAMENTO_DE_DADOS']/Id"/>
						</id>
					</xsl:when>
					<xsl:otherwise>
						<id>
							<xsl:value-of select="/ROOT/sca-request/payload/order-item-status/commercial-order/@action-id"/>
						</id>
					</xsl:otherwise>
				</xsl:choose>
			</root-item>
            <plataforma><xsl:value-of select="//work-context/tipo" /></plataforma>
			<status>
				<xsl:choose>
					<xsl:when test="//OrderLineItem[ProductCategory='COMPARTILHAMENTO_DE_DADOS' and ProductType='COMPARTILHAMENTO_DE_DADOS']">
						<xsl:call-template name="getCommercialItemStatusRoot">
							<xsl:with-param name="status" select="'success'"/>
						</xsl:call-template>		
					</xsl:when>
					
					<xsl:otherwise>
						<xsl:choose>
						
							<xsl:when test="//work-context/failure-root = 'true'">Falhou</xsl:when>
							
							<xsl:when test="//work-context/lastNotifyObrRuraisPos = 'true'">Execucao Parcial</xsl:when>
						
							<xsl:when test="(/ROOT/sca-request/payload/order-item-status/items/item/@portability = 'true') and //list-parameters[portability='PENDING']">Pendente de Portabilidade</xsl:when>
							
							<xsl:when test="$isOnHold and (/ROOT/sca-request/payload/order-item-status/commercial-order/@status != 'error')">Execucao Parcial</xsl:when>
							
							<xsl:when test="//work-context[(flow-type='RESUME' and /ROOT/sca-request/payload/order-item-status/commercial-order/@status != 'error') or (flow-type='DISCONNECT' and /ROOT/sca-request/payload/order-item-status/commercial-order/@status != 'error')]">Concluiu</xsl:when>
							
							<xsl:when test="//work-context[cancel-point &lt;= '4'and status-pedido = '2']">Execucao Parcial</xsl:when>
							
							<xsl:when test="//work-context[cancel='true']">Cancelado</xsl:when>
							
							<xsl:when test="//work-context[cancel-ven='true']">Cancelado</xsl:when>
							
							<xsl:when test="((//payload/order-item-status/commercial-order/@action-id)=(//items/item[1]/@id)) and (//items/item[1]/@status='error')">Falhou</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and  //work-context[cancel-point>='1'] and //work-context[cancel='true']">Concluiu</xsl:when>
							
							<!-- <xsl:when test="$isDiscountControle">Concluiu</xsl:when>  -->
							
							<xsl:when test="//work-context/notification-type='EXC'">Execucao Parcial</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and //work-context/logistic-order-status-code='1006'">Concluiu</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and //work-context/logistic-order-status-code='1007' and //work-context/delivery-type='COMPOUND'">Concluiu</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and //work-context/notification-type='PEN'">Concluiu</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and //work-context/logistic-order-status-code='1007'">Falhou</xsl:when>

							<xsl:when test="$isFirstNotificationFromDelivery and //work-context/logistic-order-status-code='1008'">Cancelado</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId">Execucao Parcial</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and @id!=$DeliveryAparelhoId">Concluiu</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and //work-context//delivery-code='2' and //work-context/isFidelityRet != 'YES'">Concluiu</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and //work-context//delivery-code='2' and //work-context/isFidelityRet = 'YES' and //work-context/last-task='YES'">Concluiu</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and //work-context//delivery-code='3'">Falhou</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and $isFirstNotificationFromDeliveryDOC">Execucao Parcial</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and $concludeRule and /ROOT/sca-request/payload/order-item-status//@status = 'success' and //work-context[resume-onhold-pos-true='true']">Concluiu</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and $concludeRule and /ROOT/sca-request/payload/order-item-status//@status != 'success' and //work-context[resume-onhold-pos-true='true']">Falhou</xsl:when>
							
							<xsl:when test="$isFirstNotificationFromDelivery and $concludeRule">Execucao Parcial</xsl:when>
							
							<xsl:when test="//work-context/fail-portability-from-bdo='true'">Falhou</xsl:when>
							
							<xsl:otherwise>
								<xsl:call-template name="getCommercialItemStatusRoot">
									<xsl:with-param name="status">
										<xsl:value-of select="/ROOT/sca-request/payload/order-item-status/commercial-order/@status" />
									</xsl:with-param>
								</xsl:call-template>	
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</status>
			
			<xsl:if test="//work-context/logistic-order-status-code='1004'">
				<point-no-return>
					<xsl:value-of select="'Y'" />
				</point-no-return>
			</xsl:if>
			
			<completed-date>
				<xsl:copy>
					<xsl:call-template name="formatdate">
						<xsl:with-param name="DateTimeStr" select="/ROOT/sca-request/payload/order-item-status/time"/>
					</xsl:call-template>
				</xsl:copy>
			</completed-date>
			
			<xsl:if test="(//work-context[is-vendita='YES']) and (//work-context[logistic-order-status-code='1003'])">
				<simcard>
					<xsl:choose>
						<xsl:when test="//work-context/new-sim-iccid !=''">
							<xsl:value-of select="//work-context/new-sim-iccid"/>
						</xsl:when>
						<xsl:when test="count(//work-context//nota-fiscal) > 1 and count(//work-context//nota-fiscal[numero-ICCID-material != '']) = 1">
							<xsl:value-of select="//work-context//nota-fiscal[numero-ICCID-material != '']/numero-ICCID-material"/>
						</xsl:when>
						<xsl:when test="count(//work-context//nota-fiscal) > 1">
							<xsl:variable name="SAPSalesOrderId" select="/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory = 'TECNICO' and ProductType='NOVO' and ProductSubType='TIM_CHIP']/SAPSalesOrderId"/>
							<xsl:value-of select="//work-context//nota-fiscal[ordem-SAP = $SAPSalesOrderId]/numero-ICCID-material"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="//work-context//nota-fiscal/numero-ICCID-material"/>
						</xsl:otherwise>
					</xsl:choose>						
				</simcard>
			</xsl:if>
			
			<xsl:if test="not(/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/ListOfOrderLineItems/OrderLineItem[ProductCategory='COMPARTILHAMENTO_DE_DADOS' and ActionCode='-'])">
				<crm:order-item-list>
					<xsl:apply-templates select="/ROOT/sca-request/payload/order-item-status/items/item" />					
				</crm:order-item-list>
			</xsl:if>
			<crm:event-list>
				<crm:event>
					<crm:message-id>
						<xsl:choose>
							<xsl:when test="/ROOT/sca-request/payload/order-item-status/commercial-order/message-id != ''" >
								<xsl:value-of select="/ROOT/sca-request/payload/order-item-status/commercial-order/message-id" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/OrderNumber" />
							</xsl:otherwise>
						</xsl:choose>
					</crm:message-id>
				</crm:event>
			</crm:event-list>
		</data>
	</xsl:template>
	
	
	<xsl:template name="getCommercialItemStatusRoot">
		<xsl:param name="status" />
		<xsl:choose>					
			<xsl:when test="($isExpressRollBack)">Falhou</xsl:when>	
			<xsl:when test="($isOwnership) and $status='error'">Abortou</xsl:when>
			<xsl:when test="$status='success'">Concluiu</xsl:when>
			<xsl:when  test="$status='error'">Falhou</xsl:when>
			<xsl:when test="$status='executing' and  $resultCode='2' ">Concluiu</xsl:when>
			<xsl:when test="$status='executing'">Execucao Parcial</xsl:when>
			<xsl:otherwise>Falhou</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="getCommercialItemStatus">
		<xsl:param name="status" />
		<xsl:choose>			
			<xsl:when test="($isExpressRollBack)">Falhou</xsl:when>	
			<xsl:when test="$status='success'">Concluiu</xsl:when>
			<xsl:when  test="$status='error'">Falhou</xsl:when>
			<xsl:when test="$status='executing'">Execucao Parcial</xsl:when>  
			<xsl:otherwise>Falhou</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="commercialItemStatusMng">
		<xsl:param name="status" />
		<xsl:param name="id" />
		<xsl:choose>
			<xsl:when test="/ROOT/sca-request/work-context/items/item/id=$id">
				<xsl:call-template name="getCommercialItemStatus">					
					<xsl:with-param name="status">
						<xsl:value-of select="$status" />
					</xsl:with-param>					
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="getCommercialItemStatus">
					<xsl:with-param name="status">
						<xsl:value-of select="$status" />
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="getPortabilityCommercialItemStatus">
		<xsl:param name="status" />	
		<xsl:choose>
			<xsl:when test="$status='success' and  $resultCode='2' ">Cancelada</xsl:when>
			<xsl:when test="($status='success') ">
				<xsl:choose>
					<xsl:when test="/ROOT/sca-request/work-context[portability='Canceled']">Cancelada</xsl:when>
					<xsl:when test="/ROOT/sca-request/list-parameters[portability='PENDING']">Execucao Parcial</xsl:when>
					<xsl:otherwise>Concluiu</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when  test="$status='error'">Falhou</xsl:when>
			<xsl:when test="$status='executing'">Execucao Parcial</xsl:when>
			<xsl:otherwise>Falhou</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="order-item-status/items/item">
		
		<xsl:choose>
			<xsl:when test="@id=//OrderLineItem[ProductCategory='COMPARTILHAMENTO_DE_DADOS' and ProductType='COMPARTILHAMENTO_DE_DADOS']/Id">
				<!-- do nothing -->
			</xsl:when>
			<xsl:otherwise>
				<crm:order-item>
					<crm:id>
						<xsl:value-of select="@id" />
					</crm:id>
					<crm:status>
						<xsl:choose>
								<xsl:when test="$isFirstNotificationFromDelivery and //work-context/status-pedido='2'">Execucao Parcial123</xsl:when>
							<xsl:when test="@portability='true'">
								<xsl:call-template name="getPortabilityCommercialItemStatus">
									<xsl:with-param name="status">
										<xsl:value-of select="@status" />
									</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="//work-context/failure-root = 'true'">Falhou</xsl:when>
							<xsl:when test="(//work-context/logistic-order-status-code='1007') and  (//is-vendita='YES')">Falhou</xsl:when>
							<xsl:when test="//work-context[cancel='true']">Cancelado</xsl:when>
							<xsl:when test="//work-context[flow-type='PROVIDE' and (/ROOT/sca-request/payload/order-item-status/commercial-order/@status != 'error')]">Execucao Parcial</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId and //work-context[cancel='true']">Cancelado</xsl:when>
							<xsl:when test="//work-context[cancel-ven='true']">Cancelado</xsl:when>
							<!-- WA SDN 319786 - Todos os OrderLineItem com a condição abaixo devem SEMPRE ser notificados como Concluiu -->
							<xsl:when test="@status='error' and	not(@id=//OrderLineItem[ProductCategory='DESCONTO' and ProductType='CONTROLE' and (ActionCode='Excluir' or ActionCode='Atualizar')]/Id)">Falhou</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and //work-context/logistic-order-status-code='1002'">Execucao Parcial</xsl:when>
							<xsl:when test="//work-context/notification-type='PEN'">Concluiu</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId and @status='error'">Falhou</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId and //work-context//logistic-order-status-code='1003'">Execucao Parcial</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and @id=$isAparelhoId and //sca-request/list-parameters/HasFidelity='true' and not(//work-context/isFidelityRet='NO')">Execucao Parcial</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and @id=$isAparelhoId and //sca-request/list-parameters/BeforeFidelity='true'">Execucao Parcial</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId and //work-context//delivery-code='2'">Concluiu</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId and //work-context//delivery-code='3'">Falhou</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and //work-context/logistic-order-status-code='1006'">Cancelado</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and //work-context/logistic-order-status-code='1007'">Cancelado</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId">Execucao Parcial</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and @id!=$DeliveryAparelhoId">Concluiu</xsl:when>
							<xsl:when test="$isFirstNotificationFromDeliveryDOC">Execucao Parcial</xsl:when>
							<xsl:when test="$isFirstNotificationFromDelivery and $concludeRule">Execucao Parcial</xsl:when>
							
							<xsl:otherwise>
								<xsl:call-template name="commercialItemStatusMng">
									<xsl:with-param name="status">
										<xsl:choose>
											<!-- WA SDN 319786 - Todos os OrderLineItem com a condição abaixo devem SEMPRE ser notificados como Concluiu -->
											<xsl:when test="@id=//OrderLineItem[ProductCategory='DESCONTO' and ProductType='CONTROLE' and (ActionCode='Excluir' or ActionCode='Atualizar')]/Id">
												<xsl:value-of select="'success'" />
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="@status" />
											</xsl:otherwise>									
										</xsl:choose>
									</xsl:with-param>
									<xsl:with-param name="id">
										<xsl:value-of select="@id" />
									</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</crm:status>
					<crm:completed-date>
						<xsl:call-template name="formatdate">
							<xsl:with-param name="DateTimeStr" select="@time"/>
						</xsl:call-template>
					</crm:completed-date>
					<xsl:if test="error and not($isOwnership) and not($isFirstNotificationFromDelivery)">
						<crm:desc>
							<xsl:value-of select="error/@description" />
						</crm:desc>		 
					</xsl:if>
					<xsl:if test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId and //work-context/logistic-order-status-code">
						<xsl:choose>
							<xsl:when test="(//work-context/logistic-order-status-code = '0004' or //work-context/logistic-order-status-code = '0005')">
								<crm:logistic-order-status-code>
									<xsl:value-of select="//work-context/logistic-order-status-code" />
								</crm:logistic-order-status-code>
							</xsl:when>
							<xsl:when test="//work-context[cancel='true' and cancel-point &lt; '2' and status-pedido = '2']">
								<crm:logistic-order-status-code>
									<xsl:value-of select="1001"/>
								</crm:logistic-order-status-code>
							</xsl:when>
							<xsl:when test="//work-context[cancel='true' and (cancel-point &gt;= '2' and cancel-point &lt; '3' and status-pedido = '2')]">
								<crm:logistic-order-status-code>
									<xsl:value-of select="1002"/>
								</crm:logistic-order-status-code>
							</xsl:when>
							<xsl:when test="//work-context[cancel='true' and (cancel-point &gt;= '3' and cancel-point &lt;= '4' and status-pedido = '2')]">
								<crm:logistic-order-status-code>
									<xsl:value-of select="1003"/>
								</crm:logistic-order-status-code>
							</xsl:when>
							<xsl:when test="//work-context[cancel='true']">
								<crm:logistic-order-status-code>
									<xsl:value-of select="1008"/>
								</crm:logistic-order-status-code>
							</xsl:when>
							<xsl:when test="//list-parameters/BeforeFidelity='true'">
								<crm:logistic-order-status-code>
									<xsl:value-of select="'0001'"/>
								</crm:logistic-order-status-code>
							</xsl:when>
							<xsl:when test="(//work-context[isFidelityRet='YES']) and ((@status != 'error') and (not(//list-parameters/HasFidelity='true'))) and (//work-context[notification-type='PEN'])">
								<crm:logistic-order-status-code>
									<xsl:value-of select="'0002'"/>
								</crm:logistic-order-status-code>
							</xsl:when>
							<xsl:when test="(//work-context[isFidelityRet='YES']) and (@status='error')">
								<crm:logistic-order-status-code>
									<xsl:value-of select="'0003'"/>
								</crm:logistic-order-status-code>
							</xsl:when>
							<xsl:otherwise>
								<!--<xsl:if test="not(//list-parameters/HasFidelity='true')">-->
								<crm:logistic-order-status-code>
									<xsl:value-of select="//work-context/logistic-order-status-code" />
								</crm:logistic-order-status-code>
								<!--</xsl:if>-->
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="//work-context[cancel='true' and cancel-point &lt;= '4' and status-pedido = '2']">
					     <crm:logistic-order-reason><xsl:value-of select="'Cancelamento Rejeitado pela logistica'" /></crm:logistic-order-reason>
					</xsl:if>
					<xsl:if test="//work-context/confirm/status-pedido">
						<xsl:choose>
							<xsl:when test="//work-context/confirm/status-pedido='2'">
								<crm:logistic-order-status-code>
									<xsl:value-of select="'1001'"/>
								</crm:logistic-order-status-code>
								<crm:logistic-order-notes>
									<xsl:value-of select="//work-context/confirm/obs"/>	
								</crm:logistic-order-notes>
								<crm:logistic-order-reason>Cancelamento Rejeitado pela logistica</crm:logistic-order-reason>
							</xsl:when>
						</xsl:choose>
					</xsl:if>
				
					<xsl:if test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId and //work-context/logistic-order-status-code='1001' and not(//work-context[cancel='true'])">
						<crm:logistic-order-id>
							<xsl:value-of select="/ROOT/sca-request/payload/order-item-status/commercial-order/message/Order/OrderNumber" />
						</crm:logistic-order-id>
					</xsl:if>
					
					<xsl:if test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId and //work-context/logistic-order-status-code='1004' and (not(//work-context//cancel='true'))">
						<crm:logistic-expected-delivery-date>
							<xsl:value-of select="//work-context//obs" />
						</crm:logistic-expected-delivery-date>
					</xsl:if>
					
					<xsl:if test="$isFirstNotificationFromDelivery and (@id=$DeliveryAparelhoId and not(//work-context[notification-type='PEN'])) and (//work-context/logistic-order-status-code='1005' or //work-context/logistic-order-status-code='1007') and not(//list-parameters[BeforeFidelity='true'])">
						<crm:logistic-delivery-date>
							<xsl:choose>
								<xsl:when test="//work-context//delivery-date[1]!=''">
									<xsl:call-template name="dataDelivery">
										<xsl:with-param name="dataDev" select="//work-context//delivery-date[1]"></xsl:with-param>
									</xsl:call-template>
								</xsl:when>
								<xsl:when test="//work-context//delivery-date[2]!=''">
									<xsl:call-template name="dataDelivery">
										<xsl:with-param name="dataDev" select="//work-context//delivery-date[2]"></xsl:with-param>
									</xsl:call-template>
								</xsl:when>
							</xsl:choose>
						</crm:logistic-delivery-date>
					</xsl:if>
					
					<xsl:if test="//work-context[logistic-order-status-code>='1001']">
						<xsl:if test="not(//work-context[logistic-order-status-code='1003']) or (//work-context//cancel='true')">
							<xsl:if test="(//work-context[logistic-order-status-code='1007']) or (not(//work-context[(cancel-point='1' or cancel-point >='3')])) or (//work-context[logistic-order-status-code='1006']) or (//work-context[cancel='true'])">
								<xsl:if test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId and((//work-context//obs!='') or (//work-context//delivery-reason/desc!='') or (//work-context//cancel='true'))">
									<crm:logistic-order-notes>
										<xsl:choose>
											<xsl:when test="(//work-context[cancel='true']) and (//work-context[obs-can!=''])">
												<xsl:value-of select="//work-context//obs-can"/>
											</xsl:when>
											<xsl:when test="(//work-context[cancel='true'])">
												<xsl:value-of select="'Pedido Cancelado'"/>
											</xsl:when>
											<xsl:when test="(//work-context[logistic-order-status-code='1007'])">
												<xsl:call-template name="transCod">
													<xsl:with-param name="codDesc" select="//work-context//delivery-reason/code"></xsl:with-param>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="//work-context//obs"/>
											</xsl:otherwise>
										</xsl:choose>
									</crm:logistic-order-notes>
								</xsl:if>
							</xsl:if>
							
							
							<xsl:if test="$isFirstNotificationFromDelivery and @id=$DeliveryAparelhoId and((not(//work-context[cancel-point='2' and is-vendita='YES'])) and ((not(//work-context[cancel-point='1' or cancel-point >='3'])) or (//work-context[logistic-order-status-code='1006']) or (//work-context[cancel='true'] and (//work-context//obs-can!=''))))">
								<crm:logistic-order-reason>
									<xsl:choose>
										<xsl:when test="(//work-context[cancel='true'])">Pedido Cancelado via Logistica</xsl:when>
										<xsl:when test="//work-context//reason = '1'" >Inconsistente/Falta de material</xsl:when>
										<xsl:when test="//work-context//reason = '2'" >Inconsistente/Divergencia na ordem de venda</xsl:when>
										<xsl:when test="//work-context//reason = '3'" >Inconsistente/Nota fiscal eletronica inconsistente</xsl:when>
										<xsl:when test="//work-context//reason = '4'" >Inconsistente/Sinistro no ponto de triangulacao</xsl:when>
										<xsl:when test="//work-context//reason = '11'">Inconsistente/TIM Chip inconsistente em relacao ao aparelho</xsl:when>
										<xsl:when test="//work-context//reason = '12'">Inconsistente/Elemento PEP Excedido</xsl:when>
									</xsl:choose>
									<xsl:value-of select="//work-context//cancel/reason" />
								</crm:logistic-order-reason>
							</xsl:if>
						</xsl:if>
					</xsl:if>
				</crm:order-item>
				
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:variable name="getTypeOfTariff">
		<xsl:choose>
			<xsl:when test="//OrderLineItem[ProductCategory='PLANO' and ActionCode='Nova']">
				<xsl:value-of select="//OrderLineItem[ProductCategory='PLANO' and ActionCode='Nova']/ProductType" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="//OrderLineItem[ProductCategory='PLANO']/ProductType" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="msisdn">
		<xsl:choose>
			<xsl:when
				test="//OrderLineItem[ProductCategory='ACESSO' and ActionCode='Nova'] and
				//OrderLineItem[ProductCategory='PLANO' and ActionCode='Nova']">
				<xsl:value-of select="//OrderLineItem[ProductCategory='TECNICO' and ProductType='NOVO' and ProductSubType='NUMERO']/ListOfOrderItemXA/OrderItemXA[Name='DDD']/Value"/>
				<xsl:value-of select="//OrderLineItem[ProductCategory='TECNICO' and ProductType='NOVO' and ProductSubType='NUMERO']/ListOfOrderItemXA/OrderItemXA[Name='MSISDN']/Value"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when
						test="//OrderLineItem[ProductCategory='ACESSO']/MSISDN">
						<xsl:value-of select="//OrderLineItem[ProductCategory='ACESSO']/MSISDN"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="//OrderLineItem[ProductCategory='TECNICO' and ProductSubType='NUMERO']/ListOfOrderItemXA/OrderItemXA[Name='DDD']/Value"/>
						<xsl:value-of select="//OrderLineItem[ProductCategory='TECNICO' and ProductSubType='NUMERO']/ListOfOrderItemXA/OrderItemXA[Name='MSISDN']/Value"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:template name="getExternalIntegration">
		<xsl:choose>
			<xsl:when test="$getTypeOfTariff = 'CONTROLE'">
				<xsl:choose>
					<xsl:when test="//work-context/cc-link/register-code != ''">
						<xsl:value-of select="//work-context/cc-link/register-code"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="//OrderLineItem[ProductCategory='ACESSO']/AssetExternalIntegrationId"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="//OrderLineItem[ProductCategory='COMPARTILHAMENTO_DE_DADOS' and ProductType='COMPARTILHAMENTO_DE_DADOS']">
				<xsl:value-of select="//OrderLineItem[ProductCategory='COMPARTILHAMENTO_DE_DADOS' and ProductType='COMPARTILHAMENTO_DE_DADOS']/AssetExternalIntegrationId"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="//work-context/ownership-user-data != ''">
						<xsl:value-of select="//work-context/ownership-user-data"/>
					</xsl:when>
					<xsl:when test="(//work-context/user-data) and not(//work-context[user-data = 'Port-inAdd' or user-data = 'Port-inConfirmation' or user-data = 'Port-inCanceled'])">
						<xsl:value-of select="//work-context/user-data"/>
					</xsl:when>
					<xsl:otherwise>					
						<xsl:choose>					
							<xsl:when test="(//work-context/contract/id) and not(//work-context/contract[id=''])">
								<xsl:value-of select="//work-context/contract/id" />							
							</xsl:when>
							<xsl:when test="//work-context/new-contract-id !='' and (//work-context/user-data= 'Port-inConfirmation' or //work-context/user-data= 'Port-inAdd' or //work-context/user-data = 'Port-inCanceled')">
								<xsl:value-of select="//work-context/new-contract-id" />							
							</xsl:when>
							<xsl:otherwise>		
								<xsl:value-of select="//OrderLineItem[ProductCategory='ACESSO']/AssetExternalIntegrationId"/>
							</xsl:otherwise>
						</xsl:choose>						
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
