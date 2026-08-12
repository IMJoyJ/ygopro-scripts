--No.19 フリーザードン
-- 效果：
-- 5星怪兽×2
-- ①：1回合1次，自己的超量怪兽把超量素材取除来让效果发动的场合，取除的1个超量素材可以从这张卡取除。
function c55067058.initial_effect(c)
	-- 添加以2只5星怪兽为素材的超量召唤手续
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己的超量怪兽把超量素材取除来让效果发动的场合，取除的1个超量素材可以从这张卡取除。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55067058,0))  --"是否要使用「No.19 冷冻龙」的效果？"
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c55067058.rcon)
	e1:SetOperation(c55067058.rop)
	c:RegisterEffect(e1)
end
-- 将该卡登记为「No.」怪兽，其「No.」编号为19
aux.xyz_number[55067058]=19
-- 验证代替取除素材的条件：必须是自己超量怪兽为发动效果而支付代价取除素材，且这张卡有超量素材可供取除
function c55067058.rcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and ep==e:GetOwnerPlayer() and re:GetHandler():GetOverlayCount()>=ev-1
end
-- 执行代替操作，从这张卡上取除1个超量素材
function c55067058.rop(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
