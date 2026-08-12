--不運なリポート
-- 效果：
-- 对方下次的战斗阶段进行2次。
function c19763315.initial_effect(c)
	-- 对方下次的战斗阶段进行2次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c19763315.activate)
	c:RegisterEffect(e1)
end
-- 将效果注册为永续场地方效果，使对方在战斗阶段可以进行2次战斗步骤。
function c19763315.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个影响对方玩家的永续场地方效果，使对方在战斗阶段可以进行2次战斗步骤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	-- 判断当前回合玩家是否为对方且当前阶段是否为战斗阶段开始到战斗阶段结束之间。
	if Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) then
		-- 记录当前回合数，用于后续判断是否为对方的下次战斗阶段。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c19763315.bpcon)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,1)
	end
	-- 将效果注册给对方玩家，使其在指定条件下生效。
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为对方的下次战斗阶段的条件函数。
function c19763315.bpcon(e)
	-- 判断当前回合数是否与记录的回合数不同，用于触发效果。
	return Duel.GetTurnCount()~=e:GetLabel()
end
