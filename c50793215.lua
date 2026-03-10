--深海姫プリマドーナ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：以除外的1张对方的卡为对象才能发动。从卡组把1只4星以下的水属性怪兽加入手卡或特殊召唤，作为对象的卡加入对方手卡。
-- ②：这张卡为同调素材的同调怪兽不会成为对方怪兽的效果的对象。
-- ③：这张卡被送去墓地的场合，以除外的1张自己或者对方的卡为对象才能发动。那张卡回到持有者卡组。
function c50793215.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：以除外的1张对方的卡为对象才能发动。从卡组把1只4星以下的水属性怪兽加入手卡或特殊召唤，作为对象的卡加入对方手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50793215,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50793215)
	e1:SetTarget(c50793215.thtg)
	e1:SetOperation(c50793215.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡为同调素材的同调怪兽不会成为对方怪兽的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c50793215.tgcon)
	e2:SetOperation(c50793215.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以除外的1张自己或者对方的卡为对象才能发动。那张卡回到持有者卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50793215,1))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,50793216)
	e3:SetTarget(c50793215.tdtg)
	e3:SetOperation(c50793215.tdop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的水属性4星以下怪兽，可加入手牌或特殊召唤
function c50793215.thfilter(c,e,tp,ft)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(4)
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 检查是否满足效果①的发动条件，即场上有对方除外的卡且卡组有符合条件的水属性怪兽
function c50793215.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查是否有对方除外的卡可以作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_REMOVED,1,nil)
		-- 检查卡组中是否存在符合条件的水属性怪兽
		and Duel.IsExistingMatchingCard(c50793215.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择对方除外的一张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_REMOVED,1,1,nil)
end
-- 处理效果①的发动，选择从卡组检索的怪兽并决定其处理方式
function c50793215.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择符合条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c50793215.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		if sc then
			local res=0
			if ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 判断是否优先特殊召唤或加入手牌
				and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
				-- 将选中的怪兽特殊召唤到场上
				res=Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			else
				-- 将选中的怪兽加入手牌
				res=Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 确认对方看到加入手牌的怪兽
				Duel.ConfirmCards(1-tp,sc)
			end
			-- 获取当前连锁的效果对象卡
			local tc=Duel.GetFirstTarget()
			if res~=0 and tc:IsRelateToEffect(e) then
				-- 将对象卡加入对方手牌
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			end
		end
	end
end
-- 判断是否为同调召唤导致的素材化
function c50793215.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 设置效果使同调召唤的怪兽不会成为对方效果的对象
function c50793215.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 设置效果使同调召唤的怪兽不会成为对方效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50793215,2))  --"「深海姬 首席女歌手」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetValue(c50793215.tgval)
	e1:SetOwnerPlayer(ep)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
-- 设定效果值，使对方怪兽的效果无法影响该卡
function c50793215.tgval(e,re,rp)
	return rp==1-e:GetOwnerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
-- 检查是否满足效果③的发动条件，即场上有除外的卡可以作为对象
function c50793215.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToDeck() end
	-- 检查是否有除外的卡可以作为对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择除外的一张卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	-- 设置操作信息，表示将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 处理效果③的发动，将对象卡送回卡组
function c50793215.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送回持有者卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
