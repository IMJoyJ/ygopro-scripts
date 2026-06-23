--トラブル・ダイバー
-- 效果：
-- 对方场上有怪兽存在，自己场上表侧表示存在的怪兽只有4星怪兽的场合，这张卡可以从手卡特殊召唤。这个方法的「老虎狗潜水员」的特殊召唤1回合只能有1次。把这张卡作为超量召唤的素材的场合，不是战士族怪兽的超量召唤不能使用。
function c1003028.initial_effect(c)
	-- 创建效果e1，设置其类型为场上效果，Code为特殊召唤处理，属性为不可复制，生效范围为手牌，一回合次数限制为1次（使用1003028+EFFECT_COUNT_CODE_OATH作为计数器），并设置条件函数为c1003028.spcon，最后将效果注册给卡片c。对应原文：对方场上有怪兽存在，自己场上表侧表示存在的怪兽只有4星怪兽的场合，这张卡可以从手卡特殊召唤。这个方法的「老虎狗潜水员」的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,1003028+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c1003028.spcon)
	c:RegisterEffect(e1)
	-- 创建效果e2，设置其类型为单张卡效果，Code为不能作为超量素材，属性为不可无效+不可复制，Value设置为c1003028.xyzlimit，最后将效果注册给卡片c。对应原文：把这张卡作为超量召唤的素材的场合，不是战士族怪兽的超量召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(c1003028.xyzlimit)
	c:RegisterEffect(e2)
end
-- 定义过滤函数c1003028.cfilter，用于检查一张卡是否为表侧表示且等级不为4。
function c1003028.cfilter(c)
	return c:IsFaceup() and not c:IsLevel(4)
end
-- 定义特殊召唤条件函数c1003028.spcon，判断当前玩家的怪兽区是否有格子、场上是否存在怪兽以及是否存在非4星表侧表示怪兽。
function c1003028.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查控制者tp的怪兽区是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查控制者tp的怪兽区中存在怪兽。
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查控制者tp的额外怪兽区中存在怪兽。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查控制者tp的怪兽区中不存在满足c1003028.cfilter过滤条件的卡片（即表侧表示且等级不为4的怪兽）。
		and not Duel.IsExistingMatchingCard(c1003028.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义超量素材限制函数c1003028.xyzlimit，判断一张卡是否不是战士族。
function c1003028.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_WARRIOR)
end
