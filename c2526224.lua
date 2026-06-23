--炎王神獣 キリン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段才能发动。这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏，这张卡特殊召唤。
-- ②：这张卡被破坏送去墓地的场合才能发动。从自己的手卡·墓地把「炎王神兽 麒麟」以外的1只「炎王」怪兽特殊召唤。那之后，可以把场上1张卡破坏。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段才能发动。这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spscon)
	e1:SetTarget(s.spstg)
	e1:SetOperation(s.spsop)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏送去墓地的场合才能发动。从自己的手卡·墓地把「炎王神兽 麒麟」以外的1只「炎王」怪兽特殊召唤。那之后，可以把场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：当前阶段为主要阶段1或主要阶段2
function s.spscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤函数：返回场上表侧表示的炎属性怪兽且该玩家怪兽区有空位
function s.filter(c,tp)
	-- 返回场上表侧表示的炎属性怪兽且该玩家怪兽区有空位
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_FIRE) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的发动时的处理：检索满足条件的怪兽并设置破坏和特殊召唤的操作信息
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检索满足条件的怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,c,tp)
	if chk==0 then return #g>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的发动处理：选择破坏1只怪兽并特殊召唤自己
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,aux.ExceptThisCard(e),tp)
	-- 破坏选中的怪兽并判断自己是否还在场上
	if Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将自己特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：自己被破坏送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤函数：返回「炎王」族且可特殊召唤且不是自己的怪兽
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x81) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- 效果②的发动时的处理：检查是否有满足条件的怪兽并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果②的发动处理：选择特殊召唤1只怪兽并询问是否破坏场上1张卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有怪兽区空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 特殊召唤选中的怪兽
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)<1
		-- 询问是否破坏场上1张卡
		or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end  --"是否破坏场上1张卡？"
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 检索场上所有卡
	local sg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
	-- 显示选中的卡
	Duel.HintSelection(sg)
	-- 中断当前效果
	Duel.BreakEffect()
	-- 破坏选中的卡
	Duel.Destroy(sg,REASON_EFFECT)
end
