--超量機神王グレート・マグナス
-- 效果：
-- 12星怪兽×3
-- ①：得到这张卡的超量素材种类的以下效果。
-- ●2种类以上：1回合1次，自己·对方的主要阶段把这张卡1个超量素材取除才能发动。选场上1张卡回到卡组。
-- ●4种类以上：这张卡不受「超级量子」卡以外的卡的效果影响。
-- ●6种类以上：对方不能用卡的效果从卡组把卡加入手卡。
-- ②：这张卡被送去墓地的场合才能发动。从自己墓地选「超级量子机兽」超量怪兽3种类各1只特殊召唤。
function c84025439.initial_effect(c)
	-- 为这张卡添加超量召唤手续：12星怪兽×3。
	aux.AddXyzProcedure(c,nil,12,3)
	c:EnableReviveLimit()
	-- ●2种类以上：1回合1次，自己·对方的主要阶段把这张卡1个超量素材取除才能发动。选场上1张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84025439,0))  --"回到卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c84025439.tdcon)
	e1:SetCost(c84025439.tdcost)
	e1:SetTarget(c84025439.tdtg)
	e1:SetOperation(c84025439.tdop)
	c:RegisterEffect(e1)
	-- ●4种类以上：这张卡不受「超级量子」卡以外的卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c84025439.imcon)
	e2:SetValue(c84025439.efilter)
	c:RegisterEffect(e2)
	-- ●6种类以上：对方不能用卡的效果从卡组把卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCondition(c84025439.drcon)
	-- 设置不能加入手牌的卡片来源为卡组。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e3)
	-- ●6种类以上：对方不能用卡的效果从卡组把卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_DRAW)
	e4:SetCondition(c84025439.drcon)
	e4:SetTargetRange(0,1)
	c:RegisterEffect(e4)
	-- ②：这张卡被送去墓地的场合才能发动。从自己墓地选「超级量子机兽」超量怪兽3种类各1只特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(84025439,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetTarget(c84025439.sptg)
	e6:SetOperation(c84025439.spop)
	c:RegisterEffect(e6)
end
-- 效果①中“2种类以上”效果的发动条件函数。
function c84025439.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查超量素材的卡名种类是否在2种以上，且当前是否为自己或对方的主要阶段。
	return e:GetHandler():GetOverlayGroup():GetClassCount(Card.GetCode)>=2 and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果①中“2种类以上”效果的发动代价函数：取除1个超量素材。
function c84025439.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①中“2种类以上”效果的发动准备（Target）函数。
function c84025439.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张可以回到卡组的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有可以回到卡组的卡片。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁处理信息：将场上的1张卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果①中“2种类以上”效果的处理（Operation）函数。
function c84025439.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择场上1张可以回到卡组的卡。
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if sg:GetCount()>0 then
		-- 在场上为选中的卡片显示选择框动画。
		Duel.HintSelection(sg)
		-- 将选中的卡送回持有者卡组并洗牌。
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果①中“4种类以上”效果的适用条件：超量素材的卡名种类在4种以上。
function c84025439.imcon(e)
	return e:GetHandler():GetOverlayGroup():GetClassCount(Card.GetCode)>=4
end
-- 免疫效果的过滤器：不受「超级量子」卡以外的卡的效果影响。
function c84025439.efilter(e,te)
	return not te:GetOwner():IsSetCard(0xdc)
end
-- 效果①中“6种类以上”效果的适用条件：超量素材的卡名种类在6种以上。
function c84025439.drcon(e)
	return e:GetHandler():GetOverlayGroup():GetClassCount(Card.GetCode)>=6
end
-- 过滤墓地中可以特殊召唤的「超级量子机兽」超量怪兽。
function c84025439.spfilter(c,e,tp)
	return c:IsSetCard(0x20dc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）函数。
function c84025439.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己墓地中所有满足特殊召唤条件的「超级量子机兽」超量怪兽。
		local g=Duel.GetMatchingGroup(c84025439.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查自己场上的怪兽区域空位是否大于2个，且墓地中可特召的「超级量子机兽」卡名种类是否大于2种。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>2 and g:GetClassCount(Card.GetCode)>2
	end
	-- 设置连锁处理信息：从墓地特殊召唤3只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_GRAVE)
end
-- 效果②的处理（Operation）函数。
function c84025439.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取自己场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己墓地中所有满足特殊召唤条件的「超级量子机兽」超量怪兽。
	local g=Duel.GetMatchingGroup(c84025439.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft>2 and g:GetClassCount(Card.GetCode)>2 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从符合条件的怪兽中选择3张卡名不同的卡。
		local g1=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 将选中的3只怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
end
