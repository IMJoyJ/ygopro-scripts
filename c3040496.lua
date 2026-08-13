--混沌魔龍 カオス・ルーラー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只光·暗属性怪兽加入手卡。剩下的卡送去墓地。
-- ②：把这张卡以外的光·暗属性怪兽各1只从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c3040496.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整＋1只以上调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只光·暗属性怪兽加入手卡。剩下的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3040496,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,3040496)
	e1:SetCondition(c3040496.thcon)
	e1:SetTarget(c3040496.thtg)
	e1:SetOperation(c3040496.thop)
	c:RegisterEffect(e1)
	-- ②：把这张卡以外的光·暗属性怪兽各1只从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,3040497)
	e2:SetCost(c3040496.spcost)
	e2:SetTarget(c3040496.sptg)
	e2:SetOperation(c3040496.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：当前效果持有者是否是以同调召唤（SUMMON_TYPE_SYNCHRO）的方式特殊召唤成功。
function c3040496.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义翻开卡组中筛选对象的条件：卡片为光属性或暗属性的怪兽，并且可以加入手卡。
function c3040496.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- ①效果的发动条件检查（目标阶段）：确认自己卡组上方至少有5张卡可以被送去墓地，用于确保效果处理时能完成翻5张的操作。
function c3040496.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：在chk==0（即系统询问效果能否发动）时，返回自己卡组上方是否足够5张卡送去墓地。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) end
end
-- ①效果的处理：翻开自己卡组上方5张卡；若其中存在光·暗属性怪兽且玩家选择加入手卡，则选1只加入手卡并给对方确认，随后洗切手牌；剩下的卡全部送去墓地；若不存在可选怪兽或玩家选择不加入，则5张卡全部送去墓地。
function c3040496.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次确认自己卡组上方仍可送去5张卡，防止因中途卡组数量变化导致无法执行。
	if Duel.IsPlayerCanDiscardDeck(tp,5) then
		-- 将自己卡组上方的5张卡翻开，展示给相关玩家确认。
		Duel.ConfirmDecktop(tp,5)
		-- 获取自己卡组上方5张卡，作为待处理的一组卡片。
		local g=Duel.GetDecktopGroup(tp,5)
		if g:GetCount()>0 then
			-- 禁用系统在从卡组取卡后自动进行洗切卡组的检查，以便后续手动处理洗牌。
			Duel.DisableShuffleCheck()
			-- 检查翻开组中是否存在满足条件的光·暗属性怪兽；若存在，则询问当前玩家是否要选择1只加入手卡。
			if g:IsExists(c3040496.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(3040496,1)) then  --"是否选卡加入手卡？"
				-- 给当前玩家显示选择提示：请选择要加入手牌的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg=g:FilterSelect(tp,c3040496.thfilter,1,1,nil)
				-- 将选中的1只光·暗属性怪兽加入其持有者的手卡。
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 将选出的卡展示给对方玩家确认，表明加入手卡的具体是哪张。
				Duel.ConfirmCards(1-tp,sg)
				-- 洗切当前玩家的手卡，因为向手卡加入卡后手牌顺序可能被系统调整，需要重洗。
				Duel.ShuffleHand(tp)
				g:Sub(sg)
			end
			-- 将翻开的卡组中未被选入的其余卡送去墓地，处理原因为效果且曾被翻开揭示。
			Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
		end
	end
end
-- 定义②效果除外代价的筛选条件：卡片为光属性或暗属性，且可以被除外作为代价。
function c3040496.costfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- ②效果的代价处理：从自己手卡·墓地中，以本卡以外的光属性怪兽和暗属性怪兽各1只为代价，将其表侧表示除外；合法性检查时确认能够选出这样2张卡。
function c3040496.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡·墓地中满足代价条件（光/暗属性且可除外）的怪兽组，并排除这张混沌魔龙自身。
	local g=Duel.GetMatchingGroup(c3040496.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,e:GetHandler())
	-- 代价合法性检查：在当前可选组中确认是否能选出2张卡，分别为1只光属性怪兽和1只暗属性怪兽。
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK) end
	-- 给当前玩家显示选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从符合条件的怪兽中，选择1只光属性和1只暗属性的怪兽（共2只）作为除外代价。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	-- 将选出的2张代价卡以表侧表示除外，作为发动②效果的代价。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- ②效果的发动目标设置：判断这张卡能否从墓地特殊召唤，并登记将进行特殊召唤处理。
function c3040496.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- ②效果发动合法性检查：自己场上是否有可用的怪兽区域，且这张混沌魔龙是否可以被效果特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本次效果将进行的特殊召唤信息（1只怪兽，从墓地特殊召唤），以供后续连锁和判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其从墓地特殊召唤到自己的怪兽区域，并给它附加“从场上离开时除外”的效果；最后完成特殊召唤。
function c3040496.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍然在墓地且与当前效果有联系，然后将其作为特殊召唤处理的一步，以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
	-- 完成本次特殊召唤处理，使暂定的特殊召唤正式生效。
	Duel.SpecialSummonComplete()
end
