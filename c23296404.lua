--イグナイト・アヴェンジャー
-- 效果：
-- ①：以自己场上3张「点火骑士」卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。
-- ②：1回合1次，以这张卡以外的自己场上1只「点火骑士」怪兽为对象才能发动。那张卡回到持有者手卡，选对方场上1张魔法·陷阱卡回到持有者卡组最下面。
function c23296404.initial_effect(c)
	-- ①：以自己场上3张「点火骑士」卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c23296404.sptg)
	e1:SetOperation(c23296404.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以这张卡以外的自己场上1只「点火骑士」怪兽为对象才能发动。那张卡回到持有者手卡，选对方场上1张魔法·陷阱卡回到持有者卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c23296404.tdtg)
	e2:SetOperation(c23296404.tdop)
	c:RegisterEffect(e2)
end
-- 筛选表侧表示且属于「点火骑士」系列的卡。
function c23296404.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc8)
end
-- 筛选表侧表示且属于「点火骑士」系列并能成为效果的对象的卡。
function c23296404.desfilter2(c,e)
	return c23296404.desfilter(c) and c:IsCanBeEffectTarget(e)
end
-- 效果①的目标选择函数：验证发动条件，计算需要额外腾出的怪兽区数量，并检查场上是否存在3张「点火骑士」卡可选取，且这张卡能特殊召唤。
function c23296404.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c23296404.desfilter(chkc) end
	-- 获取自己场上可用怪兽区域的数量，用于判断是否因特召空位不足而需要破坏怪兽区域的卡。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	if chk==0 then return ct<=3 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在至少3张符合条件的「点火骑士」卡（作为破坏对象）。
		and Duel.IsExistingTarget(c23296404.desfilter,tp,LOCATION_ONFIELD,0,3,nil)
		-- 若可用怪兽区不足（ct>0），则还需检查自己怪兽区域是否存在至少ct张符合条件的「点火骑士」卡，以便通过破坏腾出特召区域。
		and (ct<=0 or Duel.IsExistingTarget(c23296404.desfilter,tp,LOCATION_MZONE,0,ct,nil)) end
	local g=nil
	if ct>0 then
		-- 取得自己场上所有满足条件且能成为效果对象的「点火骑士」卡，用于后续选择破坏对象。
		local tg=Duel.GetMatchingGroup(c23296404.desfilter2,tp,LOCATION_ONFIELD,0,nil,e)
		-- 提示玩家选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		g=tg:FilterSelect(tp,Card.IsLocation,ct,ct,nil,LOCATION_MZONE)
		if ct<3 then
			tg:Sub(g)
			-- 提示玩家选择要破坏的卡片（用于追加选择）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local g2=tg:Select(tp,3-ct,3-ct,nil)
			g:Merge(g2)
		end
		-- 将已选择的卡设置为当前连锁的对象，以便效果处理时关联。
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择自己场上3张符合条件的「点火骑士」卡作为效果对象。
		g=Duel.SelectTarget(tp,c23296404.desfilter,tp,LOCATION_ONFIELD,0,3,3,nil)
	end
	-- 设置效果处理中将破坏的卡组信息，数量为3，为后续检测提供依据。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,3,0,0)
	-- 设置效果处理中将特殊召唤这张卡的卡组信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：破坏作为对象的卡，若破坏成功，则将这张卡从手卡特殊召唤。
function c23296404.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象中仍然与效果相关的卡（未被移离等），准备破坏。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若对象卡被效果破坏成功，则继续执行特殊召唤。
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 筛选表侧表示且属于「点火骑士」系列并能加入手卡的怪兽。
function c23296404.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc8) and c:IsAbleToHand()
end
-- 筛选对方场上的魔法·陷阱卡且能够返回卡组的卡。
function c23296404.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 效果②的目标选择函数：验证存在除自身以外的「点火骑士」怪兽可回手，以及对方场上有可回卡组的魔法陷阱，然后选择对象。
function c23296404.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c23296404.thfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己场上是否存在1只除这张卡以外的表侧表示「点火骑士」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c23296404.thfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 检查对方场上是否存在至少1张符合条件的魔法·陷阱卡（用于送回卡组底）。
		and Duel.IsExistingMatchingCard(c23296404.tdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己场上1只除这张卡以外的「点火骑士」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c23296404.thfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置效果处理中将把对象怪兽返回手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果处理中将对方场上的魔法陷阱返回卡组的操作信息，具体卡片在效果处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD)
end
-- 效果②的处理：将对象怪兽返回持有者手牌，若成功，则将对方场上1张魔法·陷阱卡返回持有者卡组最下面。
function c23296404.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关且已成功返回手牌，则继续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 提示玩家选择要返回卡组的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择对方场上1张符合条件的魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,c23296404.tdfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 将选择的卡返回持有者卡组最下面。
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
