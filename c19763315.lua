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
-- 发动时创建影响对方的持续效果，使对方战斗阶段变为2次；若在对方战斗阶段中发动，则记录当前回合数并通过条件跳过本次战斗阶段，从下一次对方战斗阶段开始适用，同时根据发动时机设置对应的重置时机。
function c19763315.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 对方下次的战斗阶段进行2次。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	-- 判断发动时是否处于对方回合且正在进行战斗阶段，若是则说明是在对方战斗阶段中发动，需要使效果从下一次对方战斗阶段才开始适用。
	if Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) then
		-- 将当前回合数记录到效果的Label中，用于后续条件判断以跳过当前战斗阶段。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c19763315.bpcon)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,1)
	end
	-- 将“对方战斗阶段进行2次”的效果注册给发动玩家，并使其对对方玩家适用。
	Duel.RegisterEffect(e1,tp)
end
-- 定义效果的条件函数：仅当当前回合数与记录的回合数不同时，效果才生效，从而避免效果在当前战斗阶段内立刻适用。
function c19763315.bpcon(e)
	-- 返回当前回合数是否不等于记录回合数的判断结果；为真时表示已经进入下一个回合，效果开始适用。
	return Duel.GetTurnCount()~=e:GetLabel()
end
