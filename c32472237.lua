--メタルヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，和这张卡存在过的区域相同纵列的对方的卡全部破坏。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「金属被甲弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
function c32472237.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，和这张卡存在过的区域相同纵列的对方的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32472237,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,32472237)
	e1:SetCondition(c32472237.descon)
	e1:SetTarget(c32472237.destg)
	e1:SetOperation(c32472237.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c32472237.regop)
	c:RegisterEffect(e2)
end
-- 作为①效果的发动条件：检查发动中的连锁效果是否为取对象效果、对象是否包含本卡，且该效果来自连接怪兽；全部满足才允许发动。
function c32472237.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取出当前连锁的效果所取对象的卡片集合，用于确认本卡是否在对象中。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- ①效果的目标处理：取得本卡所在纵列中的对方卡；发动时检查本卡和这些卡是否都能被破坏，并将本卡加入待破坏集合后登记破坏信息。
function c32472237.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	if chk==0 then return c:IsDestructable() and cg:GetCount()>0 end
	cg:AddCard(c)
	-- 将待破坏的卡片组（本卡及同纵列对方卡）及其数量登记到当前连锁信息，表明该效果将执行对这些卡的破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,cg,cg:GetCount(),0,0)
end
-- ①效果的处理：先以效果破坏本卡；若破坏成功，则在那之后以效果破坏同纵列中的对方全部卡。
function c32472237.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	-- 确认本卡仍与发动效果关联，并尝试用效果破坏本卡；只有当破坏成功且存在同纵列对方卡时才继续后续破坏。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 and cg:GetCount()>0 then
		-- 中断当前效果处理，使本卡破坏与后续纵列卡的破坏成为不同时点的处理，以符合‘那之后’的时点关系。
		Duel.BreakEffect()
		-- 以效果破坏同纵列中的对方全部卡片。
		Duel.Destroy(cg,REASON_EFFECT)
	end
end
-- ②效果的登记：当本卡因战斗或效果破坏从场上送去墓地时，在墓地中给本卡注册一个结束阶段才能发动的②效果，并在该结束阶段后重置。
function c32472237.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- 从卡组把「金属被甲弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(32472237,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,32472238)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c32472237.sptg)
		e1:SetOperation(c32472237.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤候选的筛选函数：必须是「弹丸」怪兽、不是「金属被甲弹丸龙」自身，且满足可被当前效果特殊召唤的条件。
function c32472237.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(32472237) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件确认：仅有主要怪兽区存在空位且卡组中存在至少1只符合条件的「弹丸」怪兽时才可发动。
function c32472237.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查我方主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1只满足 spfilter 条件的「弹丸」怪兽。
		and Duel.IsExistingMatchingCard(c32472237.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次效果将执行特殊召唤，来源为我方卡组，预定数量1只（具体卡片在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：确认主要怪兽区有空位后，从卡组选择1只符合条件的「弹丸」怪兽，以表侧攻击表示特殊召唤到我方场上。
function c32472237.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认我方主要怪兽区仍有空位；若无空位则整个特殊召唤处理不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，提示玩家从卡组选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从我方卡组选择1张满足 spfilter 条件的「弹丸」怪兽，选择结果作为待特殊召唤的卡片组 g。
	local g=Duel.SelectMatchingCard(tp,c32472237.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「弹丸」怪兽以表侧攻击表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
