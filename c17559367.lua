--ディープ・ダイバー
-- 效果：
-- 这张卡被战斗破坏送去墓地的场合，战斗阶段结束时从卡组选择1张怪兽卡，放在卡组最上面。
function c17559367.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地的场合，战斗阶段结束时从卡组选择1张怪兽卡，放在卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetOperation(c17559367.regop)
	c:RegisterEffect(e1)
end
-- 当此卡被战斗破坏送去墓地时，检查其确实在墓地且破坏原因为战斗，然后为其注册一个战斗阶段结束时的诱发必发效果以进行后续检索。
function c17559367.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) then
		-- 战斗阶段结束时从卡组选择1张怪兽卡，放在卡组最上面。
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
-- 在战斗阶段结束时，玩家从自己卡组选择1张怪兽卡，洗切卡组，将选中的卡放到卡组最上方，并向双方确认卡组最上方的那张卡。
function c17559367.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示消息，提示玩家选择要放置在卡组最上方的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17559367,1))  --"请选择放置在卡组最上方的怪兽卡"
	-- 从己方卡组中选择1张怪兽卡，作为之后放到卡组最上方的对象。
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
	local tc=g:GetFirst()
	if tc then
		-- 洗切己方卡组，以防止玩家在选牌时看到卡组顺序影响公平。
		Duel.ShuffleDeck(tp)
		-- 将选中的怪兽卡移动到己方卡组最上方。
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认己方卡组最上方1张卡，即展示刚刚放到卡组顶部的怪兽卡。
		Duel.ConfirmDecktop(tp,1)
	end
end
