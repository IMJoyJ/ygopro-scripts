--水晶機巧－サルファフナー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，从手卡把「水晶机巧-柠晶龙」以外的1张「水晶机巧」卡丢弃才能发动。这张卡守备表示特殊召唤。那之后，自己场上1张卡破坏。
-- ②：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「水晶机巧」怪兽守备表示特殊召唤。
function c3422200.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，从手卡把「水晶机巧-柠晶龙」以外的1张「水晶机巧」卡丢弃才能发动。这张卡守备表示特殊召唤。那之后，自己场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3422200,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,3422200)
	e1:SetCost(c3422200.spcost)
	e1:SetTarget(c3422200.sptg)
	e1:SetOperation(c3422200.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合才能发动。从卡组把1只「水晶机巧」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3422200,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,3422201)
	e2:SetCondition(c3422200.spcon2)
	e2:SetTarget(c3422200.sptg2)
	e2:SetOperation(c3422200.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否包含除自身外的「水晶机巧」卡且可被丢弃
function c3422200.cfilter(c)
	return c:IsSetCard(0xea) and not c:IsCode(3422200) and c:IsDiscardable()
end
-- 检查手卡中是否存在满足条件的「水晶机巧」卡并将其丢弃作为效果发动的代价
function c3422200.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张满足条件的「水晶机巧」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c3422200.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1张满足条件的「水晶机巧」卡
	Duel.DiscardHand(tp,c3422200.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 设置效果发动时的处理目标，包括特殊召唤自身和破坏场上一张卡
function c3422200.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，表示将特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 获取玩家场上的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if g:GetCount()>0 then
		-- 设置操作信息，表示将破坏场上一张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 处理效果发动时的特殊召唤和破坏操作
function c3422200.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1张卡作为破坏目标
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
		if g:GetCount()>0 then
			-- 以效果原因破坏选中的卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 判断该卡是否因战斗或效果被破坏且之前在场上
function c3422200.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于判断卡组中是否存在可特殊召唤的「水晶机巧」怪兽
function c3422200.spfilter(c,e,tp)
	return c:IsSetCard(0xea) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果发动时的处理目标，包括特殊召唤卡组中的「水晶机巧」怪兽
function c3422200.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的「水晶机巧」怪兽
		and Duel.IsExistingMatchingCard(c3422200.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动时的特殊召唤操作
function c3422200.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「水晶机巧」怪兽
	local g=Duel.SelectMatchingCard(tp,c3422200.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
