--ディープ・ダイバー
-- 效果：
-- 这张卡被战斗破坏送去墓地的场合，战斗阶段结束时从卡组选择1张怪兽卡，放在卡组最上面。
function c17559367.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时发动的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetOperation(c17559367.regop)
	c:RegisterEffect(e1)
end
-- 检测是否满足条件并注册后续效果
function c17559367.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) then
		-- 战斗阶段结束时从卡组选择1张怪兽卡，放在卡组最上面
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(17559367,0))  --"检索"
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetCountLimit(1)
		e1:SetOperation(c17559367.operation)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
-- 执行将选中的怪兽卡放置到卡组最上方的操作
function c17559367.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置在卡组最上方的怪兽卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17559367,1))  --"请选择放置在卡组最上方的怪兽卡"
	-- 从卡组中选择一张怪兽卡
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
	local tc=g:GetFirst()
	if tc then
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 将选中的怪兽卡移动到卡组最上方
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认玩家卡组最上方的1张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
