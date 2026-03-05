--カース・ネクロフィア
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：以除外的3只自己的恶魔族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
-- ②：怪兽区域的这张卡被对方破坏送去墓地的回合的结束阶段发动。这张卡从墓地特殊召唤。那之后，可以选最多有自己场上的魔法·陷阱卡的卡名种类数量的对方场上的卡破坏。
function c14509651.initial_effect(c)
	-- ①：以除外的3只自己的恶魔族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c14509651.splimit)
	c:RegisterEffect(e0)
	-- ②：怪兽区域的这张卡被对方破坏送去墓地的回合的结束阶段发动。这张卡从墓地特殊召唤。那之后，可以选最多有自己场上的魔法·陷阱卡的卡名种类数量的对方场上的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14509651,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,14509651)
	e1:SetTarget(c14509651.sptg1)
	e1:SetOperation(c14509651.spop1)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c14509651.tgop)
	c:RegisterEffect(e2)
	-- ①：以除外的3只自己的恶魔族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14509651,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,14509652)
	e3:SetCondition(c14509651.spcon2)
	e3:SetTarget(c14509651.sptg2)
	e3:SetOperation(c14509651.spop2)
	c:RegisterEffect(e3)
end
-- 限制此卡只能通过效果特殊召唤，不能通常召唤
function c14509651.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 筛选满足条件的除外恶魔族怪兽
function c14509651.spcfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup() and c:IsAbleToDeck()
end
-- 效果①的发动时点处理
function c14509651.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c14509651.spcfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认是否满足选择3只除外恶魔族怪兽的条件
		and Duel.IsExistingTarget(c14509651.spcfilter,tp,LOCATION_REMOVED,0,3,nil) end
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 选择3只除外的恶魔族怪兽作为对象
	local g=Duel.SelectTarget(tp,c14509651.spcfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	-- 设置效果①的处理信息，将3只怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置效果①的处理信息，将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理过程
function c14509651.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取连锁中被选择的对象卡组
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		-- 将对象怪兽送回卡组
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果②的触发条件处理
function c14509651.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp and bit.band(r,REASON_DESTROY)~=0 then
		c:RegisterFlagEffect(14509651,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 效果②的发动条件判断
function c14509651.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(14509651)>0
end
-- 效果②的发动时点处理
function c14509651.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果②的处理信息，将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的处理过程
function c14509651.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将此卡从墓地特殊召唤到场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取己方场上存在的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_SZONE,0,nil)
		local ct=g:GetClassCount(Card.GetCode)
		-- 获取对方场上的所有卡
		local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		-- 判断是否发动破坏效果
		if ct>0 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(14509651,2)) then  --"是否选对方的卡破坏？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=dg:Select(tp,1,ct,nil)
			-- 显示被选为对象的卡
			Duel.HintSelection(sg)
			-- 将选中的卡破坏
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
