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
	-- 可以把这张卡解放，给与对方基本分这张卡放置的变形斗士指示物数量×1000的数值的伤害。
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
-- 判断此卡是否处于攻击表示
function c91607976.cona(e)
	return e:GetHandler():IsAttackPos()
end
-- 计算攻击力上升值，数值为这张卡放置的变形斗士指示物数量×500
function c91607976.vala(e,c)
	return c:GetCounter(0x8)*500
end
-- 判断此卡是否未被无效且处于守备表示
function c91607976.cond1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 判断是否可以给这张卡放置1个变形斗士指示物
function c91607976.tgd1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x8,1) end
end
-- 给这张卡放置1个变形斗士指示物
function c91607976.opd1(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x8,1)
	end
end
-- 判断此卡是否未被无效且处于守备表示
function c91607976.cond2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 判断此卡是否可以解放，记录伤害数值并解放此卡作为发动代价
function c91607976.costd2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	e:SetLabel(e:GetHandler():GetCounter(0x8)*1000)
	-- 解放此卡作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 判断此卡是否有指示物，并设置伤害效果的对象玩家、伤害数值以及操作信息
function c91607976.tgd2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x8)>0 end
	-- 设置对方玩家为伤害效果的对象
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值为之前记录的指示物数量×1000的值
	Duel.SetTargetParam(e:GetLabel())
	-- 设置连锁的操作信息为给与对方玩家对应数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
end
-- 获取伤害对象和数值，并给与对方玩家伤害
function c91607976.opd2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的伤害对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
