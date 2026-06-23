--ヒーローバリア
-- 效果：
-- 自己场上名字中带有「元素英雄」的怪兽表侧表示存在的场合，对方怪兽的攻击只有1次无效。
function c44676200.initial_effect(c)
	-- 创建一个永续效果，用于在自由时点发动，条件为对方怪兽攻击时无效其攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c44676200.condition)
	e1:SetOperation(c44676200.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在表侧表示的「元素英雄」怪兽
function c44676200.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 效果发动条件，判断当前回合玩家不是自己且满足战斗阶段条件
function c44676200.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是自己且处于可以进行战斗操作的阶段
	return Duel.GetTurnPlayer()~=tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果处理函数，判断是否能立即无效攻击，否则注册一个攻击宣言时触发的效果
function c44676200.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否有怪兽正在攻击且满足无效攻击的条件
	if Duel.GetAttacker() and c44676200.discon(e,tp,eg,ep,ev,re,r,rp) then
		-- 无效当前的攻击
		Duel.NegateAttack()
	else
		-- 创建一个在对方攻击宣言时触发的效果，用于无效攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetCondition(c44676200.discon)
		e1:SetOperation(c44676200.disop)
		-- 将该效果注册给当前玩家，使其在对方攻击宣言时生效
		Duel.RegisterEffect(e1,tp)
	end
end
-- 无效攻击的触发条件，判断自己场上是否存在表侧表示的「元素英雄」怪兽
function c44676200.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「元素英雄」怪兽
	return Duel.IsExistingMatchingCard(c44676200.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 无效攻击时的处理函数，显示发动动画并无效攻击
function c44676200.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示该卡发动的动画提示
	Duel.Hint(HINT_CARD,0,44676200)
	-- 无效当前的攻击
	Duel.NegateAttack()
end
