--拮抗勝負
-- 效果：
-- 自己场上没有卡存在的场合，这张卡的发动从手卡也能用。
-- ①：对方场上的卡数量比自己场上的卡多的场合，自己·对方的战斗阶段结束时才能发动。直到变成和自己场上的卡数量相同为止，对方必须选自身场上的卡里侧表示除外。
function c15693423.initial_effect(c)
	-- 创建陷阱卡效果，设置为发动时点，效果分类为除外，触发条件为战斗阶段结束时点，效果处理函数为activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_END)
	e1:SetCondition(c15693423.condition)
	e1:SetTarget(c15693423.target)
	e1:SetOperation(c15693423.activate)
	c:RegisterEffect(e1)
	-- 设置陷阱卡可以从手牌发动的效果，条件为己方场上没有卡存在
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15693423,0))  --"适用「颉颃胜负」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c15693423.handcon)
	c:RegisterEffect(e2)
end
-- 效果发动时点为战斗阶段
function c15693423.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为战斗阶段
	return Duel.GetCurrentPhase()==PHASE_BATTLE
end
-- 设置效果的发动条件，判断对方场上的卡数量是否比己方多，且己方可以除外对方的卡
function c15693423.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方场上的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 计算己方场上的卡数量与对方场上的卡数量的差值
	local ct=g:GetCount()-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ct=ct-1 end
	-- 判断对方是否可以除外卡
	if chk==0 then return Duel.IsPlayerCanRemove(1-tp)
		and ct>0 and g:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE) end
	-- 设置效果发动时的操作信息，指定要除外的卡数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
end
-- 效果发动时执行的操作，判断对方是否可以除外卡，然后选择并除外对方场上的卡
function c15693423.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方是否可以除外卡，若不可以则不执行效果
	if not Duel.IsPlayerCanRemove(1-tp) then return end
	-- 获取己方场上的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 计算己方场上的卡数量与对方场上的卡数量的差值
	local ct=g:GetCount()-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if ct>0 then
		-- 提示对方选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:FilterSelect(1-tp,Card.IsAbleToRemove,ct,ct,nil,1-tp,POS_FACEDOWN,REASON_RULE)
		-- 将对方选择的卡以里侧表示的形式除外
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,1-tp)
	end
end
-- 手牌发动条件函数，判断己方场上是否没有卡
function c15693423.handcon(e)
	-- 己方场上没有卡存在
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end
