--剛鬼ムーンサルト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看，以「刚鬼 月面坠击兔」以外的自己场上1只「刚鬼」怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到持有者手卡。
-- ②：以自己墓地1只「刚鬼」连接怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以从自己墓地选1只「刚鬼」怪兽加入手卡。
function c20191720.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看，以「刚鬼 月面坠击兔」以外的自己场上1只「刚鬼」怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20191720,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,20191720)
	e1:SetCost(c20191720.spcost)
	e1:SetTarget(c20191720.sptg)
	e1:SetOperation(c20191720.spop)
	c:RegisterEffect(e1)
	-- ②：以自己墓地1只「刚鬼」连接怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以从自己墓地选1只「刚鬼」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20191720,1))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,20191721)
	e2:SetTarget(c20191720.tdtg)
	e2:SetOperation(c20191720.tdop)
	c:RegisterEffect(e2)
end
-- 效果发动时，确认手卡的这张卡对对手公开
function c20191720.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤满足条件的怪兽：属于刚鬼卡组、正面表示、能回到手卡、不是刚鬼 月面坠击兔
function c20191720.spfilter(c)
	return c:IsSetCard(0xfc) and c:IsFaceup() and c:IsAbleToHand() and not c:IsCode(20191720)
end
-- 设置效果的取对象条件：选择自己场上满足条件的怪兽作为对象
function c20191720.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c20191720.spfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认自己场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己场上是否有满足条件的怪兽
		and Duel.IsExistingTarget(c20191720.spfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c20191720.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：将对象怪兽返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数：将自身特殊召唤，然后将对象怪兽返回手牌
function c20191720.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取效果的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将对象怪兽返回手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- 过滤满足条件的怪兽：属于刚鬼卡组、是连接怪兽、能回到额外卡组
function c20191720.tdfilter(c)
	return c:IsSetCard(0xfc) and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- 设置效果的取对象条件：选择自己墓地满足条件的怪兽作为对象
function c20191720.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20191720.tdfilter(chkc) end
	-- 确认自己墓地是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c20191720.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c20191720.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将对象怪兽返回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 过滤满足条件的怪兽：属于刚鬼卡组、是怪兽类型、能回到手牌
function c20191720.thfilter(c)
	return c:IsSetCard(0xfc) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理函数：将对象怪兽返回额外卡组，然后从墓地选1只刚鬼怪兽加入手牌
function c20191720.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽是否有效，且已成功返回额外卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		-- 获取满足条件的墓地怪兽组
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c20191720.thfilter),tp,LOCATION_GRAVE,0,nil)
		-- 确认是否有满足条件的怪兽，且玩家选择是否发动
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(20191720,2)) then  --"是否从自己墓地选1只「刚鬼」怪兽加入手卡？"
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的怪兽加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对手确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
