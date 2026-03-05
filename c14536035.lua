--ダーク・グレファー
-- 效果：
-- ①：这张卡可以从手卡丢弃1只5星以上的暗属性怪兽，从手卡特殊召唤。
-- ②：1回合1次，从手卡丢弃1只暗属性怪兽才能发动。从卡组把1只暗属性怪兽送去墓地。
function c14536035.initial_effect(c)
	-- 效果原文：①：这张卡可以从手卡丢弃1只5星以上的暗属性怪兽，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14536035,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14536035.spcon)
	e1:SetTarget(c14536035.sptg)
	e1:SetOperation(c14536035.spop)
	c:RegisterEffect(e1)
	-- 效果原文：②：1回合1次，从手卡丢弃1只暗属性怪兽才能发动。从卡组把1只暗属性怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14536035,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c14536035.sgcost)
	e2:SetTarget(c14536035.sgtg)
	e2:SetOperation(c14536035.sgop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索满足5星以上且为暗属性的怪兽
function c14536035.spfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 特殊召唤的发动条件函数
function c14536035.spcon(e,c)
	if c==nil then return true end
	-- 判断玩家场上是否有可用怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 判断玩家手卡是否存在满足条件的怪兽
		Duel.IsExistingMatchingCard(c14536035.spfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end
-- 特殊召唤的选择处理函数
function c14536035.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c14536035.spfilter,tp,LOCATION_HAND,0,c)
	-- 向玩家发送选择丢弃卡片的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的处理函数
function c14536035.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽送去墓地并视为特殊召唤的代价
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_SPSUMMON)
end
-- 过滤函数：检索可丢弃的暗属性怪兽
function c14536035.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsDiscardable()
end
-- 效果②的发动代价函数
function c14536035.sgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动代价条件
	if chk==0 then return Duel.IsExistingMatchingCard(c14536035.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手卡丢弃1张满足条件的怪兽
	Duel.DiscardHand(tp,c14536035.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：检索可送去墓地的暗属性怪兽
function c14536035.filter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- 效果②的目标设定函数
function c14536035.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c14536035.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要送去墓地的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理函数
function c14536035.sgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择送去墓地怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c14536035.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
