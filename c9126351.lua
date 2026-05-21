--鬼ガエル
-- 效果：
-- ①：这张卡可以从手卡把这张卡以外的1只水属性怪兽丢弃，从手卡特殊召唤。
-- ②：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从卡组以及自己场上的表侧表示怪兽之中选1只2星以下的水族·水属性怪兽送去墓地。
-- ③：1回合1次，让自己场上1只怪兽回到持有者手卡才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把「鬼青蛙」以外的1只「青蛙」怪兽召唤。
function c9126351.initial_effect(c)
	-- ①：这张卡可以从手卡把这张卡以外的1只水属性怪兽丢弃，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c9126351.spcon)
	e1:SetTarget(c9126351.sptg)
	e1:SetOperation(c9126351.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从卡组以及自己场上的表侧表示怪兽之中选1只2星以下的水族·水属性怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c9126351.target)
	e2:SetOperation(c9126351.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：1回合1次，让自己场上1只怪兽回到持有者手卡才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把「鬼青蛙」以外的1只「青蛙」怪兽召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c9126351.excost)
	e5:SetTarget(c9126351.extg)
	e5:SetOperation(c9126351.exop)
	c:RegisterEffect(e5)
end
-- 过滤手卡中除自身以外的水属性怪兽
function c9126351.spfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 特殊召唤规则的条件：怪兽区域有空位且手卡有除自身以外的水属性怪兽
function c9126351.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在至少1只除自身以外的水属性怪兽
		and Duel.IsExistingMatchingCard(c9126351.spfilter,tp,LOCATION_HAND,0,1,c)
end
-- 特殊召唤规则的目标：选择手卡1只除自身以外的水属性怪兽丢弃
function c9126351.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中除自身以外的水属性怪兽组
	local g=Duel.GetMatchingGroup(c9126351.spfilter,tp,LOCATION_HAND,0,c)
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作：将选中的手卡怪兽送去墓地
function c9126351.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽作为特殊召唤的消耗丢弃送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON+REASON_DISCARD)
end
-- 过滤卡组或场上表侧表示的2星以下的水族·水属性怪兽
function c9126351.tgfilter(c)
	return c:IsLevelBelow(2) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_AQUA)
		and (c:IsLocation(LOCATION_DECK) or c:IsFaceup()) and c:IsAbleToGrave()
end
-- 送去墓地效果的发动准备与操作信息设置
function c9126351.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9126351.tgfilter,tp,LOCATION_DECK+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息为将卡组或场上的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_MZONE)
end
-- 送去墓地效果的执行：选择并送去墓地
function c9126351.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组或自己场上选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c9126351.tgfilter,tp,LOCATION_DECK+LOCATION_MZONE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 追加召唤效果的Cost：使自己场上1只怪兽回到手卡
function c9126351.excost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否尚未发动过此效果，且场上存在可以回到手卡的怪兽
	if chk==0 then return Duel.GetFlagEffect(tp,9126352)==0 and Duel.IsExistingMatchingCard(Card.IsAbleToHandAsCost,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只可以回到手卡的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHandAsCost,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为Cost送回持有者手卡
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 追加召唤效果的目标：检查玩家是否可以进行通常召唤及追加召唤
function c9126351.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否能够进行通常召唤以及是否可以获得额外的召唤次数
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
end
-- 追加召唤效果的执行：注册追加召唤的效果和次数限制标记
function c9126351.exop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把「鬼青蛙」以外的1只「青蛙」怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(9126351,0))  --"使用「鬼青蛙」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTarget(c9126351.estg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册追加召唤的全局效果
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册本回合已发动过该效果的标记，持续到回合结束
	Duel.RegisterFlagEffect(tp,9126352,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤追加召唤的目标：除「鬼青蛙」以外的「青蛙」怪兽
function c9126351.estg(e,c)
	return c:IsSetCard(0x12) and not c:IsCode(9126351)
end
