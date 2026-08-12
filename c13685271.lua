--同姓同名同盟条約
-- 效果：
-- 自己场上有衍生物以外的同名怪兽表侧表示2只以上存在的场合才能发动。那些同名怪兽的数量的以下效果适用。
-- ●2只：对方场上存在的1张魔法·陷阱卡破坏。
-- ●3只：对方场上存在的魔法·陷阱卡全部破坏。
function c13685271.initial_effect(c)
	-- 效果发动条件：自己场上有衍生物以外的同名怪兽表侧表示2只以上存在时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x11e0)
	e1:SetCondition(c13685271.condition)
	e1:SetTarget(c13685271.target)
	e1:SetOperation(c13685271.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于筛选场上表侧表示的非衍生物怪兽。
function c13685271.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
-- 计算函数：统计场上同名怪兽数量。
function c13685271.get_count(g)
	if g:GetCount()==0 then return 0 end
	local ret=0
	repeat
		local tc=g:GetFirst()
		g:RemoveCard(tc)
		local ct1=g:GetCount()
		g:Remove(Card.IsCode,nil,tc:GetCode())
		local ct2=g:GetCount()
		local c=ct1-ct2+1
		if c>ret then ret=c end
	until g:GetCount()==0 or g:GetCount()<=ret
	return ret
end
-- 条件判断函数：检查是否满足发动条件。
function c13685271.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检索场上表侧表示的非衍生物怪兽组。
	local g=Duel.GetMatchingGroup(c13685271.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=c13685271.get_count(g)
	e:SetLabel(ct)
	return ct==2 or ct==3
end
-- 过滤函数：用于筛选场上魔法·陷阱卡。
function c13685271.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 目标设定函数：设置效果处理时要破坏的卡。
function c13685271.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c13685271.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 检索对方场上的魔法·陷阱卡组。
	local g=Duel.GetMatchingGroup(c13685271.filter,tp,0,LOCATION_ONFIELD,nil)
	if e:GetLabel()==2 then
		-- 设置连锁操作信息：当同名怪兽为2只时，破坏1张对方场上的魔法·陷阱卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁操作信息：当同名怪兽为3只时，破坏对方场上所有魔法·陷阱卡。
	else Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0) end
end
-- 效果处理函数：执行效果的破坏处理。
function c13685271.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索场上表侧表示的非衍生物怪兽组。
	local g=Duel.GetMatchingGroup(c13685271.cfilter,tp,LOCATION_MZONE,0,nil)
	local ct=c13685271.get_count(g)
	if ct==2 then
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		-- 选择对方场上1张魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,c13685271.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 将选择的魔法·陷阱卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
	elseif ct==3 then
		-- 检索对方场上的魔法·陷阱卡组。
		local g=Duel.GetMatchingGroup(c13685271.filter,tp,0,LOCATION_ONFIELD,nil)
		-- 将对方场上所有魔法·陷阱卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
