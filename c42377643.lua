--うにの軍貫
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡以外的手卡1张「军贯」卡给对方观看才能发动。这张卡从手卡特殊召唤。那之后，给人观看的卡的以下效果适用。
-- ●「舍利军贯」：可以把给人观看的怪兽特殊召唤。
-- ●那以外：给人观看的卡回到卡组最下面。
-- ②：以自己场上1只「军贯」怪兽为对象才能发动。那只怪兽的等级变成4星或者5星。那之后，可以从卡组把1只「舍利军贯」加入手卡。
function c42377643.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把这张卡以外的手卡1张「军贯」卡给对方观看才能发动。这张卡从手卡特殊召唤。那之后，给人观看的卡的以下效果适用。●「舍利军贯」：可以把给人观看的怪兽特殊召唤。●那以外：给人观看的卡回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42377643,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,42377643)
	e1:SetCost(c42377643.spcost)
	e1:SetTarget(c42377643.sptg)
	e1:SetOperation(c42377643.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只「军贯」怪兽为对象才能发动。那只怪兽的等级变成4星或者5星。那之后，可以从卡组把1只「舍利军贯」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42377643,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,42377644)
	e2:SetTarget(c42377643.lvltg)
	e2:SetOperation(c42377643.lvlop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判定一张卡是否属于「军贯」系列（SetCard 0x166）且处于非公开状态，作为①效果中从手卡选择给对方观看的对象的过滤条件。
function c42377643.cfilter(c)
	return c:IsSetCard(0x166) and not c:IsPublic()
end
-- ①效果的代价处理：从手卡选择这张卡以外的1张非公开的「军贯」卡给对方确认，然后洗切手卡，并把选中的卡记录为该效果关联的对象，以便效果处理时根据展示卡的种类发动后续效果。
function c42377643.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：检查手卡中是否存在这张卡以外、满足「军贯」且非公开状态的卡，可作为展示代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c42377643.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择一张手卡用于给对方确认（HINTMSG_CONFIRM 的提示文字）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从自己的手卡中选择1张「军贯」且非公开的卡（不能选这张卡自身）作为展示代价。
	local g=Duel.SelectMatchingCard(tp,c42377643.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 把所选的手卡展示给对方玩家确认，满足『给对方观看』的发动条件。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切自己的手卡，使对方无法根据展示后的手牌位置追踪那张卡。
	Duel.ShuffleHand(tp)
	local tc=g:GetFirst()
	tc:CreateEffectRelation(e)
	e:SetLabelObject(tc)
end
-- ①效果发动时的条件判定：自己主要怪兽区有空位，且这张卡自身可以从手卡被特殊召唤，才可发动。该效果没有取对象。
function c42377643.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有可用的主要怪兽区空格，确保这张卡能从手卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记这个连锁将进行特殊召唤的操作：预定把这张卡（e:GetHandler）特殊召唤1只，处理分类为 CATEGORY_SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：先尝试将这张海胆军贯从手卡特殊召唤；成功后再取出被展示的卡，若展示的是「舍利军贯」则可由玩家选择是否将其特殊召唤，否则将该卡返回卡组最下面。
function c42377643.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍然与效果关联，并且成功特殊召唤到场上；若召唤失败或卡片已不关联则中止后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=e:GetLabelObject()
		if not tc:IsRelateToEffect(e) then return end
		if tc:IsCode(24639891) then
			-- 判断展示的「舍利军贯」是否满足特殊召唤条件且自己场上还有空位，满足才提供是否特殊召唤的选项。
			if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 询问玩家是否把展示的「舍利军贯」怪兽特殊召唤（对应『●「舍利军贯」：可以把给人观看的怪兽特殊召唤』的选择）。
				and Duel.SelectYesNo(tp,aux.Stringid(42377643,2)) then  --"是否把把给人观看的怪兽特殊召唤？"
				-- 中断当前效果处理，使后续的特殊召唤作为另一段处理进行，避免与前面的特殊召唤同属一个时点。
				Duel.BreakEffect()
				-- 将展示的「舍利军贯」以表侧表示特殊召唤到自己的主要怪兽区。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			-- 中断当前效果处理，使随后的回卡组操作作为新的一段处理执行，避免并入前一次特殊召唤的时点。
			Duel.BreakEffect()
			-- 将展示的那张「军贯」卡按效果送回持有者卡组最下面（REASON_EFFECT）。
			Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
-- 过滤条件：判定「军贯」怪兽在我方场上表侧表示且拥有等级（不是超量/连接等无等级怪兽），用作②效果的对象筛选。
function c42377643.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x166) and c:IsLevelAbove(0)
end
-- ②效果发动时的取对象处理：从自己场上选择1只表侧表示的拥有等级的「军贯」怪兽作为对象。
function c42377643.lvltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42377643.filter(chkc) end
	-- 发动判定：自己场上是否存在满足条件的「军贯」怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(c42377643.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择场上表侧表示的符合条件的对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示、属于「军贯」且有等级的怪兽作为效果对象，并登记为连锁对象。
	Duel.SelectTarget(tp,c42377643.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤条件：判定卡组中的卡是否为「舍利军贯」（卡号24639891），且能够加入手卡，用于②效果的追加检索。
function c42377643.thfilter(c)
	return c:IsCode(24639891) and c:IsAbleToHand()
end
-- ②效果处理：如果对象怪兽仍在场上且与效果关联，则根据其当前等级让玩家选择变为4星或5星，给对象怪兽赋予等级变更效果；之后可选择是否从卡组把1只「舍利军贯」加入手卡并展示给对方确认。
function c42377643.lvlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	local sel=0
	if tc:IsLevel(4) then
		-- 对象当前等级为4时，提供唯一选项『变成5星』；Duel.SelectOption返回0，加1后sel=1，随后把等级改为5。
		sel=Duel.SelectOption(tp,aux.Stringid(42377643,4))+1  --"变成5星"
	elseif tc:IsLevel(5) then
		-- 对象当前等级为5时，提供唯一选项『变成4星』；返回0，sel=0，随后把等级改为4。
		sel=Duel.SelectOption(tp,aux.Stringid(42377643,3))  --"变成4星"
	else
		-- 对象等级既不是4也不是5时，让玩家在『变成4星』和『变成5星』两个选项中择一。
		sel=Duel.SelectOption(tp,aux.Stringid(42377643,3),aux.Stringid(42377643,4))  --"变成4星/变成5星"
	end
	-- 那只怪兽的等级变成4星或者5星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	if sel==0 then
		e1:SetValue(4)
	else
		e1:SetValue(5)
	end
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	-- 检查卡组中是否存在1只以上可加入手卡的「舍利军贯」，用于决定是否给出追加检索的选择。
	if Duel.IsExistingMatchingCard(c42377643.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否从卡组把1只「舍利军贯」加入手卡（对应『那之后，可以从卡组把1只「舍利军贯」加入手卡』的选择）。
		and Duel.SelectYesNo(tp,aux.Stringid(42377643,5)) then  --"是否从卡组把「舍利军贯」加入手卡？"
		-- 中断当前效果处理，使随后的检索加入手卡作为新的处理段，避免与等级变更合并时点。
		Duel.BreakEffect()
		-- 提示玩家选择要加入手卡的卡（HINTMSG_ATOHAND）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张「舍利军贯」加入手卡。
		local g=Duel.SelectMatchingCard(tp,c42377643.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选择的「舍利军贯」以效果原因加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的「舍利军贯」展示给对方玩家确认（符合检索后公开牌面信息）。
		Duel.ConfirmCards(1-tp,g)
	end
end
