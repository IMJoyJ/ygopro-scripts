--奇跡の代行者 ジュピター
-- 效果：
-- ①：1回合1次，从自己墓地把1只「代行者」怪兽除外，以自己场上1只天使族·光属性怪兽为对象才能发动。那只自己的天使族·光属性怪兽的攻击力直到回合结束时上升800。
-- ②：1回合1次，从手卡丢弃1只天使族怪兽，以除外的1只自己的天使族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在场上有「天空的圣域」存在的场合才能发动和处理。
function c28573958.initial_effect(c)
	-- 将「天空的圣域」（卡号56433456）加入本卡的代码列表，用于识别本卡上记载的这张卡名。
	aux.AddCodeList(c,56433456)
	-- ①：1回合1次，从自己墓地把1只「代行者」怪兽除外，以自己场上1只天使族·光属性怪兽为对象才能发动。那只自己的天使族·光属性怪兽的攻击力直到回合结束时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28573958,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c28573958.atcost)
	e1:SetTarget(c28573958.attg)
	e1:SetOperation(c28573958.atop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从手卡丢弃1只天使族怪兽，以除外的1只自己的天使族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在场上有「天空的圣域」存在的场合才能发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28573958,1))  --"除外怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c28573958.spcon)
	e2:SetCost(c28573958.spcost)
	e2:SetTarget(c28573958.sptg)
	e2:SetOperation(c28573958.spop)
	c:RegisterEffect(e2)
end
-- 筛选自己墓地中满足「代行者」字段且可以作为发动代价除外的怪兽。
function c28573958.cfilter1(c)
	return c:IsSetCard(0x44) and c:IsAbleToRemoveAsCost()
end
-- 效果①的代价处理：检查自己墓地存在符合条件的「代行者」怪兽，让玩家选择1张并表侧表示除外作为发动代价。
function c28573958.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价合法性检查（chk==0）时，确认自己墓地存在至少1只符合「代行者」字段且可作为代价除外的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28573958.cfilter1,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发出选择提示，要求选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只符合代价条件的「代行者」怪兽。
	local g=Duel.SelectMatchingCard(tp,c28573958.cfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外，作为效果发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 筛选自己场上表侧表示的天使族・光属性怪兽。
function c28573958.filter1(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
end
-- 效果①的取对象处理：从自己场上选择1只表侧表示的天使族・光属性怪兽作为效果对象。
function c28573958.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c28573958.filter1(chkc) end
	-- 在发动合法性检查时，确认自己场上存在至少1只可作为对象的天使族・光属性表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c28573958.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发出选择提示，要求选择要提升攻击力的表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只表侧表示的天使族・光属性怪兽，并将其设为当前连锁的对象。
	Duel.SelectTarget(tp,c28573958.filter1,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理：获取对象怪兽，若其仍表侧表示且与效果存在关联，则使其攻击力上升800直到回合结束，且赋予该提升效果不可被无效的性质。
function c28573958.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只自己的天使族·光属性怪兽的攻击力直到回合结束时上升800。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：场上存在「天空的圣域」时才能发动。
function c28573958.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前场上是否有卡号56433456（「天空的圣域」）生效。
	return Duel.IsEnvironment(56433456)
end
-- 筛选手卡中满足天使族且可以丢弃的卡。
function c28573958.cfilter2(c)
	return c:IsRace(RACE_FAIRY) and c:IsDiscardable()
end
-- 效果②的代价处理：检查手卡存在可丢弃的天使族怪兽，并丢弃1张作为发动代价。
function c28573958.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价合法性检查时，确认手卡存在至少1张可丢弃的天使族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c28573958.cfilter2,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1张天使族怪兽，作为效果的发动代价（代价+丢弃）。
	Duel.DiscardHand(tp,c28573958.cfilter2,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选除外区中表侧表示、天使族・光属性、且能被当前效果特殊召唤的自己的怪兽。
function c28573958.filter2(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的取对象处理：确认自己主要怪兽区有空位，并从除外区选择1只符合条件的怪兽作为对象。
function c28573958.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c28573958.filter2(chkc,e,tp) end
	-- 在发动合法性检查时，确认自己主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认除外区存在至少1只符合条件的天使族・光属性怪兽可作为效果对象。
		and Duel.IsExistingTarget(c28573958.filter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向玩家发出选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己除外区选择1只符合条件的怪兽，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c28573958.filter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本次连锁将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理：处理时再次确认「天空的圣域」在场，获取对象怪兽并确认关联后，将其表侧表示特殊召唤到自己的主要怪兽区。
function c28573958.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若「天空的圣域」不在场上存在，则本次处理不适用（直接结束）。
	if not Duel.IsEnvironment(56433456) then return end
	-- 获取效果②选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
