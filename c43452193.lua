--異次元トンネル－ミラーゲート－
-- 效果：
-- 自己场上表侧表示存在的名字带有「元素英雄」的怪兽为攻击对象的对方怪兽攻击宣言时才能发动。对方的攻击怪兽和成为攻击对象的自己怪兽交换控制权进行伤害计算。直到这个回合结束阶段时得到控制权交换怪兽的控制权。
function c43452193.initial_effect(c)
	-- 自己场上表侧表示存在的名字带有「元素英雄」的怪兽为攻击对象的对方怪兽攻击宣言时才能发动。对方的攻击怪兽和成为攻击对象的自己怪兽交换控制权进行伤害计算。直到这个回合结束阶段时得到控制权交换怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c43452193.condition)
	e1:SetTarget(c43452193.target)
	e1:SetOperation(c43452193.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：仅在对方回合，攻击对象存在且为表侧表示的名字带有「元素英雄」的怪兽时，本卡才能发动。
function c43452193.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击的怪兽（攻击对象）。
	local at=Duel.GetAttackTarget()
	-- 判定当前为对方回合（攻击者为对方），且存在表侧表示的「元素英雄」攻击对象。
	return Duel.GetTurnPlayer()~=tp and at and at:IsFaceup() and at:IsSetCard(0x3008)
end
-- 发动时的目标选择与合法性判定：确认攻击怪兽和攻击对象均在场且可变更控制权，并且交换后双方场上都有空位，满足则登记相关卡片为效果对象和改变控制权操作信息。
function c43452193.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击宣言的对方怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击的自己怪兽。
	local at=Duel.GetAttackTarget()
	-- 检查攻击怪兽还在场上、允许控制权变更，且原本控制者在攻击怪兽离开后仍有空余怪兽区用于放置被交换过来的怪兽。
	if chk==0 then return a:IsOnField() and a:IsAbleToChangeControler() and Duel.GetMZoneCount(1-tp,a,1-tp,LOCATION_REASON_CONTROL)>0
		-- 检查攻击对象也在场上、允许控制权变更，且自己方在被攻击怪兽离开后仍有空余怪兽区用于放置攻击怪兽。
		and at:IsOnField() and at:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,at,tp,LOCATION_REASON_CONTROL)>0 end
	local g=Group.FromCards(a,at)
	-- 将攻击怪兽和攻击对象设置为当前连锁的效果处理对象。
	Duel.SetTargetCard(g)
	-- 登记本次操作将改变2只怪兽的控制权，供后续连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,2,0,0)
end
-- 效果处理：若攻击怪兽和攻击对象仍与效果关联且攻击怪兽仍可攻击，则交换双方控制权直到结束阶段，并进行伤害计算。
function c43452193.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的对方怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击的自己怪兽。
	local at=Duel.GetAttackTarget()
	if a:IsRelateToEffect(e) and a:IsAttackable() and at:IsRelateToEffect(e) then
		-- 尝试交换攻击怪兽与攻击对象的控制权，并设定该控制权变更在结束阶段时重置；交换成功则继续。
		if Duel.SwapControl(a,at,RESET_PHASE+PHASE_END,1) then
			-- 在交换控制权后，让攻击怪兽与攻击对象强制进行伤害计算。
			Duel.CalculateDamage(a,at)
		end
	end
end
