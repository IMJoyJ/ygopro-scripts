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
-- 发动①的代价：确认手卡的这张卡当前未公开，可以履行“给对方观看”的展示代价；若已公开则无法再支付该代价。
function c20191720.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- ①的对象过滤条件：选择自己场上表侧表示的「刚鬼」怪兽，且不是本卡，并且该怪兽能够返回手牌。
function c20191720.spfilter(c)
	return c:IsSetCard(0xfc) and c:IsFaceup() and c:IsAbleToHand() and not c:IsCode(20191720)
end
-- ①的取对象处理：在连锁对象确认时校验对象是否符合条件；在发动判定时确认这张卡自身能被特殊召唤、自己主要怪兽区有空位、且场上存在1只符合条件的「刚鬼」怪兽。
function c20191720.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c20191720.spfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认自己主要怪兽区有空位，用于特殊召唤这张卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己场上存在至少1只满足spfilter条件的「刚鬼」怪兽可以作为对象。
		and Duel.IsExistingTarget(c20191720.spfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示消息，类型为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从自己场上选择1只满足条件的「刚鬼」怪兽，并将其登记为本连锁的效果对象。
	local g=Duel.SelectTarget(tp,c20191720.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本连锁包含将对象怪兽返回手牌的处理，目标为已选的怪兽，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：本连锁包含将这张卡自身特殊召唤的处理，目标为这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①的效果处理：若这张卡仍与效果关联，则将其特殊召唤；特殊召唤成功后，将选择的对象怪兽返回持有者手牌。
function c20191720.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上，若特殊召唤成功则继续后续处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 取得发动时选择的对象怪兽。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将对象怪兽因效果返回持有者手牌。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- ②的对象过滤条件：选择自己墓地中「刚鬼」连接怪兽，且该怪兽能够返回额外卡组。
function c20191720.tdfilter(c)
	return c:IsSetCard(0xfc) and c:IsType(TYPE_LINK) and c:IsAbleToExtra()
end
-- ②的取对象处理：在连锁对象确认时校验对象是否合法；发动判定时确认自己墓地存在符合条件的「刚鬼」连接怪兽；随后让玩家选择对象并设置返回额外卡组的操作信息。
function c20191720.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20191720.tdfilter(chkc) end
	-- 发动判定时确认自己墓地存在至少1只满足tdfilter条件的「刚鬼」连接怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c20191720.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示消息，类型为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1只满足条件的「刚鬼」连接怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c20191720.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本连锁包含将对象怪兽返回额外卡组（回卡组）的处理，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②后续加入手牌效果的过滤条件：选择自己墓地的「刚鬼」怪兽，且该怪兽能够加入手牌。
function c20191720.thfilter(c)
	return c:IsSetCard(0xfc) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②的效果处理：若对象仍与效果关联且成功返回额外卡组，则询问玩家是否从自己墓地选1只「刚鬼」怪兽加入手牌；若选择是，则中断连锁处理，选择并加入手牌，并向对方展示。
function c20191720.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②选择的对象怪兽（墓地中的「刚鬼」连接怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联，将对象返回持有者额外卡组（底层以回卡组并洗牌方式处理），且确认对象已位于额外卡组后才继续后续的加入手牌处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
		-- 获取自己墓地中满足thfilter条件的「刚鬼」怪兽，并通过王家长眠之谷过滤器排除会受其影响的卡，作为可选的加入手牌候选。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c20191720.thfilter),tp,LOCATION_GRAVE,0,nil)
		-- 当存在可加入手牌的候选怪兽时，询问玩家是否要执行“从自己墓地选1只「刚鬼」怪兽加入手卡”的后续效果。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(20191720,2)) then  --"是否从自己墓地选1只「刚鬼」怪兽加入手卡？"
			-- 中断当前效果处理，使后续加入手牌的效果与前段返回额外卡组的处理不同时进行（制造错时点）。
			Duel.BreakEffect()
			-- 向玩家显示选择提示消息，类型为“请选择要加入手牌的卡”。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选择的「刚鬼」怪兽因效果加入持有者手牌。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对方玩家展示这张加入手牌的卡，使其确认。
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
