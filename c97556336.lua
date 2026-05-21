--無垢なる者 メディウス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组选1只「狱神」怪兽加入手卡或特殊召唤。
-- ②：这张卡在墓地存在的场合才能发动。从自己的手卡·场上（表侧表示）让1只怪兽回到卡组，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡片效果：①召唤·特殊召唤成功时从卡组检索或特召「狱神」怪兽；②墓地起动效果，让手卡·场上1只怪兽回卡组，自身特殊召唤，离场除外。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组选1只「狱神」怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组操作"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合才能发动。从自己的手卡·场上（表侧表示）让1只怪兽回到卡组，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可加入手卡或可特殊召唤的「狱神」怪兽。
function s.thfilter(c,e,tp)
	if not (c:IsSetCard(0x1ce) and c:IsType(TYPE_MONSTER)) then return false end
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ①号效果的发动准备（检查卡组中是否存在符合条件的「狱神」怪兽）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只可加入手卡或可特殊召唤的「狱神」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- ①号效果的处理：从卡组选1只「狱神」怪兽，根据情况和玩家选择，将其加入手卡或特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择1只满足条件的「狱神」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否只能加入手卡，或者在可以特召且有空位的情况下，玩家主动选择加入手卡（选项0为加入手卡，选项1为特殊召唤）。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡片。
			Duel.ConfirmCards(1-tp,tc)
		elseif ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选中的怪兽在自身场上表侧表示特殊召唤。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤手卡或场上表侧表示、可回到卡组且能腾出或不影响怪兽区域空位（若需要）的怪兽。
function s.spfilter(c,tp,chk)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
		-- 检查将该怪兽送回卡组后，是否能确保有可用的怪兽区域用于特殊召唤（或者在不作严格检查时跳过）。
		and (Duel.GetMZoneCount(tp,c)>0 or not chk)
end
-- ②号效果的发动准备（检查手卡·场上是否有可回卡组的怪兽，且自身能否特殊召唤，并设置操作信息）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡·场上是否存在至少1只满足条件且能腾出怪兽区域的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,tp,true)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：含有将1张卡送回卡组的操作。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
	-- 设置连锁处理信息：含有将墓地的这张卡特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_GRAVE)
end
-- ②号效果的处理：让手卡·场上1只怪兽回到卡组，并将墓地的这张卡特殊召唤，同时适用离场除外的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送回卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local rg=nil
	-- 检查是否存在能确保特殊召唤位置的怪兽。
	if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,tp,true) then
		-- 让玩家选择1只满足条件且能确保特殊召唤位置的怪兽。
		rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,tp,true)
	else
		-- 若无法确保位置（例如已有空位），则让玩家任意选择1只满足条件的怪兽。
		rg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,tp,false)
	end
	if rg and rg:GetCount()>0 then
		if rg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 若选中的是手卡的怪兽，则给对方玩家确认。
			Duel.ConfirmCards(1-tp,rg)
		else
			-- 若选中的是场上的怪兽，则在场上显示选中动画。
			Duel.HintSelection(rg)
		end
		-- 将选中的怪兽送回卡组并洗卡组，判断是否成功。
		if Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
			and rg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)>0
			-- 检查这张卡是否仍与连锁相关，且不受「王家长眠之谷」的影响。
			and c:IsRelateToChain() and aux.NecroValleyFilter()(c)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 将这张卡特殊召唤，并判断是否成功。
			and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1,true)
		end
	end
end
