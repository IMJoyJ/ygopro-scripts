--カース・ネクロフィア
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：以除外的3只自己的恶魔族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
-- ②：怪兽区域的这张卡被对方破坏送去墓地的回合的结束阶段发动。这张卡从墓地特殊召唤。那之后，可以选最多有自己场上的魔法·陷阱卡的卡名种类数量的对方场上的卡破坏。
function c14509651.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c14509651.splimit)
	c:RegisterEffect(e0)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以除外的3只自己的恶魔族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
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
	-- 怪兽区域的这张卡被对方破坏送去墓地的回合的
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c14509651.tgop)
	c:RegisterEffect(e2)
	-- ②：怪兽区域的这张卡被对方破坏送去墓地的回合的结束阶段发动。这张卡从墓地特殊召唤。那之后，可以选最多有自己场上的魔法·陷阱卡的卡名种类数量的对方场上的卡破坏。
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
-- 验证特殊召唤是否由动作类效果（EFFECT_TYPE_ACTIONS）引发，从而限制此卡只能通过卡的效果发动来特殊召唤。
function c14509651.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 作为①效果对象候选的过滤器：选择除外区表侧表示的、属于自己且能够返回卡组的恶魔族怪兽。
function c14509651.spcfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsFaceup() and c:IsAbleToDeck()
end
-- ①效果的发动条件检查与取对象：确认此卡可以特殊召唤、自己主要怪兽区有空位、除外区存在至少3只符合条件的恶魔族怪兽，若满足则选择3只作为对象。
function c14509651.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c14509651.spcfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认自己场上主要怪兽区存在可用空格，以保证此卡能够特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少3只满足条件的自己的恶魔族怪兽，作为①效果的对象候选。
		and Duel.IsExistingTarget(c14509651.spcfilter,tp,LOCATION_REMOVED,0,3,nil) end
	-- 向玩家显示选择提示消息“请选择要返回卡组的卡”，引导玩家选择要返回卡组的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己除外区的符合条件的恶魔族怪兽中选出3张，并将它们登记为当前效果的对象。
	local g=Duel.SelectTarget(tp,c14509651.spcfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	-- 设置操作信息：声明要将3张对象卡返回卡组，供后续效果处理和互动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置操作信息：声明要将手卡中的此卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：先确认此卡仍与效果关联；然后将其从手卡特殊召唤；成功后，将仍与效果关联的对象卡返回持有者卡组并洗切。
function c14509651.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将此卡以表侧表示特殊召唤到自己的主要怪兽区；返回值非0表示特殊召唤成功。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 从当前连锁信息中取得效果对象卡组，并筛选出仍与当前效果关联的对象（已离场或失去联系的对象被排除）。
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
		-- 将筛选出的对象怪兽返回持有者卡组并洗切，实现“作为对象的怪兽回到卡组”。
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 该连续效果用于记录②效果的前置条件：当怪兽区域的此卡被对方破坏并送去墓地时，为其打上保留到结束阶段的标记，供②效果发动条件判定。
function c14509651.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp and bit.band(r,REASON_DESTROY)~=0 then
		c:RegisterFlagEffect(14509651,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- ②效果的发动条件：此卡在墓地且带有“本回合被对方破坏送去墓地”的标记时，结束阶段可以发动。
function c14509651.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(14509651)>0
end
-- ②效果的目标处理：无需选择对象，直接设置为将墓地中的此卡特殊召唤；发动条件检查通过即返回true。
function c14509651.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：声明要将墓地中的此卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果处理：先确认此卡仍与效果关联并成功从墓地特殊召唤；之后若自己场上有表侧魔陷且对方场上有卡，则询问玩家是否进行破坏，并根据自己场上魔陷卡名种类数选择对方场上的卡破坏。
function c14509651.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与②效果关联，且尝试从墓地特殊召唤成功；只有成功后才会执行后续破坏处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 取得自己场上全部表侧表示的魔法·陷阱卡，用于计算卡名种类数量。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_SZONE,0,nil)
		local ct=g:GetClassCount(Card.GetCode)
		-- 取得对方场上的所有卡（怪兽区域和魔法陷阱区域），作为可被选择破坏的对象范围。
		local dg=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		-- 当自己场上魔陷卡名种类数大于0且对方场上有卡时，询问玩家是否选择破坏对方场上的卡，只有选择“是”才继续处理破坏。
		if ct>0 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(14509651,2)) then  --"是否选对方的卡破坏？"
			-- 中断当前效果处理，使接下来的破坏处理与之前的特殊召唤处理不再视为同一时点，符合“那之后”的时间顺序。
			Duel.BreakEffect()
			-- 向玩家显示选择提示消息“请选择要破坏的卡”，引导玩家选择要破坏的对象。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=dg:Select(tp,1,ct,nil)
			-- 为最终选定的破坏对象显示被选择的动画，并记录这些卡被选择为对象。
			Duel.HintSelection(sg)
			-- 将选定的对方场上的卡以效果破坏（REASON_EFFECT）破坏。
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
