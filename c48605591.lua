--端末世界NEXT
-- 效果：
-- 自己场上没有其他卡存在，对方场上的怪兽是3只以下，对方场上的魔法·陷阱卡是3张以下的场合才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，双方场上能出的怪兽变成各自最多到3只，双方场上能出的魔法·陷阱卡变成各自最多到3张。
function c48605591.initial_effect(c)
	-- 对应效果原文发动条件：‘自己场上没有其他卡存在，对方场上的怪兽是3只以下，对方场上的魔法·陷阱卡是3张以下的场合才能把这张卡发动。’（e1为发动效果，condition为发动条件判定）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c48605591.condition)
	c:RegisterEffect(e1)
	-- 对应①效果：‘双方场上能出的怪兽变成各自最多到3只’（e2为限制怪兽区最大可用数量的永续效果）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_MAX_MZONE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c48605591.mvalue)
	c:RegisterEffect(e2)
	-- 对应①效果：‘双方场上能出的魔法·陷阱卡变成各自最多到3张’（e3为限制魔陷区最大可用数量的永续效果）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_MAX_SZONE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,1)
	e3:SetValue(c48605591.svalue)
	c:RegisterEffect(e3)
	-- 对应①效果：‘双方场上能出的魔法·陷阱卡变成各自最多到3张’的配套限制：当普通魔陷区已超过2张时禁止发动场地/灵摆魔法，防止利用额外区域突破上限
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(1,1)
	e4:SetValue(c48605591.aclimit)
	c:RegisterEffect(e4)
	-- 对应①效果：‘双方场上能出的魔法·陷阱卡变成各自最多到3张’的配套限制：当普通魔陷区已超过2张时禁止覆盖场地魔法，防止利用覆盖额外区域突破上限
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_SSET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(1,1)
	e5:SetTarget(c48605591.setlimit)
	c:RegisterEffect(e5)
end
-- 检查本卡的发动条件：自己场上除本卡外没有其他卡，对方场上怪兽数不超过3，且对方场上魔法·陷阱卡数不超过3，全部满足才可发动。
function c48605591.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在任何其他卡片（排除本卡自身；包括怪兽、魔法、陷阱、场地等所有场上区域）。
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		-- 检查对方场上的怪兽数量是否小于或等于3。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<=3
		-- 检查对方场上的魔法·陷阱卡总数（包含场地魔法和灵摆魔法）是否小于或等于3。
		and Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)<=3
end
-- 作为EFFECT_MAX_MZONE的取值函数：当卡片正要放置到场上时（r为LOCATION_REASON_TOFIELD）返回3，使双方怪兽区最多只能使用3个区域；其他情况返回默认的5个区域。
function c48605591.mvalue(e,fp,rp,r)
	if r~=LOCATION_REASON_TOFIELD then return 5 end
	return 3
end
-- 作为EFFECT_MAX_SZONE的取值函数：当卡片正要放置到场上时，以3为魔陷区基础上限，再扣除场地区和灵摆区域中已有卡片数量，从而双方魔陷区可用格数被限制为最多3张；其他情况返回默认的5格。
function c48605591.svalue(e,fp,rp,r)
	if r~=LOCATION_REASON_TOFIELD then return 5 end
	local ct=3
	for i=5,7 do
		-- 如果场地区或灵摆区域（序号5-7）已有卡片，则每有一张就减少1个普通魔陷区可用格数，确保包括场地/灵摆在内的魔陷总数不超过3。
		if Duel.GetFieldCard(fp,LOCATION_SZONE,i) then ct=ct-1 end
	end
	return ct
end
-- 作为EFFECT_CANNOT_ACTIVATE的限制判定：当普通魔陷区数量已超过2时，禁止发动场地魔法和灵摆魔法，从而保证‘场上能出的魔法·陷阱卡不超过3张’不被额外区域突破。
function c48605591.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	if re:IsActiveType(TYPE_FIELD) then
		-- 当场地魔法区域没有卡片且普通魔陷区数量已超过2时，禁止发动场地魔法，否则发动后会使魔陷总数超过3张。
		return not Duel.GetFieldCard(tp,LOCATION_FZONE,0) and Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)>2
	elseif re:IsActiveType(TYPE_PENDULUM) then
		-- 当普通魔陷区数量已超过2时，禁止发动灵摆魔法，因为灵摆魔法发动后占用魔陷区会使总数超过3张。
		return Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)>2
	end
	return false
end
-- 作为EFFECT_CANNOT_SSET的限制判定：当普通魔陷区已超过2时，禁止玩家覆盖场地魔法，防止通过覆盖形式绕过魔陷区3张上限。
function c48605591.setlimit(e,c,tp)
	-- 如果该卡是场地魔法、场地区没有卡片且普通魔陷区数量已超过2，则不能将其覆盖到场上。
	return c:IsType(TYPE_FIELD) and not Duel.GetFieldCard(tp,LOCATION_FZONE,0) and Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)>2
end
