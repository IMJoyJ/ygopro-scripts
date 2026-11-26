--深海姫プリマドーナ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：以除外的1张对方的卡为对象才能发动。从卡组把1只4星以下的水属性怪兽加入手卡或特殊召唤，作为对象的卡加入对方手卡。
-- ②：这张卡为同调素材的同调怪兽不会成为对方怪兽的效果的对象。
-- ③：这张卡被送去墓地的场合，以除外的1张自己或者对方的卡为对象才能发动。那张卡回到持有者卡组。
function c50793215.initial_effect(c)
	-- 设置同调召唤条件：需要调整1只＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 调整＋调整以外的怪兽1只以上 这个卡名的①③的效果1回合各能使用1次。 ①：以除外的1张对方的卡为对象才能发动。从卡组把1只4星以下的水属性怪兽加入手卡或特殊召唤，作为对象的卡加入对方手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50793215,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50793215)
	e1:SetTarget(c50793215.thtg)
	e1:SetOperation(c50793215.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡为同调素材的同调怪兽
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
-- 筛选条件：检查卡组中的怪兽是否为4星以下水属性怪兽，且可加入手卡或在己方怪兽区有空位时可特殊召唤
function c50793215.thfilter(c,e,tp,ft)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(4)
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ①效果的发动检测：确认对方除外区有可回手卡的卡且己方卡组有满足条件的水属性怪兽
function c50793215.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取己方主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 发动条件检查（前半）：确认对方除外区存在至少1张可加入手卡的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_REMOVED,1,nil)
		-- 发动条件检查（后半）：确认己方卡组存在可加入手卡或特殊召唤的4星以下水属性怪兽
		and Duel.IsExistingMatchingCard(c50793215.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
	-- 向己方提示选择要使其加入手卡的对方除外区对象卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方从对方除外区选择1张可加入手卡的卡作为当前连锁的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_REMOVED,1,1,nil)
end
-- ①效果的处理流程：从己方卡组选1只4星以下水属性怪兽加入手卡或特殊召唤，若操作成功且对象卡仍在连锁中，则将该对象卡加入对方手卡
function c50793215.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前己方主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 向己方提示选择要从卡组操作的4星以下水属性怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让己方从己方卡组选择1只满足条件的4星以下水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c50793215.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		if sc then
			local res=0
			if ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 判断在可特召条件下是否因无法加入手卡或己方选择特殊召唤分支而执行特殊召唤
				and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
				-- 将选出的4星以下水属性怪兽以表侧表示特殊召唤到己方场上，并记录操作结果
				res=Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			else
				-- 以效果将选出的4星以下水属性怪兽加入己方手卡，并记录操作结果
				res=Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 向对方展示加入手卡的水属性怪兽
				Duel.ConfirmCards(1-tp,sc)
			end
			-- 获取当前连锁所指定的对方除外区对象卡
			local tc=Duel.GetFirstTarget()
			if res~=0 and tc:IsRelateToEffect(e) then
				-- 将作为对象的对方除外区的卡返回持有者（对方）手卡
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			end
		end
	end
end
-- ②效果的触发条件检查：确认这张卡是作为同调召唤的素材被使用的
function c50793215.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- ②效果的处理流程：获取以这张卡为素材同调召唤出的怪兽，为其赋予不会成为对方怪兽效果对象的永续抗性
function c50793215.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 不会成为对方怪兽的效果的对象。
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
-- 抗性生效范围函数：判定仅当效果来自原素材持有者的对方玩家且为怪兽效果时不能成为对象
function c50793215.tgval(e,re,rp)
	return rp==1-e:GetOwnerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
-- ③效果的发动检测、取对象及信息设置：确认双方除外区存在可返回卡组的卡，选择1张作为对象并登记返回卡组操作信息
function c50793215.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToDeck() end
	-- 发动条件检查：确认双方除外区存在至少1张可返回卡组的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 向己方提示选择要返回卡组的除外区卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让己方从双方除外区选择1张可返回卡组的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	-- 登记连锁的返回卡组操作信息，预计将所选对象卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ③效果的处理流程：确认对象卡仍与连锁有联系后，将其返回持有者卡组并洗牌
function c50793215.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁所指定的除外区对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果将对象卡返回原持有者的卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
