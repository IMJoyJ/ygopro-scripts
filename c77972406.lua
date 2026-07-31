--反撃の毒牙
-- 效果：
-- 自己场上表侧表示存在的名字带有「蛇毒」的怪兽受到攻击宣言时才能发动。把1只对方怪兽的攻击无效，战斗阶段结束。那之后，给攻击怪兽放置1个毒指示物。
function c77972406.initial_effect(c)
	-- ①：自己场上有「毒蛇」怪兽被选择为攻击对象时才能发动。对方1只怪兽的攻击无效，战斗阶段结束。那之后，给攻击怪兽放置1个毒指示物。
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
-- 发动条件：自己场上有表侧表示的「毒蛇」怪兽受到攻击
function c77972406.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsControler(tp) and tc:IsFaceup() and tc:IsSetCard(0x50)
end
-- 发动准备：选择攻击怪兽为效果对象
function c77972406.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取攻击怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设为效果对象
	Duel.SetTargetCard(tg)
end
-- 效果处理：攻击无效并结束战斗阶段，给攻击怪兽放置毒指示物
function c77972406.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local tc=Duel.GetAttacker()
	-- 检查攻击怪兽是否仍与效果关联且攻击成功无效
	if tc:IsRelateToEffect(e) and Duel.NegateAttack() then
		-- 强制结束对方的战斗阶段
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		-- 分隔效果处理逻辑
		Duel.BreakEffect()
		local atk=tc:GetAttack()
		tc:AddCounter(0x1009,1)
		if atk>0 and tc:IsAttack(0) then
			-- 若攻击力因放置指示物变为0，触发自定义事件
			Duel.RaiseEvent(tc,EVENT_CUSTOM+54306223,e,0,0,0,0)
		end
	end
end
