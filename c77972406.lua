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
c77972406.mentioned_counter={
	[0x1009]=true,
}
-- 检查发动的条件：被攻击的对象是否是自己控制的表侧表示的「蛇毒」怪兽
function c77972406.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗被攻击的怪兽
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsControler(tp) and tc:IsFaceup() and tc:IsSetCard(0x50)
end
-- 效果的发动目标设定，将攻击怪兽设为效果对象
function c77972406.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取本次战斗发起攻击的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 把当前正在处理的连锁的对象设置成攻击怪兽
	Duel.SetTargetCard(tg)
end
-- 效果处理逻辑，无效攻击并跳过战斗阶段，然后给攻击怪兽放置毒指示物
function c77972406.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 判断攻击怪兽是否与此效果有关联，并且成功将其攻击无效
	if tc:IsRelateToEffect(e) and Duel.NegateAttack() then
		-- 跳过对方的战斗阶段，强制进入主要阶段2或结束阶段
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		-- 中断当前效果的处理，使前后的效果处理不视为同时发生
		Duel.BreakEffect()
		local atk=tc:GetAttack()
		tc:AddCounter(0x1009,1)
		if atk>0 and tc:IsAttack(0) then
			-- 触发一个自定义事件，可能用于配合其他卡片的效果
			Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
		end
	end
end
