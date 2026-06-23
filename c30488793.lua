--反発力
-- 效果：
-- 表侧攻击表示存在的怪兽为攻击对象的怪兽的攻击无效时才能发动。给与对方基本分那2只怪兽的攻击力差的数值的伤害。
function c30488793.initial_effect(c)
	-- 效果设置：反弹力作为发动时效果，造成伤害，触发条件为攻击无效时，以对方玩家为目标，满足条件时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_ATTACK_DISABLED)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c30488793.condition)
	e1:SetTarget(c30488793.target)
	e1:SetOperation(c30488793.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：攻击怪兽和被攻击怪兽都在主要怪兽区且表侧攻击表示。
function c30488793.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取当前攻击对象怪兽
	local t=Duel.GetAttackTarget()
	return a:IsLocation(LOCATION_MZONE) and t and t:IsLocation(LOCATION_MZONE) and t:IsPosition(POS_FACEUP_ATTACK)
end
-- 效果目标：设置伤害对象为对方玩家，伤害值为攻击怪兽与被攻击怪兽的攻击力差，设置攻击怪兽与被攻击怪兽为效果对象。
function c30488793.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取当前攻击对象怪兽
	local t=Duel.GetAttackTarget()
	local g=Group.FromCards(a,t)
	local dam=math.abs(a:GetAttack()-t:GetAttack())
	-- 设置连锁处理的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为攻击力差值
	Duel.SetTargetParam(dam)
	-- 设置连锁处理的目标卡为攻击怪兽与被攻击怪兽
	Duel.SetTargetCard(g)
	-- 设置连锁操作信息为造成伤害效果，目标玩家为对方，伤害值为攻击力差值
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,dam)
end
-- 效果发动：获取连锁中目标卡组，过滤出与效果相关的卡，若数量不足2则返回，若满足条件则计算攻击力差并给予对方基本分伤害。
function c30488793.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标卡组并过滤出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()<2 then return end
	local c1=g:GetFirst()
	local c2=g:GetNext()
	if c1:IsFaceup() and c2:IsFaceup() then
		-- 获取连锁中目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=math.abs(c1:GetAttack()-c2:GetAttack())
		-- 以效果原因对目标玩家造成指定伤害值
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
