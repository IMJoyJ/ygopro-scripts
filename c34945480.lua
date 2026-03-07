--外神アザトート
-- 效果：
-- 5星怪兽×3
-- 这张卡也能在自己场上的「外神」超量怪兽上面把这张卡重叠来超量召唤。这张卡不能作为超量召唤的素材。
-- ①：这张卡超量召唤成功的回合，对方不能把怪兽的效果发动。
-- ②：这张卡有融合·同调·超量怪兽全部在作为超量素材的场合，把这张卡1个超量素材取除才能发动。对方场上的卡全部破坏。
function c34945480.initial_effect(c)
	aux.AddXyzProcedure(c,nil,5,3,c34945480.ovfilter,aux.Stringid(34945480,1))  --"是否在自己场上的「外神」超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 效果原文：这张卡不能作为超量召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡超量召唤成功的回合，对方不能把怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c34945480.sumcon)
	e2:SetOperation(c34945480.sumsuc)
	c:RegisterEffect(e2)
	-- 效果原文：②：这张卡有融合·同调·超量怪兽全部在作为超量素材的场合，把这张卡1个超量素材取除才能发动。对方场上的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34945480,0))  --"对方场上的卡全部破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c34945480.condition)
	e3:SetCost(c34945480.cost)
	e3:SetTarget(c34945480.target)
	e3:SetOperation(c34945480.operation)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「外神」超量怪兽（正面表示、属于外神卡组、超量怪兽）
function c34945480.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb6) and c:IsType(TYPE_XYZ)
end
-- 判断此卡是否为超量召唤
function c34945480.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 为对方玩家设置不能发动怪兽效果的永续效果
function c34945480.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：对方场上的卡全部破坏
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(c34945480.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制对方不能发动怪兽效果
function c34945480.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 判断此卡的超量素材是否同时包含融合、同调、超量怪兽
function c34945480.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetOverlayGroup()
	return g:IsExists(Card.IsType,1,nil,TYPE_FUSION) and g:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO)
		and g:IsExists(Card.IsType,1,nil,TYPE_XYZ)
end
-- 检查此卡是否能去除1个超量素材作为发动代价
function c34945480.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置连锁操作信息，确定要破坏的卡
function c34945480.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，确定要破坏的卡数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果
function c34945480.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因破坏这些卡
	Duel.Destroy(g,REASON_EFFECT)
end
