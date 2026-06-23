--端末世界NEXT
-- 效果：
-- 自己场上没有其他卡存在，对方场上的怪兽是3只以下，对方场上的魔法·陷阱卡是3张以下的场合才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，双方场上能出的怪兽变成各自最多到3只，双方场上能出的魔法·陷阱卡变成各自最多到3张。
function c48605591.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，双方场上能出的怪兽变成各自最多到3只，双方场上能出的魔法·陷阱卡变成各自最多到3张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c48605591.condition)
	c:RegisterEffect(e1)
	-- 自己场上没有其他卡存在，对方场上的怪兽是3只以下，对方场上的魔法·陷阱卡是3张以下的场合才能把这张卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_MAX_MZONE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c48605591.mvalue)
	c:RegisterEffect(e2)
	-- 自己场上没有其他卡存在，对方场上的怪兽是3只以下，对方场上的魔法·陷阱卡是3张以下的场合才能把这张卡发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_MAX_SZONE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,1)
	e3:SetValue(c48605591.svalue)
	c:RegisterEffect(e3)
	-- 自己场上没有其他卡存在，对方场上的怪兽是3只以下，对方场上的魔法·陷阱卡是3张以下的场合才能把这张卡发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(1,1)
	e4:SetValue(c48605591.aclimit)
	c:RegisterEffect(e4)
	-- 自己场上没有其他卡存在，对方场上的怪兽是3只以下，对方场上的魔法·陷阱卡是3张以下的场合才能把这张卡发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_SSET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(1,1)
	e5:SetTarget(c48605591.setlimit)
	c:RegisterEffect(e5)
end
-- 检查是否满足发动条件：自己场上没有其他卡存在、对方场上怪兽数量不超过3只、对方场上魔法·陷阱卡数量不超过3张。
function c48605591.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在除该卡外的其他卡。
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查对方场上怪兽数量是否不超过3只。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<=3
		-- 检查对方场上魔法·陷阱卡数量是否不超过3张。
		and Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)<=3
end
-- 设置怪兽区上限为3，若为场地卡则上限为5。
function c48605591.mvalue(e,fp,rp,r)
	if r~=LOCATION_REASON_TOFIELD then return 5 end
	return 3
end
-- 设置魔陷区上限为3，若为场地卡则上限为5，并根据已存在的魔陷卡减少可用格数。
function c48605591.svalue(e,fp,rp,r)
	if r~=LOCATION_REASON_TOFIELD then return 5 end
	local ct=3
	for i=5,7 do
		-- 遍历魔陷区判断是否有卡存在并减少可用格数。
		if Duel.GetFieldCard(fp,LOCATION_SZONE,i) then ct=ct-1 end
	end
	return ct
end
-- 限制对方发动魔法·陷阱卡的效果，若为场地或灵摆卡且魔陷区超过2格则禁止发动。
function c48605591.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	if re:IsActiveType(TYPE_FIELD) then
		-- 若为场地卡且未设置场地区域，则禁止发动。
		return not Duel.GetFieldCard(tp,LOCATION_FZONE,0) and Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)>2
	elseif re:IsActiveType(TYPE_PENDULUM) then
		-- 若魔陷区超过2格则禁止发动。
		return Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)>2
	end
	return false
end
-- 限制对方覆盖设置魔法·陷阱卡的效果，若为场地卡且未设置场地区域且魔陷区超过2格则禁止设置。
function c48605591.setlimit(e,c,tp)
	-- 若为场地卡且未设置场地区域且魔陷区超过2格则禁止设置。
	return c:IsType(TYPE_FIELD) and not Duel.GetFieldCard(tp,LOCATION_FZONE,0) and Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)>2
end
