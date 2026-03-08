--ドレインシールド
-- 效果：
-- ①：对方怪兽的攻击宣言时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击无效，自己回复那只怪兽的攻击力数值的基本分。
function c43250041.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，以1只攻击怪兽为对象才能发动。那只攻击怪兽的攻击无效，自己回复那只怪兽的攻击力数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c43250041.condition)
	e1:SetTarget(c43250041.target)
	e1:SetOperation(c43250041.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当前回合玩家不是效果使用者
function c43250041.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是效果使用者
	return tp~=Duel.GetTurnPlayer()
end
-- 效果处理目标：获取攻击怪兽并设置为效果对象
function c43250041.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为效果对象
	Duel.SetTargetCard(tg)
	local rec=tg:GetAttack()
	-- 设置效果操作信息为回复基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果发动时的处理：无效攻击并回复基本分
function c43250041.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackable() then
		-- 无效此次攻击
		if Duel.NegateAttack() then
			-- 以攻击怪兽的攻击力为数值回复基本分
			Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
		end
	end
end
