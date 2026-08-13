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
-- 筛选作为特殊召唤代价的怪兽：等级5以上且光属性，用于从手卡丢弃。
function c27407330.spfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 特殊召唤规则效果的条件判定：自己场上有空余怪兽区域，且手牌存在1只5星以上光属性怪兽（除自身）时才能以此方式特殊召唤。
function c27407330.spcon(e,c)
	if c==nil then return true end
	-- 判定自己场上是否存在可用的主要怪兽区域空格，确保特殊召唤后有位置。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查手牌中是否存在1只5星以上光属性怪兽（排除自身）作为丢弃代价。
		Duel.IsExistingMatchingCard(c27407330.spfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end
-- 特殊召唤手续的目标处理：从手牌选择1只5星以上光属性怪兽作为丢弃代价，并存入LabelObject，选择成功则返回true。
function c27407330.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手牌中所有满足5星以上光属性条件的怪兽集合（排除自身），供玩家选择。
	local g=Duel.GetMatchingGroup(c27407330.spfilter,tp,LOCATION_HAND,0,c)
	-- 向玩家显示选择提示，要求选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的操作处理：将已选择的怪兽丢弃，完成该卡从手卡的特殊召唤。
function c27407330.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将作为代价的怪兽送去墓地，原因标记为丢弃并同时作为特殊召唤手续。
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_SPSUMMON)
end
-- 筛选第二个效果的丢弃代价：手牌中光属性且可以丢弃的怪兽。
function c27407330.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsDiscardable()
end
-- 第二个效果的代价处理：检查并执行丢弃1只光属性手牌作为发动代价。
function c27407330.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否存在1只光属性且可丢弃的怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27407330.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家从手牌选择1只光属性怪兽丢弃，作为发动效果的代价。
	Duel.DiscardHand(tp,c27407330.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选卡组中可以除外的光属性怪兽，作为除外效果的对象候选。
function c27407330.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemove()
end
-- 目标判定阶段：确认卡组存在可除外的光属性怪兽后，设置本次操作将除外1张卡组中的光属性怪兽。
function c27407330.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在1只光属性且能被除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c27407330.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：除外卡组中1只光属性怪兽，对象在效果处理时选择，因此目标暂设为nil。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：从卡组选择1只光属性怪兽，将其表侧除外。
function c27407330.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示，要求从卡组选择要除外的光属性怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从卡组中实际选择1只满足条件的光属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c27407330.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以表侧表示从游戏中除外，完成除外处理。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
