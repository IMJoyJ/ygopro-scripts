--拮抗勝負
-- 效果：
-- 自己场上没有卡存在的场合，这张卡的发动从手卡也能用。
-- ①：对方场上的卡数量比自己场上的卡多的场合，自己·对方的战斗阶段结束时才能发动。直到变成和自己场上的卡数量相同为止，对方必须选自身场上的卡里侧表示除外。
function c15693423.initial_effect(c)
	-- ①：对方场上的卡数量比自己场上的卡多的场合，自己·对方的战斗阶段结束时才能发动。直到变成和自己场上的卡数量相同为止，对方必须选自身场上的卡里侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_END)
	e1:SetCondition(c15693423.condition)
	e1:SetTarget(c15693423.target)
	e1:SetOperation(c15693423.activate)
	c:RegisterEffect(e1)
	-- 自己场上没有卡存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15693423,0))  --"适用「颉颃胜负」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c15693423.handcon)
	c:RegisterEffect(e2)
end
-- 发动条件判定函数：要求当前阶段必须为战斗阶段，配合提示时点实现在战斗阶段结束时发动。
function c15693423.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为战斗阶段的判定结果，作为效果发动条件之一。
	return Duel.GetCurrentPhase()==PHASE_BATTLE
end
-- 发动时的处理函数：获取对方场上卡片并计算与己方场上卡片数量之差（若从手卡发动则再减去本卡自身），同时确认对方玩家可被除外且对方场上有可里侧表示除外的卡，以判定效果可否发动。
function c15693423.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上（LOCATION_ONFIELD）全部卡片，作为可能被除外的对象集合。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 计算需要除外的数量：对方场上卡片数减去己方场上卡片数，得到差值ct。
	local ct=g:GetCount()-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ct=ct-1 end
	-- 发动合法性检查：确认对方玩家（1-tp）是否能够被除外（即是否允许除外其卡片），作为能否发动的条件之一。
	if chk==0 then return Duel.IsPlayerCanRemove(1-tp)
		and ct>0 and g:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE) end
	-- 设置操作信息，声明本连锁效果涉及除外对方场上卡片g、数量为ct，供其他卡效果连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
end
-- 效果处理时的操作：若对方玩家仍可被除外，重新获取对方场上卡片并计算差值ct；若ct>0，则令对方玩家从自身场上选择ct张卡，以里侧表示除外。
function c15693423.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次检查对方玩家是否可以被除外，若不能则直接终止效果处理。
	if not Duel.IsPlayerCanRemove(1-tp) then return end
	-- 效果处理时重新获取对方场上全部卡片，作为当前可选择除外的对象集合。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 效果处理时重新计算需要除外的数量，即对方场上卡片数与己方场上卡片数的差值。
	local ct=g:GetCount()-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if ct>0 then
		-- 向对方玩家发送“请选择要除外的卡”的选择提示信息，用于卡片选择界面的显示。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:FilterSelect(1-tp,Card.IsAbleToRemove,ct,ct,nil,1-tp,POS_FACEDOWN,REASON_RULE)
		-- 将对方选择的卡片sg以里侧表示除外，执行实际除外操作。
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,1-tp)
	end
end
-- 手卡发动条件判定函数：该效果发动者场上没有卡片时，允许这张陷阱卡从手卡发动。
function c15693423.handcon(e)
	-- 返回该效果发动者自己场上卡片数是否为0，若为0则满足从手卡发动的条件。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)==0
end
