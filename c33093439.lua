--サイバー・エルタニン
-- 效果：
-- 这张卡不能通常召唤。从自己墓地以及自己场上的表侧表示怪兽之中把机械族·光属性怪兽全部除外的场合才能特殊召唤。
-- ①：这张卡的攻击力·守备力变成因为这张卡特殊召唤而除外的怪兽数量×500。
-- ②：这张卡特殊召唤成功的场合发动。这张卡以外的场上的表侧表示怪兽全部送去墓地。
function c33093439.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为无效，即不能通常召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 从自己墓地以及自己场上的表侧表示怪兽之中把机械族·光属性怪兽全部除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c33093439.spcon)
	e2:SetOperation(c33093439.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的场合发动。这张卡以外的场上的表侧表示怪兽全部送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33093439,0))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c33093439.target)
	e3:SetOperation(c33093439.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为满足条件的机械族·光属性怪兽（可除外）。
function c33093439.cfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
		and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
-- 判断特殊召唤条件是否满足：场上或墓地是否存在满足条件的怪兽。
function c33093439.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断场上是否存在满足条件的怪兽。
	return Duel.IsExistingMatchingCard(c33093439.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断墓地是否存在满足条件的怪兽且场上存在空位。
		or (Duel.IsExistingMatchingCard(c33093439.cfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
-- 特殊召唤时执行的操作：检索满足条件的怪兽并除外，然后设置攻击力和守备力。
function c33093439.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取满足条件的怪兽组（场上+墓地）。
	local g=Duel.GetMatchingGroup(c33093439.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 将满足条件的怪兽除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	-- 设置自身攻击力为除外怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetReset(RESET_EVENT+0xff0000)
	e1:SetValue(g:GetCount()*500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
end
-- 设置效果处理时的目标为场上所有表侧表示怪兽。
function c33093439.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置操作信息为将场上所有表侧表示怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 发动效果时执行的操作：将场上所有表侧表示怪兽（除自身外）送去墓地。
function c33093439.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有表侧表示怪兽（除自身外）。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将目标怪兽送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
