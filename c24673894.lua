--チェンジ・デステニー
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。把1只对方怪兽的攻击无效，那只怪兽变成守备表示。那只怪兽只要在场上表侧表示存在，变成不能把表示形式变更。那之后，对方从以下效果选择1个适用。
-- ●自己基本分回复用这张卡的效果把攻击无效的怪兽的攻击力一半的数值。
-- ●给与对方基本分用这张卡的效果把攻击无效的怪兽的攻击力一半数值的伤害。
function c24673894.initial_effect(c)
	-- 创建一张永续魔法卡效果，条件为对方怪兽攻击宣言时发动，目标为攻击怪兽，效果为无效攻击并变守备表示，之后对方选择回复LP或受到伤害
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c24673894.condition)
	e1:SetTarget(c24673894.target)
	e1:SetOperation(c24673894.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：当前回合玩家不是攻击方
function c24673894.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不等于攻击方玩家
	return tp~=Duel.GetTurnPlayer()
end
-- 效果目标：选择攻击怪兽作为目标
function c24673894.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	if chkc then return chkc==tc end
	if chk==0 then return tc:IsLocation(LOCATION_MZONE) and tc:IsAttackPos()
		and tc:IsCanChangePosition() and tc:IsCanBeEffectTarget(e) end
	-- 设置攻击怪兽为效果目标
	Duel.SetTargetCard(tc)
end
-- 效果发动：无效攻击并变为守备表示，使该怪兽不能改变表示形式，然后让对方选择回复LP或受到伤害
function c24673894.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	-- 攻击怪兽存在于场上且攻击宣言有效，且可以改变表示形式
	if tc:IsRelateToEffect(e) and Duel.NegateAttack() and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		-- 效果原文：那只怪兽只要在场上表侧表示存在，变成不能把表示形式变更
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		local val=tc:GetAttack()/2
		-- 让对方选择回复LP或受到伤害
		local op=Duel.SelectOption(1-tp,aux.Stringid(24673894,0),aux.Stringid(24673894,1))  --"自己基本分回复/给予对方伤害"
		-- 对方选择回复LP，回复攻击怪兽攻击力一半的数值
		if op==0 then Duel.Recover(1-tp,math.ceil(val),REASON_EFFECT)
		-- 对方选择受到伤害，受到攻击怪兽攻击力一半的数值
		else Duel.Damage(tp,math.floor(val),REASON_EFFECT) end
	end
end
