--D・クロックン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：这张卡放置的变形斗士指示物每有1个，这张卡的攻击力上升500。
-- ●守备表示：1回合1次，可以给这张卡放置1个变形斗士指示物。可以把这张卡解放，给与对方基本分这张卡放置的变形斗士指示物数量×1000的数值的伤害。
function c91607976.initial_effect(c)
	c:EnableCounterPermit(0x8)
	-- ●攻击表示：这张卡放置的变形斗士指示物每有1个，这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c91607976.cona)
	e1:SetValue(c91607976.vala)
	c:RegisterEffect(e1)
	-- ●守备表示：1回合1次，可以给这张卡放置1个变形斗士指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91607976,0))  --"放置1个变形斗士指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c91607976.cond1)
	e2:SetTarget(c91607976.tgd1)
	e2:SetOperation(c91607976.opd1)
	c:RegisterEffect(e2)
	-- ●守备表示：可以把这张卡解放，给予对方基本分这张卡放置的变形斗士指示物数量×1000的数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91607976,1))  --"对方基本分这张卡放置的变形斗士指示物数量×1000的数值的伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c91607976.cond2)
	e3:SetCost(c91607976.costd2)
	e3:SetTarget(c91607976.tgd2)
	e3:SetOperation(c91607976.opd2)
	c:RegisterEffect(e3)
end
c91607976.mentioned_counter={
	[0x8]=true,
}
-- 攻击表示效果适用条件：此卡为攻击表示
function c91607976.cona(e)
	return e:GetHandler():IsAttackPos()
end
-- 攻击力上升数值计算：自身放置的变形斗士指示物数量×500
function c91607976.vala(e,c)
	return c:GetCounter(0x8)*500
end
-- 放置指示物效果发动条件：此卡效果未被无效且为守备表示
function c91607976.cond1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 放置指示物效果发动准备：检查自身能否放置变形斗士指示物
function c91607976.tgd1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x8,1) end
end
-- 放置指示物效果处理：给自身放置1个变形斗士指示物
function c91607976.opd1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x8,1)
	end
end
-- 伤害效果发动条件：此卡效果未被无效且为守备表示
function c91607976.cond2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 伤害效果发动Cost：记录指示物伤害数值并将自身解放
function c91607976.costd2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	e:SetLabel(e:GetHandler():GetCounter(0x8)*1000)
	-- 将自身解放作为发动Cost
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 伤害效果发动准备：设置给予对方伤害的操作信息与参数
function c91607976.tgd2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x8)>0 end
	-- 设置伤害目标玩家：对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值：指示物数量×1000
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁操作信息：给予对方指示物数量×1000的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 伤害效果处理：给予对方设定的伤害数值
function c91607976.opd2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标玩家与伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成卡片效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
