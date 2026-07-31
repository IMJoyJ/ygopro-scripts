--反撃の毒牙
-- 效果：
-- 自己场上表侧表示存在的名字带有「蛇毒」的怪兽受到攻击宣言时才能发动。把1只对方怪兽的攻击无效，战斗阶段结束。那之后，给攻击怪兽放置1个毒指示物。
function c77972406.initial_effect(c)
	-- ①：自己场上的「云魔物」怪兽被选择作为攻击对象时，以1只攻击怪兽为对象才能发动。那次攻击无效，战斗阶段结束。那之后，给那只怪兽放置1个雾指示物。
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
-- 发动条件：攻击目标为自己场上表侧表示的「云魔物」怪兽
function c77972406.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsControler(tp) and tc:IsFaceup() and tc:IsSetCard(0x50)
end
-- 效果发动准备：以攻击怪兽为对象
function c77972406.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取进行攻击的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 设置攻击怪兽为效果的目标卡
	Duel.SetTargetCard(tg)
end
-- 效果处理：无效攻击并结束战斗阶段，给攻击怪兽放置1个雾指示物
function c77972406.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local tc=Duel.GetAttacker()
	-- 确认攻击怪兽仍与效果关联且成功无效其攻击
	if tc:IsRelateToEffect(e) and Duel.NegateAttack() then
		-- 跳过对方战斗阶段的后续步骤（直接结束战斗阶段）
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		-- 连接效果块：分隔无效攻击/结束战斗阶段与放置指示物处理
		Duel.BreakEffect()
		local atk=tc:GetAttack()
		tc:AddCounter(0x1009,1)
		if atk>0 and tc:IsAttack(0) then
			-- 触发自定义事件：通知攻击力降至0的相关效果处理
			Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
		end
	end
end
