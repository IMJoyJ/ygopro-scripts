--反撃の毒牙
-- 效果：
-- 自己场上表侧表示存在的名字带有「蛇毒」的怪兽受到攻击宣言时才能发动。把1只对方怪兽的攻击无效，战斗阶段结束。那之后，给攻击怪兽放置1个毒指示物。
function c77972406.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「蛇毒」的怪兽受到攻击宣言时才能发动。把1只对方怪兽的攻击无效，战斗阶段结束。那之后，给攻击怪兽放置1个毒指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c77972406.condition)
	e1:SetTarget(c77972406.target)
	e1:SetOperation(c77972406.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查被攻击的怪兽是否为自己场上表侧表示的「蛇毒」怪兽
function c77972406.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击的怪兽（攻击目标）
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsControler(tp) and tc:IsFaceup() and tc:IsSetCard(0x50)
end
-- 效果的目标选择：将发动攻击的怪兽作为效果的对象
function c77972406.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前发动攻击的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将发动攻击的怪兽设为本效果的对象
	Duel.SetTargetCard(tg)
end
-- 效果处理：无效攻击并结束战斗阶段，之后给攻击怪兽放置1个毒指示物
function c77972406.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前发动攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽仍与此效果有关联，则尝试无效该攻击
	if tc:IsRelateToEffect(e) and Duel.NegateAttack() then
		-- 跳过对方战斗阶段的战斗步骤，使其直接进入结束步骤（即结束战斗阶段）
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		-- 中断效果处理，使后续的放置毒指示物处理与无效攻击、结束战斗阶段不视为同时处理
		Duel.BreakEffect()
		local atk=tc:GetAttack()
		tc:AddCounter(0x1009,1)
		if atk>0 and tc:IsAttack(0) then
			-- 触发自定义事件，用于处理怪兽因毒指示物导致攻击力变为0而被破坏的规则
			Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
		end
	end
end
