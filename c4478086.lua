--クロック・スパルトイ
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「电脑网融合」加入手卡。
-- ②：这张卡所连接区有怪兽特殊召唤的场合，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
function c4478086.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只电子界族怪兽作为连接素材（对应效果原文'电子界族怪兽2只'）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡连接召唤成功的场合才能发动。从卡组把1张「电脑网融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4478086,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,4478086)
	e1:SetCondition(c4478086.thcon)
	e1:SetTarget(c4478086.thtg)
	e1:SetOperation(c4478086.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡所连接区有怪兽特殊召唤的场合，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4478086,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,4478087)
	e2:SetCondition(c4478086.spcon)
	e2:SetTarget(c4478086.sptg)
	e2:SetOperation(c4478086.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡是连接召唤成功的场合。
function c4478086.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤器：选择卡组中卡名为「电脑网融合」且能被加入手卡的卡。
function c4478086.thfilter(c)
	return c:IsCode(65801012) and c:IsAbleToHand()
end
-- ①效果的发动时点判定与操作信息登记：检查卡组是否存在「电脑网融合」，并登记从卡组将1张卡加入手卡的操作信息。
function c4478086.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：我方卡组存在至少1张卡名为「电脑网融合」且满足thfilter条件的卡时，效果才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c4478086.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：将本效果标记为从卡组检索1张卡加入手卡，便于其他卡进行对应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时：从卡组选择1张「电脑网融合」加入手卡，并让对方确认。
function c4478086.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示框，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己卡组中选择1张满足thfilter的卡（即「电脑网融合」）。
	local g=Duel.SelectMatchingCard(tp,c4478086.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：判断一张卡是否位于这张卡所连接的区域（通过连接区域组lg进行包含判断）。
function c4478086.cfilter(c,lg)
	return lg:IsContains(c)
end
-- ②效果的发动条件：本次特殊召唤成功的怪兽中存在被特殊召唤到这张卡所连接区域的怪兽。
function c4478086.spcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c4478086.cfilter,1,nil,lg)
end
-- ②效果的对象选择过滤：从自己墓地选择1只4星以下、电子界族、可以表侧表示特殊召唤的怪兽。
function c4478086.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ②效果的发动时点判定：若chkc指定卡，则检查该卡是否是自己墓地中满足filter的电子界族怪兽；若chk==0则检查墓地是否存在可对象化的满足条件怪兽以及自己场上是否有可用怪兽区域。
function c4478086.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4478086.filter(chkc,e,tp) end
	-- 发动合法性检查：自己墓地存在至少1只满足filter条件且可以作为效果对象的电子界族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c4478086.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 且自己场上存在可用的怪兽区域，用于后续特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 弹出选择提示框，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足filter的电子界族怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c4478086.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本效果将会对选择的对象进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理时：将对象怪兽特殊召唤并使其效果无效；之后给这张卡的控制者附加直到回合结束不能从额外卡组特殊召唤融合怪兽以外怪兽的自肃效果。
function c4478086.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时当前连锁的第一个对象卡（即选中的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关联，则将其以表侧表示进行特殊召唤（作为特殊召唤处理的一步）。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽效果无效特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤处理，将之前通过SpecialSummonStep暂时特殊召唤的怪兽正式确定上场，并触发召唤成功时点。
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c4478086.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给这张卡的控制者tp，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃效果的过滤：不能特殊召唤的卡是位于额外卡组且不是融合怪兽的卡。
function c4478086.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
