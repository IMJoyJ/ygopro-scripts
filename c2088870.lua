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
-- 过滤函数，返回场上表侧表示且不是名字带有「异虫」的爬虫类族怪兽的怪兽。
function c2088870.filter(c)
	return c:IsFaceup() and not (c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE))
end
-- 设置连锁处理中要破坏的怪兽组，用于破坏效果的发动确认。
function c2088870.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有满足过滤条件的怪兽组。
	local g=Duel.GetMatchingGroup(c2088870.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前连锁处理的破坏对象为g组怪兽，数量为g的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，将g组怪兽以效果原因破坏。
function c2088870.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足过滤条件的怪兽组。
	local g=Duel.GetMatchingGroup(c2088870.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因将g组怪兽全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 过滤函数，返回墓地里名字带有「异虫」且属于爬虫类族的怪兽。
function c2088870.vfilter(c)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
end
-- 计算自己墓地中名字带有「异虫」且属于爬虫类族的怪兽数量，并乘以500作为攻击力提升值。
function c2088870.atkval(e,c)
	-- 返回自己墓地中满足条件的怪兽数量乘以500的结果。
	return Duel.GetMatchingGroupCount(c2088870.vfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*500
end
