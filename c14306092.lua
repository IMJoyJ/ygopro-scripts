--牙鮫帝シャーク・カイゼル
-- 效果：
-- 3星怪兽×3只以上（最多5只）
-- 1回合1次，把这张卡1个超量素材取除才能发动。给这张卡放置1个鲨指示物。此外，这张卡进行战斗的伤害步骤内，这张卡的攻击力上升这张卡放置的鲨指示物数量×1000的数值。
function c14306092.initial_effect(c)
	c:EnableCounterPermit(0x2e)
	-- 为这张卡添加超量召唤手续：用3只以上（最多5只）等级3的怪兽作为素材进行超量叠放
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
c14306092.mentioned_counter={
	[0x2e]=true,
}
-- 作为发动代价，取除这张卡的1个超量素材（先检查能否取除）
function c14306092.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检查这张卡能否放置1个鲨指示物，作为效果能否发动的对象判定
function c14306092.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x2e,1) end
end
-- 若这张卡仍与效果相关且表侧表示，则给这张卡放置1个鲨指示物
function c14306092.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x2e,1)
	end
end
-- 永续效果的适用条件：判定当前是否处于这张卡进行战斗的伤害步骤
function c14306092.atkcon(e)
	-- 获取当前所处的阶段
	local ph=Duel.GetCurrentPhase()
	-- 当前阶段为伤害步骤或伤害计算时，且这张卡是攻击怪兽或被攻击的对象时条件成立
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end
-- 攻击力的上升数值为这张卡放置的鲨指示物数量×1000
function c14306092.atkval(e,c)
	return c:GetCounter(0x2e)*1000
end
