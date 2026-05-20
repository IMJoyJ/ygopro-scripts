--魂の氷結
-- 效果：
-- 当自己的基本分比对方的基本分少2000以上时这张卡才能发动。略过对方的下一个战斗阶段。
function c57069605.initial_effect(c)
	-- 当自己的基本分比对方的基本分少2000以上时这张卡才能发动。略过对方的下一个战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(c57069605.condition)
	e1:SetTarget(c57069605.target)
	e1:SetOperation(c57069605.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，用于判断是否满足发动卡片的基本分差值要求
function c57069605.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断我方生命值加上2000后是否小于等于对方生命值
	return Duel.GetLP(tp)+2000<=Duel.GetLP(1-tp)
end
-- 定义靶向与合法性检查函数，确保对方当前未处于跳过战斗阶段的状态
function c57069605.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认对方玩家当前没有被施加跳过战斗阶段的效果
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_SKIP_BP) end
end
-- 定义效果处理函数，创建并注册一个跳过对方下一个战斗阶段的全局效果
function c57069605.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 略过对方的下一个战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	-- 判断当前是否正是对方回合的战斗阶段（如果是，则该效果不能在当前回合生效，需顺延至下一个对方回合）
	if Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) then
		-- 将当前回合数保存到效果的Label中，以便后续过滤当前回合
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c57069605.skipcon)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,1)
	end
	-- 向系统注册该全局效果，使其对玩家生效
	Duel.RegisterEffect(e1,tp)
end
-- 定义跳过战斗阶段效果的条件判断函数
function c57069605.skipcon(e)
	-- 判断当前回合数不等于保存的发动回合数，以实现避开当前回合、顺延至下个回合生效
	return Duel.GetTurnCount()~=e:GetLabel()
end
