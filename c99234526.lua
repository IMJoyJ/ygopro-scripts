--輝白竜 ワイバースター
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把1只暗属性怪兽除外的场合才能特殊召唤。这个方法的「辉白龙 暴源翼龙」的特殊召唤1回合只能有1次。
-- ①：这张卡从场上送去墓地的场合才能发动。从卡组把1只「暗黑龙 坍缩星蛇」加入手卡。
function c99234526.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 从自己墓地把1只暗属性怪兽除外的场合才能特殊召唤。这个方法的「辉白龙 暴源翼龙」的特殊召唤1回合只能有1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,99234526+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c99234526.spcon)
	e2:SetTarget(c99234526.sptg)
	e2:SetOperation(c99234526.spop)
	c:RegisterEffect(e2)
	-- ①：这张卡从场上送去墓地的场合才能发动。从卡组把1只「暗黑龙 坍缩星蛇」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99234526,0))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c99234526.condition)
	e3:SetTarget(c99234526.target)
	e3:SetOperation(c99234526.operation)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤的除外素材过滤条件：自己墓地中暗属性且可以作为特殊召唤代价除外的怪兽。
function c99234526.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤条件判定：若c为空则返回true；否则检查自己场上是否有空余怪兽区，且自己墓地存在至少1只满足spfilter的暗属性怪兽作为除外代价。
function c99234526.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空位，以确定能否进行特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1张满足spfilter（暗属性且可作为除外代价）的怪兽。
		and Duel.IsExistingMatchingCard(c99234526.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤的素材选择处理：获取自己墓地中所有符合条件的暗属性怪兽，提示玩家选择1张作为除外的代价；若选择成功则记录该卡并返回true，否则返回false。
function c99234526.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足spfilter的暗属性怪兽，组成候选集合供玩家选择。
	local g=Duel.GetMatchingGroup(c99234526.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家发出选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤处理：将特殊召唤时记录下的对象卡（从墓地选择的暗属性怪兽）从墓地除外，作为特殊召唤的代价。
function c99234526.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将之前选择的怪兽以表侧表示除外，除外原因是特殊召唤（REASON_SPSUMMON）。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- ①效果的发动条件：这张卡从场上被送去墓地（即送去墓地前位于场上区域），满足该场合才能发动。
function c99234526.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ①效果发动时的目标处理：在效果发动时检查卡组是否存在可检索的目标，并设置操作信息为从卡组将1张卡加入手牌。
function c99234526.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查（chk==0时）：确认卡组中存在1张满足filter的「暗黑龙 坍缩星蛇」。
	if chk==0 then return Duel.IsExistingMatchingCard(c99234526.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息：将1张卡从卡组加入手牌（CATEGORY_TOHAND），处理时从卡组选1张。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义检索过滤函数：筛选卡组中卡号61901281（「暗黑龙 坍缩星蛇」）且能够加入手牌的卡。
function c99234526.filter(c)
	return c:IsCode(61901281) and c:IsAbleToHand()
end
-- 效果处理：从卡组选择1张「暗黑龙 坍缩星蛇」加入手牌，并让对方确认该卡。
function c99234526.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中筛选出符合条件的「暗黑龙 坍缩星蛇」，并让玩家选择其中1张（不取对象时效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c99234526.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手卡（实际加入自己手卡），原因是效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索后加入手卡的那张卡展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
