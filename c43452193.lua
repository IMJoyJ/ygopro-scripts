--異次元トンネル－ミラーゲート－
-- 效果：
-- 自己场上表侧表示存在的名字带有「元素英雄」的怪兽为攻击对象的对方怪兽攻击宣言时才能发动。对方的攻击怪兽和成为攻击对象的自己怪兽交换控制权进行伤害计算。直到这个回合结束阶段时得到控制权交换怪兽的控制权。
function c43452193.initial_effect(c)
	-- 创建效果，设置为发动时的效果，触发条件为攻击宣言，效果分类为改变控制权
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c43452193.condition)
	e1:SetTarget(c43452193.target)
	e1:SetOperation(c43452193.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：对方怪兽攻击宣言，且攻击对象是自己场上的表侧表示的「元素英雄」怪兽
function c43452193.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击对象怪兽
	local at=Duel.GetAttackTarget()
	-- 判断攻击对象是否为表侧表示的「元素英雄」怪兽
	return Duel.GetTurnPlayer()~=tp and at and at:IsFaceup() and at:IsSetCard(0x3008)
end
-- 设置效果的目标，检查攻击怪兽和攻击对象怪兽是否满足控制权交换的条件
function c43452193.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击对象怪兽
	local at=Duel.GetAttackTarget()
	-- 判断攻击怪兽是否在场且可以改变控制权，且对方怪兽区有足够空间
	if chk==0 then return a:IsOnField() and a:IsAbleToChangeControler() and Duel.GetMZoneCount(1-tp,a,1-tp,LOCATION_REASON_CONTROL)>0
		-- 判断攻击对象怪兽是否在场且可以改变控制权，且己方怪兽区有足够空间
		and at:IsOnField() and at:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,at,tp,LOCATION_REASON_CONTROL)>0 end
	local g=Group.FromCards(a,at)
	-- 设置连锁处理的目标卡片为攻击怪兽和攻击对象怪兽
	Duel.SetTargetCard(g)
	-- 设置操作信息，表示本次效果将改变控制权，涉及2张卡
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,2,0,0)
end
-- 效果处理函数，执行控制权交换和伤害计算
function c43452193.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取攻击对象怪兽
	local at=Duel.GetAttackTarget()
	if a:IsRelateToEffect(e) and a:IsAttackable() and at:IsRelateToEffect(e) then
		-- 交换攻击怪兽和攻击对象怪兽的控制权，直到结束阶段重置
		if Duel.SwapControl(a,at,RESET_PHASE+PHASE_END,1) then
			-- 进行攻击伤害计算
			Duel.CalculateDamage(a,at)
		end
	end
end
