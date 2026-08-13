--深海姫プリマドーナ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：以除外的1张对方的卡为对象才能发动。从卡组把1只4星以下的水属性怪兽加入手卡或特殊召唤，作为对象的卡加入对方手卡。
-- ②：这张卡为同调素材的同调怪兽不会成为对方怪兽的效果的对象。
-- ③：这张卡被送去墓地的场合，以除外的1张自己或者对方的卡为对象才能发动。那张卡回到持有者卡组。
function c50793215.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（任意）＋1只以上调整以外的怪兽，即通常同调召唤条件。
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
-- 定义①效果的可选择怪兽筛选条件：水属性、4星以下，且能被加入手卡，或在主怪兽区有空位时能被特殊召唤。
function c50793215.thfilter(c,e,tp,ft)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelBelow(4)
		and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ①效果的发动条件与取对象处理：判定对方除外区存在可加入手卡的对象，且自己卡组存在符合条件的怪兽；并从对方除外区选择1张能加入手卡的卡为对象。
function c50793215.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上主怪兽区的可用空格数，用于判断是否能够特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方除外区是否存在至少1张能够加入手卡的卡，作为取对象的前提。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_REMOVED,1,nil)
		-- 检查自己卡组是否存在至少1张满足thfilter的怪兽，作为从卡组加入手卡/特殊召唤的候选。
		and Duel.IsExistingMatchingCard(c50793215.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
	-- 发出“请选择要加入手牌的卡”的选牌提示（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从对方除外区选择1张能够加入手卡的卡作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_REMOVED,1,1,nil)
end
-- ①效果处理：从卡组选择1只符合条件的怪兽，若主怪兽区有空位且玩家选择特殊召唤（或该卡不能加入手卡），则将其特殊召唤；否则将其加入手卡并向对方确认；若处理成功，将对象卡加入对方手卡。
function c50793215.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取自己主怪兽区的可用空格数，用于判断可选特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 发出“请选择要操作的卡”的选牌提示（HINTMSG_OPERATECARD）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组选择1张满足thfilter的水属性4星以下怪兽，用于加入手卡或特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c50793215.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		if sc then
			local res=0
			if ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 判定是否执行特殊召唤：仅当主怪兽区有空位且该卡可以特殊召唤时，若该卡不能加入手卡，或玩家选择了特殊召唤选项，则执行特殊召唤；否则加入手卡。
				and (not sc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
				-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
				res=Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			else
				-- 将选择的怪兽加入持有者的手卡（此处为tp）。
				res=Duel.SendtoHand(sc,nil,REASON_EFFECT)
				-- 向对方玩家展示加入手卡的怪兽卡片。
				Duel.ConfirmCards(1-tp,sc)
			end
			-- 获取①效果发动时选择的对象卡（对方除外区的卡）。
			local tc=Duel.GetFirstTarget()
			if res~=0 and tc:IsRelateToEffect(e) then
				-- 将对象卡加入其持有者的手卡（即对方手卡），完成①效果的后半段。
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
			end
		end
	end
end
-- ②效果的触发条件：这张卡作为同调素材被使用（reason为REASON_SYNCHRO）。
function c50793215.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- ②效果处理：为因此卡作为素材而召唤出的同调怪兽赋予永续效果，使其不会成为对方怪兽效果的对象；同时设置效果提示、持有玩家和重置时机。
function c50793215.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ②：这张卡为同调素材的同调怪兽不会成为对方怪兽的效果的对象。
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
-- 抗性判定函数：当发动效果的玩家是这张卡持有者的对方，且该效果为怪兽效果时，不能以这只怪兽为对象。
function c50793215.tgval(e,re,rp)
	return rp==1-e:GetOwnerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
-- ③效果的发动条件与取对象处理：选择除外区1张自己或对方的能够返回卡组的卡为对象，并设置返回卡组的操作信息。
function c50793215.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToDeck() end
	-- 检查双方除外区是否存在至少1张能够返回卡组的卡，作为③效果的发动前提。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 发出“请选择要返回卡组的卡”的选牌提示（HINTMSG_TODECK）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从双方除外区选择1张能够返回卡组的卡作为③效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	-- 设置本连锁的操作信息：将对象卡返回卡组（CATEGORY_TODECK）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ③效果处理：将对象卡返回持有者卡组并洗切（若该卡仍与效果关联）。
function c50793215.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡返回持有者卡组并洗切（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
