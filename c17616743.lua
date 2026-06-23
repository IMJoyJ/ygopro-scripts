--喚忌の呪眼
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地选1只「咒眼」怪兽特殊召唤。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，也能作为代替从卡组把1只「咒眼」怪兽特殊召唤。
function c17616743.initial_effect(c)
	-- 创建效果，设置为发动时点，可以特殊召唤，限制发动次数为1次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,17616743+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c17616743.sptg)
	e1:SetOperation(c17616743.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查是否为「咒眼」怪兽且可以被特殊召唤
function c17616743.spfilter(c,e,tp)
	return c:IsSetCard(0x129) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，检查是否为「太阴之咒眼」且表侧表示
function c17616743.filter(c)
	return c:IsCode(44133040) and c:IsFaceup()
end
-- 效果的发动条件判断，检查是否有足够的怪兽区域以及满足条件的怪兽
function c17616743.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家场上是否有足够的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local loc=LOCATION_HAND+LOCATION_GRAVE
		-- 检查玩家魔法与陷阱区域是否存在「太阴之咒眼」
		if Duel.IsExistingMatchingCard(c17616743.filter,tp,LOCATION_SZONE,0,1,nil) then
			loc=loc+LOCATION_DECK
		end
		-- 检查是否存在满足条件的「咒眼」怪兽
		return Duel.IsExistingMatchingCard(c17616743.spfilter,tp,loc,0,1,nil,e,tp)
	end
	-- 设置效果处理时要特殊召唤的卡的类型和位置信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果的处理函数，执行特殊召唤操作
function c17616743.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local loc=LOCATION_HAND+LOCATION_GRAVE
	-- 检查玩家魔法与陷阱区域是否存在「太阴之咒眼」
	if Duel.IsExistingMatchingCard(c17616743.filter,tp,LOCATION_SZONE,0,1,nil) then
		loc=loc+LOCATION_DECK
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「咒眼」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c17616743.spfilter),tp,loc,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
