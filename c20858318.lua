--必殺！黒蠍コンビネーション
-- 效果：
-- 当自己场上存在表侧表示的「首领 扎鲁格」「黑蝎-拆除陷阱的克里夫」「黑蝎-飞速逃跑的齐克」「黑蝎-强力的高戈」「黑蝎-荆棘的美奈」时这张卡才能发动。这张卡发动的回合，这些怪兽可以对对方进行直接攻击，每只怪兽对对方造成的战斗伤害数值在此时都变成400点。
function c20858318.initial_effect(c)
	-- 记录此卡关联的五张黑蝎怪兽卡号
	aux.AddCodeList(c,76922029,6967870,61587183,48768179,74153887)
	-- 当自己场上存在表侧表示的「首领 扎鲁格」「黑蝎-拆除陷阱的克里夫」「黑蝎-飞速逃跑的齐克」「黑蝎-强力的高戈」「黑蝎-荆棘的美奈」时这张卡才能发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c20858318.con)
	e1:SetTarget(c20858318.tg)
	e1:SetOperation(c20858318.op)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查一张卡是否为表侧表示且卡号为指定值
function c20858318.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 判断是否满足发动条件，即己方场上同时存在五张指定的黑蝎怪兽
function c20858318.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在表侧表示的「首领 扎鲁格」
	return Duel.IsExistingMatchingCard(c20858318.cfilter,tp,LOCATION_MZONE,0,1,nil,76922029)
		-- 检查己方场上是否存在表侧表示的「黑蝎-拆除陷阱的克里夫」
		and Duel.IsExistingMatchingCard(c20858318.cfilter,tp,LOCATION_MZONE,0,1,nil,6967870)
		-- 检查己方场上是否存在表侧表示的「黑蝎-飞速逃跑的齐克」
		and Duel.IsExistingMatchingCard(c20858318.cfilter,tp,LOCATION_MZONE,0,1,nil,61587183)
		-- 检查己方场上是否存在表侧表示的「黑蝎-强力的高戈」
		and Duel.IsExistingMatchingCard(c20858318.cfilter,tp,LOCATION_MZONE,0,1,nil,48768179)
		-- 检查己方场上是否存在表侧表示的「黑蝎-荆棘的美奈」
		and Duel.IsExistingMatchingCard(c20858318.cfilter,tp,LOCATION_MZONE,0,1,nil,74153887)
end
-- 设置发动时的处理函数，将己方场上所有怪兽设为连锁对象
function c20858318.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
	-- 获取己方场上所有怪兽组成卡片组
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 将己方场上所有怪兽设为连锁对象
	Duel.SetTargetCard(g)
end
-- 设置发动效果的处理函数，为符合条件的怪兽注册标志效果并注册直接攻击和战斗伤害变更效果
function c20858318.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被指定的卡片组，并筛选出与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(20858318,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=g:GetNext()
	end
	-- 注册直接攻击效果，使符合条件的怪兽可以进行直接攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c20858318.affected)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将直接攻击效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
	-- 注册战斗伤害变更效果，使这些怪兽对对方造成的战斗伤害变为400点
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c20858318.rdcon)
	e2:SetValue(400)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将战斗伤害变更效果注册给全局环境
	Duel.RegisterEffect(e2,tp)
end
-- 判断目标怪兽是否具有标志效果，用于确定是否可以进行直接攻击
function c20858318.affected(e,c)
	return c:GetFlagEffect(20858318)~=0
end
-- 判断当前攻击怪兽是否具有标志效果且未攻击对方怪兽，用于触发伤害变更效果
function c20858318.rdcon(e)
	-- 判断当前攻击怪兽是否具有标志效果且未攻击对方怪兽
	return Duel.GetAttacker():GetFlagEffect(20858318)~=0 and Duel.GetAttackTarget()==nil
end
