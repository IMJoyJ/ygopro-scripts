--CNo.1000 夢幻虚神ヌメロニアス
-- 效果：
-- 12星怪兽×5
-- ①：双方回合1次，把这张卡1个超量素材取除才能发动。选场上1只其他怪兽破坏。
-- ②：战斗阶段结束时发动。场上的其他怪兽全部破坏。那之后，可以从对方墓地选1只怪兽守备表示特殊召唤。
-- ③：持有超量素材的这张卡被对方的效果破坏送去墓地的场合才能发动。从额外卡组把1只「混沌虚数No.1000 梦幻虚光神 原数天灵·原数天地」特殊召唤，把这张卡作为那超量素材。
function c89477759.initial_effect(c)
	-- 设置XYZ召唤手续：12星怪兽×5。
	aux.AddXyzProcedure(c,nil,12,5)
	c:EnableReviveLimit()
	-- ①：双方回合1次，把这张卡1个超量素材取除才能发动。选场上1只其他怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89477759,0))  --"选场上1只其他怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c89477759.descost1)
	e1:SetTarget(c89477759.destg1)
	e1:SetOperation(c89477759.desop1)
	c:RegisterEffect(e1)
	-- ②：战斗阶段结束时发动。场上的其他怪兽全部破坏。那之后，可以从对方墓地选1只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_GRAVE_SPSUMMON)
	e2:SetDescription(aux.Stringid(89477759,1))  --"场上的其他怪兽全部破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c89477759.destg2)
	e2:SetOperation(c89477759.desop2)
	c:RegisterEffect(e2)
	-- ③：持有超量素材的这张卡被对方的效果破坏送去墓地的场合才能发动。从额外卡组把1只「混沌虚数No.1000 梦幻虚光神 原数天灵·原数天地」特殊召唤，把这张卡作为那超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89477759,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c89477759.spcon)
	e3:SetTarget(c89477759.sptg)
	e3:SetOperation(c89477759.spop)
	c:RegisterEffect(e3)
end
-- 设置该怪兽的「No.」数值为1000。
aux.xyz_number[89477759]=1000
-- 效果①的Cost：检查并取除这张卡的1个超量素材。
function c89477759.descost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的Target：检查场上是否存在其他怪兽，并设置破坏操作信息。
function c89477759.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在除自身以外的至少1只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除自身以外的所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置破坏操作信息，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的Operation：选场上1只其他怪兽破坏。
function c89477759.desop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只除自身以外的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 在场上显示选中卡片的特效。
		Duel.HintSelection(g)
		-- 因效果破坏选中的怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果②的Target：设置破坏场上所有其他怪兽的操作信息。
function c89477759.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上除自身以外的所有怪兽。
	local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置破坏操作信息，数量为场上所有其他怪兽的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 过滤条件：可以以表侧守备表示特殊召唤的怪兽。
function c89477759.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的Operation：破坏场上所有其他怪兽，之后可以从对方墓地选1只怪兽守备表示特殊召唤。
function c89477759.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除自身以外的所有怪兽。
	local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 如果成功破坏了怪兽，且自己场上有空余的怪兽区域。
	if Duel.Destroy(dg,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取对方墓地中可以守备表示特殊召唤的怪兽。
		local g=Duel.GetMatchingGroup(c89477759.spfilter2,tp,0,LOCATION_GRAVE,nil,e,tp)
		-- 如果存在可特殊召唤的怪兽，询问玩家是否发动特殊召唤效果。
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(89477759,3)) then  --"是否从对方墓地选怪兽特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤不与破坏同时处理（造成错时点）。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
-- 效果③的Condition：持有超量素材的这张卡在自己场上被对方的效果破坏送去墓地。
function c89477759.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetPreviousOverlayCountOnField()>0 and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp)
end
-- 过滤条件：额外卡组中卡名为「混沌虚数No.1000 梦幻虚光神 原数天灵·原数天地」且可以特殊召唤的XYZ怪兽。
function c89477759.spfilter(c,e,tp)
	return c:IsCode(15862758) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且自己场上有可以从额外卡组特殊召唤怪兽的空余区域。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果③的Target：检查额外卡组是否存在满足条件的怪兽，且自身可以作为超量素材，并设置特殊召唤和离开墓地的操作信息。
function c89477759.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c89477759.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		and e:GetHandler():IsCanOverlay() end
	-- 设置特殊召唤操作信息，数量为1，位置为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置离开墓地操作信息，目标为自身。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果③的Operation：从额外卡组特殊召唤「混沌虚数No.1000 梦幻虚光神 原数天灵·原数天地」，并将自身作为其超量素材。
function c89477759.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c89477759.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			-- 将自身重叠作为该怪兽的超量素材。
			Duel.Overlay(tc,Group.FromCards(c))
		end
	end
end
