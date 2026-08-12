--岩石の番兵
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，自己场上的怪兽只有岩石族怪兽的场合才能发动。这张卡特殊召唤。
function c57354389.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在墓地存在，自己场上的怪兽只有岩石族怪兽的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57354389,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,57354389)
	e1:SetCondition(c57354389.spcon)
	e1:SetTarget(c57354389.sptg)
	e1:SetOperation(c57354389.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：里侧表示怪兽或非岩石族怪兽
function c57354389.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_ROCK)
end
-- 发动条件：自己场上有怪兽存在，且不存在里侧表示怪兽和非岩石族怪兽（即自己场上的怪兽只有表侧表示的岩石族怪兽）
function c57354389.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否大于0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查自己场上是否不存在里侧表示怪兽以及非岩石族怪兽
		and not Duel.IsExistingMatchingCard(c57354389.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 检查发动可行性：自己场上有空余怪兽区域，且这张卡可以特殊召唤
function c57354389.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍存在于墓地，则将其特殊召唤
function c57354389.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
