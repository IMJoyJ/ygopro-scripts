--ティンダングル・ジレルス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡的场合，把这张卡以外的1张手卡丢弃才能发动。从卡组把「廷达魔三角之结界石」以外的1张「廷达魔三角」卡送去墓地，这张卡里侧守备表示特殊召唤。
-- ②：这张卡反转的场合才能发动。从卡组选「廷达魔三角之结界石」以外的1只反转怪兽加入手卡或送去墓地。
function c24158464.initial_effect(c)
	-- 对应效果原文①：这张卡在手卡的场合，把这张卡以外的1张手卡丢弃才能发动。从卡组把「廷达魔三角之结界石」以外的1张「廷达魔三角」卡送去墓地，这张卡里侧守备表示特殊召唤。
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
	-- 对应效果原文②：这张卡反转的场合才能发动。从卡组选「廷达魔三角之结界石」以外的1只反转怪兽加入手卡或送去墓地。
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
-- 定义①效果的发动代价：丢弃这张卡以外的1张手卡，并检查是否存在满足代价的手卡，然后实际执行丢弃。
function c24158464.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动合法性检查：确认自己手牌中存在除这张卡以外的至少1张可丢弃的手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 实际支付代价：从手牌选择1张自身以外的卡丢弃（丢弃兼代价）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,c)
end
-- 定义①效果从卡组送墓的筛选条件：是「廷达魔三角」系列卡、不是「廷达魔三角之结界石」自身、且可以送去墓地。
function c24158464.tgfilter(c)
	return c:IsSetCard(0x10b) and not c:IsCode(24158464) and c:IsAbleToGrave()
end
-- 定义①效果的目标与发动条件：需要己方有可用怪兽区域、这张卡自身可以里侧守备表示特殊召唤、且卡组中存在符合条件的「廷达魔三角」卡。
function c24158464.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有可用的空格，以满足后续特殊召唤条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 检查卡组中是否存在至少1张符合条件的「廷达魔三角」卡（即非「廷达魔三角之结界石」且可送墓）。
		and Duel.IsExistingMatchingCard(c24158464.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果包含从卡组把1张卡送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 登记本次效果包含将这张卡（效果持有者）特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 实际处理①效果：从卡组选1张符合条件的「廷达魔三角」卡送去墓地，若成功且这张卡仍与效果关联，则将其里侧守备表示特殊召唤，并向对方展示。
function c24158464.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示“请选择要送去墓地的卡”，引导玩家选择卡组中的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择1张符合条件的「廷达魔三角」卡作为送去墓地的对象。
	local g=Duel.SelectMatchingCard(tp,c24158464.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认玩家已选择卡、送墓操作成功，且该卡确实进入了墓地，以决定是否继续处理后续特殊召唤。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE)
		-- 确认这张卡仍与效果相关，且能够成功里侧守备表示特殊召唤；若特殊召唤成功则继续后续处理。
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 将里侧守备表示特殊召唤的这张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,c)
	end
end
-- 定义②效果可选卡的筛选条件：是反转怪兽、不是「廷达魔三角之结界石」自身、且能够加入手卡或送去墓地。
function c24158464.filter(c)
	return c:IsType(TYPE_FLIP) and not c:IsCode(24158464) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 定义②效果的目标与发动条件：确认卡组存在符合条件的反转怪兽，并登记效果可能进行的加入手卡或送去墓地操作。
function c24158464.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认卡组中至少存在1只符合条件的反转怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24158464.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次效果可能从卡组将1张卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 登记本次效果可能从卡组将1张卡送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 实际处理②效果：从卡组选择1只符合条件的反转怪兽，并根据情况让玩家选择加入手卡或送去墓地，最终执行并确认。
function c24158464.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示“请选择要操作的卡”，引导玩家选择卡组中的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组中选择1只符合条件的反转怪兽。
	local g=Duel.SelectMatchingCard(tp,c24158464.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 判断选择的卡是否可加入手卡：若只能加入手卡则直接加入手卡；若也可送去墓地，则弹出选项让玩家选择，选择0时加入手卡，否则送去墓地。
		if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选择的卡加入其持有者的手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手卡的卡片展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 当选择的卡不能加入手卡或玩家选择送去墓地时，将其送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
