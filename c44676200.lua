--ヒーローバリア
-- 效果：
-- 自己场上名字中带有「元素英雄」的怪兽表侧表示存在的场合，对方怪兽的攻击只有1次无效。
function c44676200.initial_effect(c)
	-- 自己场上名字中带有「元素英雄」的怪兽表侧表示存在的场合，对方怪兽的攻击只有1次无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c44676200.condition)
	e1:SetOperation(c44676200.operation)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：检查怪兽是否为表侧表示且卡名含有「元素英雄」（字段0x3008），用于判断自己场上是否存在符合条件的怪兽。
function c44676200.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008)
end
-- 发动条件函数：仅在对方回合且处于（或可进入）战斗阶段时才能发动本卡。
function c44676200.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“当前不是自己的回合（即对方回合）”且“处于/可进入战斗阶段”的判定结果，作为发动条件是否成立。
	return Duel.GetTurnPlayer()~=tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果处理函数：若当前已有攻击宣言的怪兽且我方场上有表侧元素英雄，则直接无效该次攻击；否则设置一个在攻击宣言时若条件满足则无效攻击一次的持续效果（回合结束重置，限1次）。
function c44676200.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否存在攻击宣言的怪兽（Duel.GetAttacker()非空）且我方场上有表侧元素英雄（discon成立），若两者皆满足则进入直接无效攻击的分支。
	if Duel.GetAttacker() and c44676200.discon(e,tp,eg,ep,ev,re,r,rp) then
		-- 无效当前这次攻击宣言。
		Duel.NegateAttack()
	else
		-- 对方怪兽的攻击只有1次无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetCondition(c44676200.discon)
		e1:SetOperation(c44676200.disop)
		-- 将创建的持续效果e1注册给当前玩家tp，使该效果在场上持续到结束阶段，用于在后续攻击宣言时发动。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 持续效果的发动条件函数：检查我方场上是否存在表侧表示且含有「元素英雄」的怪兽，若存在则允许发动无效攻击效果。
function c44676200.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回“我方怪兽区（LOCATION_MZONE）存在至少1张表侧表示且字段为0x3008的怪兽”的判定结果。
	return Duel.IsExistingMatchingCard(c44676200.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 持续效果的处理函数：先展示本卡发动提示，再无效当前的攻击宣言。
function c44676200.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方显示卡号44676200的卡片动画提示，表明是「英雄障壁」的效果在无效攻击。
	Duel.Hint(HINT_CARD,0,44676200)
	-- 无效触发此效果时的攻击宣言。
	Duel.NegateAttack()
end
