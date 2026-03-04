--トラブル・ダイバー
-- 效果：
-- 对方场上有怪兽存在，自己场上表侧表示存在的怪兽只有4星怪兽的场合，这张卡可以从手卡特殊召唤。这个方法的「老虎狗潜水员」的特殊召唤1回合只能有1次。把这张卡作为超量召唤的素材的场合，不是战士族怪兽的超量召唤不能使用。
function c1003028.initial_effect(c)
	-- 对方场上有怪兽存在，自己场上表侧表示存在的怪兽只有4星怪兽的场合，这张卡可以从手卡特殊召唤。这个方法的「老虎狗潜水员」的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,1003028+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c1003028.spcon)
	c:RegisterEffect(e1)
	-- 把这张卡作为超量召唤的素材的场合，不是战士族怪兽的超量召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c1003028.xyzlimit)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查场上是否存在非4星的表侧表示怪兽
function c1003028.cfilter(c)
	return c:IsFaceup() and not c:IsLevel(4)
end
-- 特殊召唤条件函数，判断是否满足特殊召唤的条件
function c1003028.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家的怪兽区域是否有可用空间
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在怪兽
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查对方场上是否存在怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己场上是否不存在非4星的表侧表示怪兽
		and not Duel.IsExistingMatchingCard(c1003028.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 超量召唤素材限制函数，判断怪兽是否不属于战士族
function c1003028.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_WARRIOR)
end
