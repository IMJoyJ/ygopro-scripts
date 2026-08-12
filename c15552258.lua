--ハーフorストップ
-- 效果：
-- 对方回合的战斗阶段时才能发动。对方从以下效果选择1个适用。
-- ●直到战斗阶段结束时，自己场上存在的全部怪兽的攻击力变成一半数值。
-- ●把战斗阶段结束。
function c15552258.initial_effect(c)
	-- 效果发动条件设置为自由时点，且提示在战斗阶段开始时发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCondition(c15552258.condition)
	e1:SetOperation(c15552258.activate)
	c:RegisterEffect(e1)
end
-- 判断是否为对方回合且当前处于战斗阶段
function c15552258.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不等于发动玩家，并且当前阶段为战斗阶段开始到战斗阶段结束之间
	return tp~=Duel.GetTurnPlayer() and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 效果处理函数，根据场上怪兽数量选择效果选项
function c15552258.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方场上所有正面表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local opt=0
	if g:GetCount()==0 then
		-- 若场上无怪兽，则对方选择“把战斗阶段结束”选项
		opt=Duel.SelectOption(1-tp,aux.Stringid(15552258,1))+1  --"把战斗阶段结束"
	else
		-- 若场上存在怪兽，则对方选择“攻击力变成一半数值”或“把战斗阶段结束”选项
		opt=Duel.SelectOption(1-tp,aux.Stringid(15552258,0),aux.Stringid(15552258,1))  --"攻击力变成一半数值/把战斗阶段结束"
	end
	if opt==1 then
		-- 跳过对方的战斗阶段结束步骤
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		return
	end
	local tc=g:GetFirst()
	while tc do
		-- 将目标怪兽的攻击力变为原来的一半数值
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
