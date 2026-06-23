--ライトレイ グレファー
-- 效果：
-- 这张卡可以从手卡丢弃1只5星以上的光属性怪兽，从手卡特殊召唤。此外，1回合1次，可以通过从手卡丢弃1只光属性怪兽，卡组1只光属性怪兽从游戏中除外。
function c27407330.initial_effect(c)
	-- 这张卡可以从手卡丢弃1只5星以上的光属性怪兽，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c27407330.spcon)
	e1:SetTarget(c27407330.sptg)
	e1:SetOperation(c27407330.spop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，可以通过从手卡丢弃1只光属性怪兽，卡组1只光属性怪兽从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27407330,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c27407330.rmcost)
	e2:SetTarget(c27407330.rmtg)
	e2:SetOperation(c27407330.rmop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在5星以上且为光属性的怪兽
function c27407330.spfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 特殊召唤的发动条件，检查场上是否有空位且手卡存在满足条件的怪兽
function c27407330.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家的场上主怪兽区是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查玩家手卡中是否存在至少1张满足条件的怪兽
		Duel.IsExistingMatchingCard(c27407330.spfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end
-- 设置特殊召唤效果的目标选择逻辑，提示玩家选择要丢弃的怪兽
function c27407330.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的怪兽组（手卡中5星以上且为光属性的怪兽）
	local g=Duel.GetMatchingGroup(c27407330.spfilter,tp,LOCATION_HAND,0,c)
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤效果的处理函数，将选中的怪兽送去墓地
function c27407330.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以丢弃和特殊召唤的理由送去墓地
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_SPSUMMON)
end
-- 过滤函数，用于判断手卡中是否存在光属性且可丢弃的怪兽
function c27407330.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsDiscardable()
end
-- 除外效果的发动费用，丢弃1张光属性可丢弃的怪兽
function c27407330.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手卡中是否存在至少1张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27407330.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从玩家手卡中丢弃1张满足条件的怪兽
	Duel.DiscardHand(tp,c27407330.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于判断卡组中是否存在光属性且可除外的怪兽
function c27407330.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemove()
end
-- 设置除外效果的目标选择逻辑，检查卡组中是否存在满足条件的怪兽
function c27407330.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组中是否存在至少1张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27407330.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示本次效果将除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 除外效果的处理函数，从卡组中选择1张光属性怪兽除外
function c27407330.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组中选择满足条件的怪兽组
	local g=Duel.SelectMatchingCard(tp,c27407330.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以正面表示的形式从游戏中除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
