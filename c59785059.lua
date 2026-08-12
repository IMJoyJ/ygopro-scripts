--イグナイト・スティンガー
-- 效果：
-- ①：以自己场上3张「点火骑士」卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。
-- ②：1回合1次，以这张卡以外的自己场上1只「点火骑士」怪兽为对象才能发动。那张卡回到持有者手卡，选对方场上1只怪兽回到持有者卡组最下面。
function c59785059.initial_effect(c)
	-- ①：以自己场上3张「点火骑士」卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c59785059.sptg)
	e1:SetOperation(c59785059.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以这张卡以外的自己场上1只「点火骑士」怪兽为对象才能发动。那张卡回到持有者手卡，选对方场上1只怪兽回到持有者卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c59785059.tdtg)
	e2:SetOperation(c59785059.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「点火骑士」卡
function c59785059.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc8)
end
-- 过滤条件：场上表侧表示且可以成为效果对象的「点火骑士」卡
function c59785059.desfilter2(c,e)
	return c59785059.desfilter(c) and c:IsCanBeEffectTarget(e)
end
-- 效果①的发动准备与对象选择（处理特殊召唤所需的怪兽区域空格与破坏对象判定）
function c59785059.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c59785059.desfilter(chkc) end
	-- 获取自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	if chk==0 then return ct<=3 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在至少3张可以成为对象的「点火骑士」卡
		and Duel.IsExistingTarget(c59785059.desfilter,tp,LOCATION_ONFIELD,0,3,nil)
		-- 若特殊召唤需要腾出怪兽区域，则检查怪兽区域中是否存在足够数量的可以成为对象的「点火骑士」卡
		and (ct<=0 or Duel.IsExistingTarget(c59785059.desfilter,tp,LOCATION_MZONE,0,ct,nil)) end
	local g=nil
	if ct>0 then
		-- 获取自己场上所有可以成为效果对象的「点火骑士」卡
		local tg=Duel.GetMatchingGroup(c59785059.desfilter2,tp,LOCATION_ONFIELD,0,nil,e)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		g=tg:FilterSelect(tp,Card.IsLocation,ct,ct,nil,LOCATION_MZONE)
		if ct<3 then
			tg:Sub(g)
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local g2=tg:Select(tp,3-ct,3-ct,nil)
			g:Merge(g2)
		end
		-- 将选定的卡片组设为效果的对象
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择自己场上3张「点火骑士」卡作为对象
		g=Duel.SelectTarget(tp,c59785059.desfilter,tp,LOCATION_ONFIELD,0,3,3,nil)
	end
	-- 设置连锁信息：包含破坏3张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,3,0,0)
	-- 设置连锁信息：包含特殊召唤这张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理（破坏对象并特殊召唤自身）
function c59785059.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与该效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 破坏作为对象的卡，若成功破坏至少1张
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		-- 将这张卡从手卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：场上表侧表示且能回到手牌的「点火骑士」怪兽
function c59785059.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc8) and c:IsAbleToHand()
end
-- 效果②的发动准备与对象选择（选择自己场上的「点火骑士」怪兽，并确认对方场上有可回卡组的怪兽）
function c59785059.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c59785059.thfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己场上是否存在除这张卡以外、可以成为对象且能回到手牌的「点火骑士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c59785059.thfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 并检查对方场上是否存在可以回到卡组的怪兽
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要加入手牌（回到手牌）的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己场上1只「点火骑士」怪兽作为对象
	local g=Duel.SelectTarget(tp,c59785059.thfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置连锁信息：包含将对象怪兽送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置连锁信息：包含将对方场上1只怪兽送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_MZONE)
end
-- 效果②的处理（对象怪兽回到手牌，对方场上1只怪兽回到卡组最下面）
function c59785059.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与该效果相关，且成功回到持有者手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家选择对方场上1只可以回到卡组的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil)
		-- 将选择的对方怪兽送回持有者卡组最下面
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
