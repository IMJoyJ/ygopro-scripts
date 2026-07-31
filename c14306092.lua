--牙鮫帝シャーク・カイゼル
-- 效果：
-- 3星怪兽×3只以上（最多5只）
-- 1回合1次，把这张卡1个超量素材取除才能发动。给这张卡放置1个鲨指示物。此外，这张卡进行战斗的伤害步骤内，这张卡的攻击力上升这张卡放置的鲨指示物数量×1000的数值。
function c14306092.initial_effect(c)
	c:EnableCounterPermit(0x2e)
	-- 为 c 添加 XYZ 召唤手续，允许用等级为 3、数量为 3（最多 5）只怪兽进行叠放
	aux.AddXyzProcedure(c,nil,3,3,nil,nil,5)
	c:EnableReviveLimit()
	-- '1回合1次，把这张卡1个超量素材取除才能发动。给这张卡放置1个鲨指示物。'
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
	-- '此外，这张卡进行战斗的伤害步骤内，这张卡的攻击力上升这张卡放置的鲨指示物数量×1000的数值。'
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
-- 效果发动时的代价：检查并移除该怪兽叠放的至少1张卡片（对应'把这张卡1个超量素材取除'）
function c14306092.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时的目标检查：确认怪兽当前能放置的鲨指示物数量是否至少为1（对应'给这张卡放置1个鲨指示物'）
function c14306092.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanAddCounter(0x2e,1) end
end
-- 效果发动时的处理：如果怪兽与效果关联且表侧表示，则为其添加1个鲨指示物（对应'给这张卡放置1个鲨指示物'）
function c14306092.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x2e,1)
	end
end
-- 效果发动时的条件函数定义：检查当前阶段是否为伤害步骤，且怪兽为攻击方或被攻击方之一（对应'此外...'部分）
function c14306092.atkcon(e)
	-- 获取决斗当前的阶段变量，用于后续判断是否处于伤害步骤
	local ph=Duel.GetCurrentPhase()
	-- 返回布尔值结果，表示怪兽当前状态是否符合攻击力修正的触发条件（对应'此外...'部分）
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) and (Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler())
end
-- 效果发动时的数值计算：返回怪兽当前已放置的鲨指示物数量乘以1000后的数值，用于增加攻击力（对应'这张卡的攻击力上升...'）
function c14306092.atkval(e,c)
	return c:GetCounter(0x2e)*1000
end
