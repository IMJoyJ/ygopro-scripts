--チェンジ・デステニー
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。把1只对方怪兽的攻击无效，那只怪兽变成守备表示。那只怪兽只要在场上表侧表示存在，变成不能把表示形式变更。那之后，对方从以下效果选择1个适用。
-- ●自己基本分回复用这张卡的效果把攻击无效的怪兽的攻击力一半的数值。
-- ●给与对方基本分用这张卡的效果把攻击无效的怪兽的攻击力一半数值的伤害。
function c24673894.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c24673894.condition)
	e1:SetTarget(c24673894.target)
	e1:SetOperation(c24673894.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：仅当本卡的发动者不是当前回合玩家（即对方回合的攻击宣言时）才能发动。
function c24673894.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家不是效果发动者，即满足对方回合的条件。
	return tp~=Duel.GetTurnPlayer()
end
-- 目标选择函数：获取攻击宣言的怪兽，校验其位于怪兽区、攻击表示、可变更表示形式且可成为效果对象。
function c24673894.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取正在攻击宣言的怪兽。
	local tc=Duel.GetAttacker()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsLocation(LOCATION_MZONE) and tc:IsAttackPos()
		and tc:IsCanChangePosition() and tc:IsCanBeEffectTarget(e) end
	-- 将攻击宣言的怪兽登记为当前连锁的效果对象。
	Duel.SetTargetCard(tc)
end
-- 效果处理：无效攻击并将攻击怪兽变为表侧守备表示，成功后附加不能变更表示形式的永续效果，再中断处理，由对方选择回复LP或给予伤害。
function c24673894.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取攻击宣言的怪兽。
	local tc=Duel.GetAttacker()
	-- 判断攻击怪兽仍与效果关联、攻击无效成功、且成功变为表侧守备表示，三者均满足才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.NegateAttack() and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		-- 那只怪兽只要在场上表侧表示存在，变成不能把表示形式变更。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 中断当前效果处理，使后续的选择和LP回复/伤害作为独立处理段进行，避免错过时点。
		Duel.BreakEffect()
		local val=tc:GetAttack()/2
		-- 由对方玩家选择要适用的效果：0为回复自己LP，1为给予对方伤害。
		local op=Duel.SelectOption(1-tp,aux.Stringid(24673894,0),aux.Stringid(24673894,1))  --"自己基本分回复/给予对方伤害"
		-- 若对方选择第一个选项，则对方玩家回复攻击无效怪兽当前攻击力一半数值（向上取整）的LP。
		if op==0 then Duel.Recover(1-tp,math.ceil(val),REASON_EFFECT)
		-- 若对方选择第二个选项，则给与对方（即选择方的对手/效果发动者）造成攻击无效怪兽当前攻击力一半数值（向下取整）的伤害。
		else Duel.Damage(tp,math.floor(val),REASON_EFFECT) end
	end
end
