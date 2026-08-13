--アネスヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，选场上1只表侧表示怪兽。那只怪兽不能攻击，效果无效化。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「麻醉弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
function c53266486.initial_effect(c)
	-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，选场上1只表侧表示怪兽。那只怪兽不能攻击，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53266486,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,53266486)
	e1:SetCondition(c53266486.descon)
	e1:SetTarget(c53266486.destg)
	e1:SetOperation(c53266486.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c53266486.regop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：当前连锁的效果必须是以场上的这张卡为对象的取对象效果，且该效果的发动者是连接怪兽；满足时才能发动。
function c53266486.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 从连锁信息中取出该效果的对象卡集合，用于判断这张卡是否被选为对象。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- ①效果的发动时点合法性检查：自身可被破坏，且场上存在除自身以外的表侧表示怪兽（供后续选择）。
function c53266486.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable()
		-- 检查场上是否存在至少1只除这张卡以外的表侧表示怪兽，以确保“那之后选场上1只表侧表示怪兽”能够处理。
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 将本次连锁的操作信息登记为破坏这张卡，使后续“这张卡破坏”能够被正确检测和对应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
-- ①效果处理：先破坏这张卡；破坏成功后，选场上1只表侧表示怪兽，令其不能攻击且效果无效化。
function c53266486.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与该效果关联（未被无效或离场导致关系重置），并且实际破坏成功后才继续执行后续选择与无效处理。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 获取场上所有表侧表示怪兽，作为“选场上1只表侧表示怪兽”的选择集合。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()==0 then return end
		-- 中断当前效果处理，使后续选择与无效化处理作为不同的处理（错开时点），避免与破坏同时处理。
		Duel.BreakEffect()
		-- 显示选择提示，要求从表侧表示怪兽中选择1只。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 向双方展示所选择的怪兽，并将其记录为这次效果处理的对象。
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		-- 将该怪兽相关联的连锁效果无效化，直到该怪兽变里侧表示时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_ATTACK)
		tc:RegisterEffect(e4)
	end
end
-- 送墓时的辅助效果（不入连锁）：判断此卡是否因战斗或效果被破坏且从场上送去墓地；若是，则在墓地注册②效果，使②在结束阶段可以发动。
function c53266486.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「麻醉弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(53266486,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,53266487)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c53266486.sptg)
		e1:SetOperation(c53266486.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤的筛选条件：是「弹丸」字段怪兽、不是「麻醉弹丸龙」本身，且可以特殊召唤。
function c53266486.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(53266486) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：我方主要怪兽区有空位，并且卡组中存在符合条件的「弹丸」怪兽。
function c53266486.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的「弹丸」怪兽。
		and Duel.IsExistingMatchingCard(c53266486.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次连锁的操作信息登记为从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只符合条件的「弹丸」怪兽，正面表示特殊召唤到我方主要怪兽区。
function c53266486.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区仍有空格，若已无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组筛选并选择1只符合条件的「弹丸」怪兽。
	local g=Duel.SelectMatchingCard(tp,c53266486.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽正面表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
