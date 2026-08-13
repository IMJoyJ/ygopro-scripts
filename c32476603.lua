--シルバーヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，把对方的额外卡组确认，那之内的1张除外。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「银色弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
function c32476603.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，把对方的额外卡组确认，那之内的1张除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32476603,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,32476603)
	e1:SetCondition(c32476603.descon)
	e1:SetTarget(c32476603.destg)
	e1:SetOperation(c32476603.desop)
	c:RegisterEffect(e1)
	-- 场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c32476603.regop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：当以场上的这张卡为对象的连接怪兽效果发动时，满足条件（该效果为取对象效果、连锁对象包含此卡且发动效果者为连接怪兽）才可发动。
function c32476603.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果所选择的对象卡组，用于判断对象中是否包含此卡。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- ①效果的发动条件判定与发动信息登记：确认此卡能够被破坏且对方额外卡组有可除外的卡，并登记破坏此卡、除外对方额外卡组1张卡的操作信息。
function c32476603.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取对方额外卡组中当前可以被除外的所有卡，用于判定是否存在可除外的卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return c:IsDestructable() and g:GetCount()>0 end
	-- 登记本连锁的破坏操作信息：要破坏的对象为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 登记本连锁的除外操作信息：可能被除外的对象为对方额外卡组所有可除外的卡，预计数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果的处理：此卡仍与效果关联时将其破坏；若破坏成功，则确认对方额外卡组，从中选1张除外，之后洗切对方额外卡组。
function c32476603.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方额外卡组的全部卡片。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	-- 检查发动效果的这张卡仍与效果关联（可被破坏），且通过效果成功破坏此卡，并确认对方额外卡组有卡存在。
	if e:GetHandler():IsRelateToEffect(e) and Duel.Destroy(e:GetHandler(),REASON_EFFECT)>0 and g:GetCount()>0 then
		-- 中断当前效果处理，使此卡破坏与后续的除外处理视为不同时处理，避免错误时点。
		Duel.BreakEffect()
		-- 向当前玩家确认对方额外卡组中的所有卡片。
		Duel.ConfirmCards(tp,g)
		-- 弹出选择提示，要求玩家从已确认的对方额外卡组中选择1张要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local tg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
		if tg:GetCount()>0 then
			-- 将选中的卡以表侧表示从额外卡组除外，除外原因记为效果。
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
		-- 洗切对方的额外卡组，因为除外操作导致卡组顺序变化。
		Duel.ShuffleExtra(1-tp)
	end
end
-- ②效果的登记：这张卡被战斗或效果破坏并送去墓地的场合，在墓地中注册一个在回合结束阶段发动的选发效果。
function c32476603.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- 这个卡名的①②的效果1回合各能使用1次。②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「银色弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(32476603,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,32476604)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c32476603.sptg)
		e1:SetOperation(c32476603.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤的候选卡过滤条件：卡名属于「弹丸」字段、不是「银色弹丸龙」，且满足特殊召唤条件。
function c32476603.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(32476603) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：自己场上有可用怪兽区，且卡组存在符合条件的「弹丸」怪兽。
function c32476603.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足特殊召唤条件的「弹丸」怪兽（不取对象）。
		and Duel.IsExistingMatchingCard(c32476603.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本连锁将进行的特殊召唤操作信息：预计从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若自己场上仍有空位，从卡组选择1只符合条件的「弹丸」怪兽以表侧表示特殊召唤。
function c32476603.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区是否有空位，若无空位则效果处理不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家从卡组选择1只要特殊召唤的「弹丸」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选取1张满足条件的「弹丸」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c32476603.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上，不额外检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
