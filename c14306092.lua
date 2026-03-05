--牙鮫帝シャーク・カイゼル
-- 效果：
-- 3星怪兽×3只以上（最多5只）
-- 1回合1次，把这张卡1个超量素材取除才能发动。给这张卡放置1个鲨指示物。此外，这张卡进行战斗的伤害步骤内，这张卡的攻击力上升这张卡放置的鲨指示物数量×1000的数值。
function c14306092.initial_effect(c)
	c:EnableCounterPermit(0x2e)
	-- 添加XYZ召唤手续，要求使用3星怪兽3只以上（最多5只）进行叠放
	aux.AddXyzProcedure(c,nil,3,3,nil,nil,5)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。给这张卡放置1个鲨指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14306092,0))  --"放置指示物"
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c14306092.ctcost)
	e1:SetTarget(c14306092.cttg)
	e1:SetOperation(c14306092.ctop)
	c:RegisterEffect(e1)
	-- 此外，这张卡进行战斗的伤害步骤内，这张卡的攻击力上升这张卡放置的鲨指示物数量×1000的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(c14306092.atkcon)
	e2:SetValue(c14306092.atkval)
	c:RegisterEffect(e2)
end
-- 检查是否可以移除1个超量素材作为发动cost
function c14306092.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检查是否可以放置1个鲨指示物
function c14306092.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x2e,1) end
end
-- 将1个鲨指示物放置到自己身上
function c14306092.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x2e,1)
	end
end
-- 判断是否处于伤害步骤内且自己为攻击或被攻击怪兽
function c14306092.atkcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 若当前阶段为伤害步骤或伤害计算阶段，且自己为攻击怪兽或被攻击怪兽，则满足条件
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end
-- 计算攻击力上升值，为鲨指示物数量乘以1000
function c14306092.atkval(e,c)
	return c:GetCounter(0x2e)*1000
end
