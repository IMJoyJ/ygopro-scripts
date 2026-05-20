--盆回し
-- 效果：
-- ①：从卡组选2张卡名不同的场地魔法卡，那之内的1张在自己场上盖放，另1张在对方场上盖放。只要这个效果盖放的卡的其中任意张在场地区域盖放中，双方不能把其他的场地魔法卡发动·盖放。
function c73468603.initial_effect(c)
	-- ①：从卡组选2张卡名不同的场地魔法卡，那之内的1张在自己场上盖放，另1张在对方场上盖放。只要这个效果盖放的卡的其中任意张在场地区域盖放中，双方不能把其他的场地魔法卡发动·盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c73468603.target)
	e1:SetOperation(c73468603.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中可以盖放的场地魔法卡
function c73468603.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsSSetable()
end
-- 检查卡组中是否存在至少2张卡名不同的可以盖放的场地魔法卡
function c73468603.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己卡组中所有可以盖放的场地魔法卡
	local g=Duel.GetMatchingGroup(c73468603.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>1 end
end
-- 执行将2张卡名不同的场地魔法卡分别在双方场上盖放，并注册限制双方发动和盖放其他场地魔法卡的效果
function c73468603.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有可以盖放的场地魔法卡
	local g=Duel.GetMatchingGroup(c73468603.filter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 提示玩家选择要盖放到自己场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(73468603,0))  --"请选择要盖放到自己场上的卡"
	local tg1=g:Select(tp,1,1,nil)
	g:Remove(Card.IsCode,nil,tg1:GetFirst():GetCode())
	-- 提示玩家选择要盖放到对方场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(73468603,1))  --"请选择要盖放到对方场上的卡"
	local tg2=g:Select(tp,1,1,nil)
	-- 将选中的第1张卡在自己场上盖放
	Duel.SSet(tp,tg1)
	-- 将选中的第2张卡在对方场上盖放
	Duel.SSet(tp,tg2,1-tp)
	tg1:GetFirst():RegisterFlagEffect(73468603,RESET_EVENT+RESETS_STANDARD,0,1)
	tg2:GetFirst():RegisterFlagEffect(73468603,RESET_EVENT+RESETS_STANDARD,0,1)
	-- 只要这个效果盖放的卡的其中任意张在场地区域盖放中，双方不能把其他的场地魔法卡发动
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetCondition(c73468603.con)
	e1:SetValue(c73468603.actlimit)
	-- 注册限制双方发动其他场地魔法卡的效果
	Duel.RegisterEffect(e1,tp)
	-- 只要这个效果盖放的卡的其中任意张在场地区域盖放中，双方不能把其他的场地魔法卡...盖放
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SSET)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(c73468603.con)
	e2:SetTarget(c73468603.setlimit)
	-- 注册限制双方盖放其他场地魔法卡的效果
	Duel.RegisterEffect(e2,tp)
end
-- 过滤场地区域中由该效果盖放且仍处于里侧表示的卡
function c73468603.cfilter(c)
	return c:IsFacedown() and c:GetFlagEffect(73468603)~=0
end
-- 限制发动和盖放效果的适用条件：场地区域存在由该效果盖放且仍处于里侧表示的卡
function c73468603.con(e)
	-- 检查双方场地区域是否存在至少1张由该效果盖放且仍处于里侧表示的卡
	return Duel.IsExistingMatchingCard(c73468603.cfilter,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 限制发动的卡片过滤：不能发动除该效果盖放的卡以外的场地魔法卡
function c73468603.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():GetFlagEffect(73468603)==0
end
-- 限制盖放的卡片过滤：不能盖放除该效果盖放的卡以外的场地魔法卡
function c73468603.setlimit(e,c,tp)
	return c:IsType(TYPE_FIELD) and c:GetFlagEffect(73468603)==0
end
