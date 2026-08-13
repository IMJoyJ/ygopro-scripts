--青き眼の幻出
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡也能把手卡1只「青眼白龙」给人观看来发动。那个场合，从手卡把1只怪兽特殊召唤。
-- ②：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽回到持有者手卡。那之后，可以让回到手卡的卡的原本卡名的以下效果适用。
-- ●「青眼白龙」：从手卡把1只怪兽特殊召唤。
-- ●那以外：从手卡把1只「青眼」怪兽特殊召唤。
function c35659410.initial_effect(c)
	-- 注册本卡效果文记载的「青眼白龙」卡号89631139，用于后续判断原本卡名是否为「青眼白龙」。
	aux.AddCodeList(c,89631139)
	-- 这个卡名的卡在1回合只能发动1张。①：这张卡也能把手卡1只「青眼白龙」给人观看来发动。那个场合，从手卡把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35659410+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c35659410.target)
	e1:SetOperation(c35659410.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽回到持有者手卡。那之后，可以让回到手卡的卡的原本卡名的以下效果适用。●「青眼白龙」：从手卡把1只怪兽特殊召唤。●那以外：从手卡把1只「青眼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c35659410.sptg)
	e2:SetOperation(c35659410.spop)
	c:RegisterEffect(e2)
end
-- 定义「青眼白龙」的展示过滤条件：卡名是89631139且当前不是公开状态的卡，用于确认手牌中有未公开的青眼白龙可供展示。
function c35659410.showfilter(c)
	return c:IsCode(89631139) and not c:IsPublic()
end
-- 定义可特殊召唤的怪兽过滤条件：检查手牌中的怪兽是否能被效果正常特殊召唤（满足召唤条件和苏生限制）。
function c35659410.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果1发动时的目标处理：若主怪兽区有空位、手牌存在未公开的青眼白龙和可特召怪兽，且玩家选择展示青眼白龙，则设置Label=1并登记特殊召唤操作信息；否则Label=0，效果处理时不进行特殊召唤。
function c35659410.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查自己场上主要怪兽区是否有空位，用于判断能否从手卡特殊召唤怪兽。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在1张未公开的「青眼白龙」，作为可展示给对方的候选。
		and Duel.IsExistingMatchingCard(c35659410.showfilter,tp,LOCATION_HAND,0,1,nil)
		-- 检查手牌中是否存在1只可以特殊召唤的怪兽，作为展示青眼白龙后从手卡特殊召唤的对象。
		and Duel.IsExistingMatchingCard(c35659410.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 询问玩家“是否展示「青眼白龙」并从手卡特殊召唤怪兽？”，选择是才执行后续展示与特殊召唤流程。
		and Duel.SelectYesNo(tp,aux.Stringid(35659410,0)) then  --"是否展示「青眼白龙」并从手卡特殊召唤怪兽？"
		-- 提示玩家选择一张要展示给对方确认的卡（将选择提示设为“选择给对方确认的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从手牌中选择1张满足展示过滤条件的「青眼白龙」。
		local g=Duel.SelectMatchingCard(tp,c35659410.showfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 将选中的「青眼白龙」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 展示手牌后洗切手牌，以重置手牌的公开状态并隐藏卡组顺序信息。
		Duel.ShuffleHand(tp)
		e:SetLabel(1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 登记操作信息：效果处理时将从手卡把1只怪兽特殊召唤，预定额为1，目标玩家为自己，位置为手牌。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	else
		e:SetLabel(0)
		e:SetCategory(0)
	end
end
-- 效果1处理时的操作：若发动时Label为1（选择了展示青眼白龙），则从手牌选择1只可特殊召唤的怪兽正面表示特殊召唤；否则不做任何处理。
function c35659410.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择1只满足可特殊召唤条件的怪兽。
		local sg=Duel.SelectMatchingCard(tp,c35659410.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			-- 将选择的怪兽以正面表示特殊召唤到自己场上（正常检查召唤条件和苏生限制）。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 定义②效果对象的过滤条件：自己场上表侧表示且可以加入手卡的怪兽，用于选择返回手牌的对象。
function c35659410.thfilter(c)
	return c:IsAbleToHand() and c:IsFaceup()
end
-- 定义「青眼」怪兽的特殊召唤过滤条件：手牌中的怪兽可以被特殊召唤，并且是「青眼」字段（0xdd）的怪兽。
function c35659410.spfilter2(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsSetCard(0xdd)
end
-- ②效果的发动条件与目标选择：检查自己场上是否存在符合条件的表侧表示怪兽，选择其中1只作为对象，并登记返回手牌的操作信息。
function c35659410.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c35659410.thfilter(chkc) end
	-- 发动的合法性检查：自己场上是否存在1只表侧表示且可回手的怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c35659410.thfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只符合条件的表侧表示怪兽作为效果对象（同时自动登记为该连锁的对象）。
	local g=Duel.SelectTarget(tp,c35659410.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记操作信息：将选择的对象卡返回持有者手牌，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：先将对象怪兽返回持有者手卡；若返回成功且该卡在手卡，则根据其原本卡名决定后续效果：原本卡名为「青眼白龙」时，从手卡特殊召唤任意1只怪兽；否则从手卡特殊召唤1只「青眼」怪兽。玩家可选择是否进行后续特殊召唤。
function c35659410.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时登记的第1个对象卡（即被选为返回手牌对象的怪兽）。
	local tc=Duel.GetFirstTarget()
	local code=tc:GetOriginalCode()
	-- 确认对象卡仍然与当前效果关联、仍是表侧表示、成功返回持有者手卡，并且现在位于手卡中，只有满足这些条件才继续处理后续特殊召唤。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 取得手牌中所有可以特殊召唤的怪兽，用于原本卡名为「青眼白龙」时的特召候选。
		local g1=Duel.GetMatchingGroup(c35659410.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if code==89631139 and #g1>0
			-- 若原本卡名是「青眼白龙」且存在可特召怪兽，则询问玩家“是否从手卡特殊召唤怪兽？”，选择是才执行特召。
			and Duel.SelectYesNo(tp,aux.Stringid(35659410,1)) then  --"是否从手卡特殊召唤怪兽？"
			-- 中断当前效果处理，使后续特殊召唤作为另一次效果处理结算，从而错开时点。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg1=g1:Select(tp,1,1,nil)
			-- 将选择的手牌怪兽正面表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 取得手牌中所有可以特殊召唤且是「青眼」字段的怪兽，用于原本卡名不是「青眼白龙」时的特召候选。
		local g2=Duel.GetMatchingGroup(c35659410.spfilter2,tp,LOCATION_HAND,0,nil,e,tp)
		if code~=89631139 and #g2>0
			-- 若原本卡名不是「青眼白龙」且存在可特召的「青眼」怪兽，则询问玩家“是否从手卡特殊召唤怪兽？”，选择是才执行特召。
			and Duel.SelectYesNo(tp,aux.Stringid(35659410,1)) then  --"是否从手卡特殊召唤怪兽？"
			-- 中断当前效果处理，使后续特殊召唤作为另一次效果处理结算，从而错开时点。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg2=g2:Select(tp,1,1,nil)
			-- 将选择的手牌中的「青眼」怪兽正面表示特殊召唤到自己场上。
			Duel.SpecialSummon(sg2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
