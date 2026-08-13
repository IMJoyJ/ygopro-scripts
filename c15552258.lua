--ハーフorストップ
-- 效果：
-- 对方回合的战斗阶段时才能发动。对方从以下效果选择1个适用。
-- ●直到战斗阶段结束时，自己场上存在的全部怪兽的攻击力变成一半数值。
-- ●把战斗阶段结束。
function c15552258.initial_effect(c)
	-- 对应效果原文：“对方回合的战斗阶段时才能发动。对方从以下效果选择1个适用。●直到战斗阶段结束时，自己场上存在的全部怪兽的攻击力变成一半数值。●把战斗阶段结束。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCondition(c15552258.condition)
	e1:SetOperation(c15552258.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：仅当是对方回合且当前处于战斗阶段（从战斗阶段开始到战斗阶段结束）时允许发动。
function c15552258.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查发动条件：当前不是回合玩家（即对方回合），且当前阶段处于战斗阶段开始到战斗阶段结束之间。
	return tp~=Duel.GetTurnPlayer() and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 定义效果处理函数：根据对方选择的效果进行处理；若opt为1则跳过战斗阶段，否则将己方场上全部表侧怪兽的攻击力变为一半。
function c15552258.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方（tp方）场上全部表侧表示的怪兽，存为组g。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local opt=0
	if g:GetCount()==0 then
		-- 当自己场上没有表侧怪兽时，只提供“把战斗阶段结束”一个选项，对方选择后opt为1。
		opt=Duel.SelectOption(1-tp,aux.Stringid(15552258,1))+1  --"把战斗阶段结束"
	else
		-- 当自己场上有表侧怪兽时，提供“攻击力变成一半数值”和“把战斗阶段结束”两个选项，选项序号加1后存入opt。
		opt=Duel.SelectOption(1-tp,aux.Stringid(15552258,0),aux.Stringid(15552258,1))  --"攻击力变成一半数值/把战斗阶段结束"
	end
	if opt==1 then
		-- 跳过对方（1-tp）的战斗阶段，使战斗阶段结束（value=1表示同时跳过战斗阶段结束步骤）。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		return
	end
	local tc=g:GetFirst()
	while tc do
		-- 对应效果原文：“●直到战斗阶段结束时，自己场上存在的全部怪兽的攻击力变成一半数值。”
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
