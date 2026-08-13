--ワーム・ヴィクトリー
-- 效果：
-- 反转：名字带有「异虫」的爬虫类族怪兽以外的场上表侧表示存在的怪兽全部破坏。这张卡的攻击力上升自己墓地存在的名字带有「异虫」的爬虫类族怪兽数量×500的数值。
function c2088870.initial_effect(c)
	-- 反转：名字带有「异虫」的爬虫类族怪兽以外的场上表侧表示存在的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetTarget(c2088870.destg)
	e1:SetOperation(c2088870.desop)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力上升自己墓地存在的名字带有「异虫」的爬虫类族怪兽数量×500的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c2088870.atkval)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示，且不是“名字带有「异虫」的爬虫类族怪兽”的怪兽。
function c2088870.filter(c)
	return c:IsFaceup() and not (c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE))
end
-- 反转效果的发动时点：满足发动条件则通过；随后获取场上所有符合条件的表侧表示怪兽，并设置破坏相关的操作信息。
function c2088870.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取以tp视角看场上所有满足filter的怪兽（表侧表示且非异虫爬虫类怪兽），用于确定反转效果要破坏的对象。
	local g=Duel.GetMatchingGroup(c2088870.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将本次连锁的处理信息设置为破坏效果，对象为g，预计破坏数量为g:GetCount()，供其他卡发动时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 反转效果处理时：再次获取场上所有符合条件的表侧表示怪兽，并全部以效果原因破坏。
function c2088870.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取以tp视角看场上所有满足filter的怪兽（表侧表示且非异虫爬虫类怪兽），用于实际执行破坏。
	local g=Duel.GetMatchingGroup(c2088870.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将g中的所有怪兽以效果（REASON_EFFECT）为原因破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 过滤条件：卡名含有「异虫」（0x3e）且种族为爬虫类族的怪兽。
function c2088870.vfilter(c)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
end
-- 攻击力上升效果的值计算：以该怪兽的控制者为视角，统计其墓地中符合条件的「异虫」爬虫类族怪兽数量。
function c2088870.atkval(e,c)
	-- 返回自己墓地中满足vfilter的怪兽数量乘以500，作为这张卡的攻击力上升数值。
	return Duel.GetMatchingGroupCount(c2088870.vfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*500
end
