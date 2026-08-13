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
-- 发动条件：效果发动方不是当前回合玩家，即仅在对方回合（对方怪兽攻击宣言时）才能发动。
function c43250041.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是本卡发动者（即对手回合），满足则条件通过。
	return tp~=Duel.GetTurnPlayer()
end
-- 发动时选择对象：获取攻击怪兽作为对象，确认其在场且可成为效果对象后将其设置为效果对象，并将该怪兽当前攻击力作为预计回复数值写入操作信息。
function c43250041.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得正在进行攻击宣言的怪兽作为候选对象。
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设置为当前连锁的效果对象（取对象）。
	Duel.SetTargetCard(tg)
	local rec=tg:GetAttack()
	-- 设定本连锁的处理信息：效果分类为回复LP，预计回复值为该怪兽的攻击力（目标玩家为自己），供后续时点/效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果处理：取出对象怪兽，确认其仍与效果关联、表侧表示且可攻击后，无效该攻击，并回复其当前攻击力数值的LP。
function c43250041.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对应的对象怪兽（即发动时选择的那只攻击怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackable() then
		-- 尝试无效该攻击；若无效成功（攻击已被其他效果无效或怪兽不能攻击时返回false）则进入回复处理。
		if Duel.NegateAttack() then
			-- 以效果原因让自己回复对象怪兽当前攻击力数值的基本分。
			Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
		end
	end
end
