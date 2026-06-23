--破械式鬼シュマ
local s,id,o=GetID()
-- 定义一个函数s.initial_effect(c)，用于注册卡片的效果。
function s.initial_effect(c)
	-- 创建效果e1，描述为aux.Stringid(id,0)（效果提示），类别为特殊召唤和破坏，类型为单次触发效果，触发条件为通常召唤成功，延迟生效，限制每回合一次，目标为s.sptg，操作为s.spop，并将效果注册到卡片c。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 创建效果e2，描述为aux.Stringid(id,1)（效果提示），类别为特殊召唤，类型为单次触发效果，延迟生效，触发条件为被破坏，限制每回合一次，条件为s.spcon2，目标为s.sptg2，操作为s.spop2，并将效果注册到卡片c。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 定义一个函数s.spfilter(c,e,tp)，用于过滤符合特殊召唤条件的卡片：种族为机械族、不是自身、等级低于4且可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(id) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义一个函数s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)，作为特殊召唤效果的目标选择器。如果chk为0，则检查玩家场上是否有怪兽区，以及卡组中是否存在符合s.spfilter过滤条件的卡片。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的怪兽区域数量是否大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少一张满足s.spfilter条件且不等于排除卡的卡片。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从卡组特殊召唤1张卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 获取玩家场上的所有卡片。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if g:GetCount()>0 then
		-- 设置操作信息，表示将破坏1张卡片。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 定义一个函数s.spop(e,tp,eg,ep,ev,re,r,rp)，作为特殊召唤效果的操作。如果玩家的怪兽区域数量大于0，则提示选择要特殊召唤的卡片，从卡组中选择符合s.spfilter过滤条件的卡片进行特殊召唤，然后中断当前效果，提示选择要破坏的卡片，并破坏选中的卡片。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家的怪兽区域数量是否大于0。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家发送提示信息，要求选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择符合s.spfilter过滤条件的卡片。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 如果选择了卡片并且成功特殊召唤，则中断当前效果。
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 中断当前效果，使之后的效果处理视为不同时处理。
			Duel.BreakEffect()
			-- 向玩家发送提示信息，要求选择要破坏的卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择场上的卡片进行破坏。
			local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 手动显示选中的卡片的动画效果。
				Duel.HintSelection(sg)
				-- 以效果为理由破坏选定的卡片。
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
	-- 创建并注册一个场地效果，禁止对方特殊召唤恶魔族怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将e1效果注册为tp玩家的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 定义函数s.splimit(e,c)，判断是否可以特殊召唤。如果不是恶魔族则返回true（即不能特殊召唤）。
function s.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
-- 定义一个函数s.spcon2(e,tp,eg,ep,ev,re,r,rp)，作为第二个触发效果的条件判断器。检查被破坏的卡片是否是因为战斗或效果而破坏，并且不是由当前卡片的效果引起的，以及该卡片之前的位置是否在场上。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and not re:GetHandler():IsCode(id))) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义一个函数s.spfilter2(c,e,tp)，用于过滤符合特殊召唤条件的卡片：种族为机械族、不是自身且可以特殊召唤。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x130) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义一个函数s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)，作为第二个特殊召唤效果的目标选择器。如果chk为0，则检查玩家场上是否有怪兽区，以及手牌或卡组中是否存在符合s.spfilter2过滤条件的卡片。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的怪兽区域数量是否大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌和卡组中是否存在至少一张满足s.spfilter2条件且不等于排除卡的卡片。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将从手牌或卡组特殊召唤1张卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义一个函数s.spop2(e,tp,eg,ep,ev,re,r,rp)，作为第二个特殊召唤效果的操作。如果玩家的怪兽区域数量小于等于0，则直接返回。否则，提示选择要特殊召唤的卡片，从手牌或卡组中选择符合s.spfilter2过滤条件的卡片进行特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家的怪兽区域数量是否小于等于0，如果是则结束效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择符合s.spfilter2过滤条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡片以正面表示进行特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
