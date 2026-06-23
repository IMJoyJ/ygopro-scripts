--ティンダングル・ジレルス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡的场合，把这张卡以外的1张手卡丢弃才能发动。从卡组把「廷达魔三角之结界石」以外的1张「廷达魔三角」卡送去墓地，这张卡里侧守备表示特殊召唤。
-- ②：这张卡反转的场合才能发动。从卡组选「廷达魔三角之结界石」以外的1只反转怪兽加入手卡或送去墓地。
function c24158464.initial_effect(c)
	-- ①：这张卡在手卡的场合，把这张卡以外的1张手卡丢弃才能发动。从卡组把「廷达魔三角之结界石」以外的1张「廷达魔三角」卡送去墓地，这张卡里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24158464,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,24158464)
	e1:SetCost(c24158464.spcost)
	e1:SetTarget(c24158464.sptg)
	e1:SetOperation(c24158464.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡反转的场合才能发动。从卡组选「廷达魔三角之结界石」以外的1只反转怪兽加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24158464,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,24158465)
	e1:SetTarget(c24158464.target)
	e1:SetOperation(c24158464.operation)
	c:RegisterEffect(e1)
end
-- 丢弃一张手卡作为cost
function c24158464.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 执行丢弃手卡操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 检索条件过滤器：筛选「廷达魔三角」卡且不是本卡，且能送去墓地
function c24158464.tgfilter(c)
	return c:IsSetCard(0x10b) and not c:IsCode(24158464) and c:IsAbleToGrave()
end
-- 设置①效果的发动条件：检查是否有足够的怪兽区域，本卡能否特殊召唤，卡组是否有符合条件的卡
function c24158464.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 检查卡组是否有符合条件的「廷达魔三角」卡
		and Duel.IsExistingMatchingCard(c24158464.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：选择卡组中的「廷达魔三角」卡送去墓地，然后将本卡特殊召唤
function c24158464.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择卡组中符合条件的「廷达魔三角」卡
	local g=Duel.SelectMatchingCard(tp,c24158464.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡送去墓地且在墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 判断本卡是否还在场上且成功特殊召唤
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 向对方确认本卡的特殊召唤
		Duel.ConfirmCards(1-tp,c)
	end
end
-- 反转怪兽过滤器：筛选反转怪兽且不是本卡，且能回手或送去墓地
function c24158464.filter(c)
	return c:IsType(TYPE_FLIP) and not c:IsCode(24158464) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ②效果的发动条件：检查卡组是否有符合条件的反转怪兽
function c24158464.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否有符合条件的反转怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c24158464.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要加入手卡的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理时要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理函数：选择卡组中的反转怪兽，然后选择加入手卡或送去墓地
function c24158464.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择卡组中符合条件的反转怪兽
	local g=Duel.SelectMatchingCard(tp,c24158464.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 判断是否能将卡加入手卡，否则选择送去墓地
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将卡送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
