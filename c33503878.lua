--魔界台本「ドラマチック・ストーリー」
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只「魔界剧团」灵摆怪兽为对象才能发动。和那只怪兽卡名不同的1只「魔界剧团」怪兽从卡组特殊召唤。那之后，作为对象的怪兽在自己的灵摆区域放置或破坏。
-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。选场上最多2张卡回到持有者手卡。
function c33503878.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只「魔界剧团」灵摆怪兽为对象才能发动。和那只怪兽卡名不同的1只「魔界剧团」怪兽从卡组特殊召唤。那之后，作为对象的怪兽在自己的灵摆区域放置或破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33503878,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,33503878+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c33503878.target)
	e1:SetOperation(c33503878.operation)
	c:RegisterEffect(e1)
	-- ②：自己的额外卡组有表侧表示的「魔界剧团」灵摆怪兽存在，盖放的这张卡被对方的效果破坏的场合才能发动。选场上最多2张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33503878,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c33503878.thcon)
	e2:SetTarget(c33503878.thtg)
	e2:SetOperation(c33503878.thop)
	c:RegisterEffect(e2)
end
-- 过滤可作为①对象的自己场上的表侧表示「魔界剧团」灵摆怪兽，并确认卡组存在另一只卡名不同的可特殊召唤的「魔界剧团」怪兽。
function c33503878.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10ec) and c:IsType(TYPE_PENDULUM)
		-- 检查卡组中是否存在至少1只满足spfilter条件的「魔界剧团」怪兽（与对象卡名不同且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c33503878.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤卡组中可作为特殊召唤对象的「魔界剧团」怪兽：必须是「魔界剧团」、与对象怪兽卡名不同，且能被此效果特殊召唤。
function c33503878.spfilter(c,e,tp,code)
	return c:IsSetCard(0x10ec) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件与取对象处理：确认自己场上有可成为对象的表侧「魔界剧团」灵摆怪兽、主要怪兽区有空位、卡组有可特殊召唤的不同名「魔界剧团」怪兽；发动时选择1只符合条件的对象。
function c33503878.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c33503878.filter(chkc,e,tp) end
	-- 发动时确认自己主要怪兽区是否有空位（特殊召唤需要）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并确认自己场上有1只满足filter条件的「魔界剧团」灵摆怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c33503878.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送选择表侧表示卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足条件的「魔界剧团」灵摆怪兽，并将其设置为效果对象。
	local g=Duel.SelectTarget(tp,c33503878.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：预告知效果处理时将从卡组特殊召唤1只怪兽（用于连锁与卡组区域相关判定）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：若主要怪兽区有空位且对象仍相关且表侧表示，则从卡组选择1只与对象卡名不同的「魔界剧团」怪兽特殊召唤；随后若灵摆区有空位且对象卡不被禁止，则让玩家选择将其放置到灵摆区或将其破坏。
function c33503878.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位，则直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	-- 向玩家发送选择要特殊召唤的卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足spfilter条件的「魔界剧团」怪兽（与对象卡名不同且可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c33503878.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 判断自己的灵摆区域是否有空位，并且对象怪兽没有被禁止（能否放置到灵摆区）。
		if (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and not tc:IsForbidden()
			-- 让玩家选择后续处理方式：当选择选项0（放置到灵摆区域）时条件成立；否则将执行破坏。
			and Duel.SelectOption(tp,aux.Stringid(33503878,2),aux.Stringid(33503878,3))==0 then  --"在灵摆区域放置/破坏"
			-- 中断当前效果处理，使后续的放置处理视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 将对象怪兽移动到自己的灵摆区域，表侧表示放置并立刻适用其效果。
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		else
			-- 中断当前效果处理，使后续的破坏处理视为不同时处理。
			Duel.BreakEffect()
			-- 以效果原因破坏对象怪兽。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 过滤额外卡组中表侧表示的「魔界剧团」灵摆怪兽，用于确认②的发动条件。
function c33503878.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x10ec)
end
-- ②的发动条件：这张卡在场上里侧表示状态下被对方的效果破坏，且自己额外卡组有表侧表示的「魔界剧团」灵摆怪兽。
function c33503878.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
		-- 确认自己的额外卡组存在至少1张表侧表示的「魔界剧团」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c33503878.cfilter,tp,LOCATION_EXTRA,0,1,nil)
end
-- ②发动时的处理：确认场上存在至少1张可以送回手卡的卡，并获取所有可回手的卡用于记录操作信息（效果处理时选择最多2张）。
function c33503878.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认场上存在至少1张可以被送回手卡的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有可以被送回手卡的卡的范围，用于操作信息记录。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：预告知将把场上卡片返回持有者手卡，目标范围为g，至少1张。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：从场上选择最多2张可以被送回手卡的卡（不取对象，处理时选择），将它们返回持有者手卡。
function c33503878.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择要返回手牌的卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1到2张可以被送回手卡的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	if g:GetCount()>0 then
		-- 显示所选择的卡片被选中的动画，并记录这些卡被选为对象（广义）。
		Duel.HintSelection(g)
		-- 将选择的卡以效果原因返回持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
