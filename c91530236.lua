--精霊術の使い手
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃1张手卡才能发动。从卡组选「灵使」怪兽、「凭依装着」怪兽、「凭依」魔法·陷阱卡之内2张（同名卡最多1张）。那之内的1张加入手卡，另1张在自己场上盖放。
function c91530236.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：丢弃1张手卡才能发动。从卡组选「灵使」怪兽、「凭依装着」怪兽、「凭依」魔法·陷阱卡之内2张（同名卡最多1张）。那之内的1张加入手卡，另1张在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_MSET+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,91530236+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c91530236.cost)
	e1:SetTarget(c91530236.target)
	e1:SetOperation(c91530236.activate)
	c:RegisterEffect(e1)
end
-- ①效果的发动代价：检查并从自己手卡丢弃这张卡以外的1张可丢弃手卡。
function c91530236.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认自己手卡中除这张卡外存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让己方从手卡选择1张可丢弃的卡并作为发动代价丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 范围过滤函数：检查卡片是否为「灵使」怪兽、「凭依装着」怪兽或「凭依」魔法·陷阱卡。
function c91530236.filter(c)
	return c:IsSetCard(0xbf) and c:IsType(TYPE_MONSTER)
		or c:IsSetCard(0x10c0) and c:IsType(TYPE_MONSTER)
		or c:IsSetCard(0xc0) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 加手卡卡片过滤函数：检查卡片是否满足范围且可加入手卡，同时卡组还存在另1张满足条件的卡可供盖放。
function c91530236.thfilter(c,e,tp,mft,sft)
	return c91530236.filter(c) and c:IsAbleToHand()
		-- 检查卡组中是否存在另1张与该卡不同名且可以在己方场上盖放的目标卡。
		and Duel.IsExistingMatchingCard(c91530236.setfilter,tp,LOCATION_DECK,0,1,c,e,tp,mft,sft,c:GetCode())
end
-- 盖放卡片过滤函数：检查卡片是否满足范围、与前一张卡不同名，且在魔陷或怪兽区有空位时可里侧盖放。
function c91530236.setfilter(c,e,tp,mft,sft,code)
	return c91530236.filter(c) and not c:IsCode(code)
		and (sft>0 and c:IsSSetable(true) or mft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
end
-- ①效果的目标处理函数：计算可用怪兽区与魔陷区空位（扣除从手卡发动的这张卡占用的1格），检查卡组是否存在合法的检索+盖放组合。
function c91530236.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己主要怪兽区可用于盖放怪兽的空位数量。
		local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取自己魔法与陷阱区可用于盖放魔陷的空位数量。
		local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then sft=sft-1 end
		-- 确认自己卡组存在至少1对满足「1张加手卡＋1张不同名盖放」条件的卡片组合。
		return Duel.IsExistingMatchingCard(c91530236.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,mft,sft)
	end
	-- 设置操作信息：预计从自己卡组把1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理函数：依次从卡组选择1张加入手卡和另1张不同名卡里侧盖放，并向对方确认这2张卡。
function c91530236.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时获取自己主要怪兽区的可用空位数量。
	local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 处理时获取自己魔法与陷阱区的可用空位数量。
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 发送提示信息，引导玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张要加入手卡的符合条件卡片。
	local tc1=Duel.SelectMatchingCard(tp,c91530236.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mft,sft):GetFirst()
	if tc1 then
		-- 发送提示信息，引导玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从自己卡组选择另1张与已选卡不同名且可盖放的符合条件卡片。
		local tc2=Duel.SelectMatchingCard(tp,c91530236.setfilter,tp,LOCATION_DECK,0,1,1,tc1,e,tp,mft,sft,tc1:GetCode()):GetFirst()
		-- 将第1张所选卡以效果加入自己手卡。
		Duel.SendtoHand(tc1,nil,REASON_EFFECT)
		if tc2:IsType(TYPE_MONSTER) then
			-- 若第2张卡是怪兽，将其以里侧守备表示特殊召唤（里侧盖放）到自己场上。
			Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		else
			-- 若第2张卡是魔法或陷阱，将其里侧盖放到自己的魔法与陷阱区域。
			Duel.SSet(tp,tc2,tp,false)
		end
		-- 将加入手卡和盖放的这2张卡一起展示给对方确认。
		Duel.ConfirmCards(1-tp,Group.FromCards(tc1,tc2))
	end
end
