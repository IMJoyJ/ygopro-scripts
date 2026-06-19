--闇紅の魔導師
-- 效果：
-- 这张卡召唤成功时，这张卡放置2个魔力指示物。只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。这张卡放置的魔力指示物每有1个，这张卡的攻击力上升300。1回合1次，可以把这张卡放置的2个魔力指示物取除，对方手卡随机丢弃1张。
function c45462639.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 这张卡召唤成功时，这张卡放置2个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45462639,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c45462639.addct)
	e1:SetOperation(c45462639.addc)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 设置操作为记录连锁发生时这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 只要这张卡在场上表侧表示存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c45462639.acop)
	c:RegisterEffect(e2)
	-- 这张卡放置的魔力指示物每有1个，这张卡的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(c45462639.attackup)
	c:RegisterEffect(e3)
	-- 1回合1次，可以把这张卡放置的2个魔力指示物取除，对方手卡随机丢弃1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(45462639,1))
	e4:SetCategory(CATEGORY_HANDES_OPPO)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c45462639.descost)
	e4:SetTarget(c45462639.destarg)
	e4:SetOperation(c45462639.desop)
	c:RegisterEffect(e4)
end
-- 召唤成功时放置指示物效果的靶向与检测函数，设置放置指示物的操作信息
function c45462639.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置在自身放置2个魔力指示物的操作信息
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1)
end
-- 召唤成功时放置指示物效果的处理函数，若自身在场则放置2个魔力指示物
function c45462639.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 魔法卡发动连锁处理完毕时的处理函数，若此卡在场则给此卡放置1个魔力指示物
function c45462639.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 攻击力上升值的计算函数，返回自身魔力指示物数量乘以300的数值
function c45462639.attackup(e,c)
	return c:GetCounter(0x1)*300
end
-- 丢弃手牌效果的代价函数，取除自身2个魔力指示物
function c45462639.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,2,REASON_COST)
end
-- 丢弃手牌效果的目标过滤与检测函数，确认对方手牌数并设置丢弃手牌的操作信息
function c45462639.destarg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检测对方手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,1)
end
-- 丢弃手牌效果的处理函数，随机选择对方1张手牌并以效果丢弃的方式送去墓地
function c45462639.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌中的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将选中的卡片作为效果丢弃送去墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
