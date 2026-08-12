--ヴァレルガード・ドラゴン
-- 效果：
-- 效果怪兽3只以上
-- ①：场上的这张卡不会被效果破坏。
-- ②：1回合1次，把自己的魔法与陷阱区域1张卡送去墓地才能发动。把这个回合被破坏送去自己或对方的墓地的1只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ③：自己·对方回合1次，以场上1只怪兽为对象才能发动（对方不能对应这个发动把卡的效果发动）。那只怪兽变成表侧守备表示。
function c68987122.initial_effect(c)
	-- 设置连接召唤手续，需要效果怪兽3只以上。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- ①：场上的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把自己的魔法与陷阱区域1张卡送去墓地才能发动。把这个回合被破坏送去自己或对方的墓地的1只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68987122,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c68987122.spcost)
	e2:SetTarget(c68987122.sptg)
	e2:SetOperation(c68987122.spop)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合1次，以场上1只怪兽为对象才能发动（对方不能对应这个发动把卡的效果发动）。那只怪兽变成表侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68987122,1))  --"变成表侧守备表示"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetTarget(c68987122.postg)
	e3:SetOperation(c68987122.posop)
	c:RegisterEffect(e3)
end
-- 过滤自己魔法与陷阱区域（不含场地区）可以送去墓地的卡。
function c68987122.costfilter(c)
	return c:IsAbleToGraveAsCost() and c:GetSequence()<5
end
-- 效果②的发动代价（Cost）处理：将自己魔陷区的一张卡送去墓地。
function c68987122.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否存在可以作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c68987122.costfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择自己魔陷区的一张卡。
	local g=Duel.SelectMatchingCard(tp,c68987122.costfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选中的卡作为发动代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤本回合被破坏送去双方墓地且可以特殊召唤的怪兽。
function c68987122.spfilter(c,e,tp,tid)
	return c:GetTurnID()==tid and bit.band(c:GetReason(),REASON_DESTROY)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）处理：检查怪兽区域空位及是否存在符合条件的墓地怪兽。
function c68987122.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前回合数。
	local tid=Duel.GetTurnCount()
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地中是否存在本回合被破坏送去墓地且可以特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c68987122.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,tid) end
	-- 设置特殊召唤的操作信息（从墓地特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理（Operation）：选择符合条件的墓地怪兽特殊召唤，并将其效果无效化。
function c68987122.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前回合数。
	local tid=Duel.GetTurnCount()
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择双方墓地中1只本回合被破坏送去墓地的怪兽。
	local g=Duel.SelectMatchingCard(tp,c68987122.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp,tid)
	local tc=g:GetFirst()
	-- 尝试将选中的怪兽以表侧表示特殊召唤到自己场上。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。③：自己·对方回合1次，以场上1只怪兽为对象才能发动（对方不能对应这个发动把卡的效果发动）。那只怪兽变成表侧守备表示。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤的最终处理。
	Duel.SpecialSummonComplete()
end
-- 过滤场上非表侧守备表示且可以改变表示形式的怪兽。
function c68987122.posfilter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
-- 效果③的发动准备（Target）处理：选择场上1只怪兽作为对象，并限制对方不能对应此效果的发动来发动卡的效果。
function c68987122.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c68987122.posfilter(chkc) end
	-- 检查场上是否存在可以改变表示形式的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c68987122.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家选择场上1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c68987122.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置改变表示形式的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
	-- 限制连锁，使得对方不能对应这个效果的发动把卡的效果发动。
	Duel.SetChainLimit(c68987122.chlimit)
end
-- 连锁限制条件：只有发动该效果的玩家（自己）可以进行连锁。
function c68987122.chlimit(e,ep,tp)
	return tp==ep
end
-- 效果③的效果处理（Operation）：将作为对象的怪兽变成表侧守备表示。
function c68987122.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变成表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
