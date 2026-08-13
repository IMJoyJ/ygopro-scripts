--ホロウヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，从对方卡组上面把最多6张卡翻开，从那之中选1张除外，剩余用原本的顺序回到卡组上面。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「空尖弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
local s,id,o=GetID()
-- 创建并注册两个效果：e1为①效果的诱发即时效果（破坏自身并除外对方卡组卡），e2为②效果的送墓触发效果（在满足条件时于结束阶段注册特殊召唤效果）。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，从对方卡组上面把最多6张卡翻开，从那之中选1张除外，剩余用原本的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外卡组"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：检测发动中的效果是否为取对象的连接怪兽效果，且对象包含这张卡；若满足则允许发动。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 从连锁信息中获取当前发动效果所选择的对象卡集合。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- ①效果的发动时点合法性检查：确认自身可被破坏、对方卡组顶有卡且那1张卡可被除外；同时设置后续处理所需的除外与破坏操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取对方卡组最上方1张卡，用于检查是否存在可除外的卡。
	local g=Duel.GetDecktopGroup(1-tp,1)
	if chk==0 then return c:IsDestructable() and g:GetCount()>0 and g:GetFirst():IsAbleToRemove(tp) end
	-- 设置效果处理信息：从对方卡组除外1张卡（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
	-- 设置效果处理信息：破坏这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
-- ①效果的处理：先破坏自身；若破坏成功，则从对方卡组顶翻开最多6张卡（由发动者选择数量，至少1），确认后从中选1张除外，其余按原顺序放回卡组顶。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与当前连锁相关，并以效果将其破坏；若破坏成功（返回>0）才继续执行后续除外处理。
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 获取对方卡组当前的卡数量，用于限制最多翻开的张数不超过6。
		local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
		if ct>5 then ct=6 end
		if ct>1 then
			-- 获取对方卡组顶1张卡，检查其是否可被除外；若不可除外则无法进行后续“选1张除外”的处理。
			local cg=Duel.GetDecktopGroup(1-tp,1)
			if not cg:GetFirst():IsAbleToRemove(tp) then
				return
			end
			local tbl={}
			for i=1,ct do
				table.insert(tbl,i)
			end
			-- 显示选择提示，让发动者选择要翻开的卡的数量。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要翻开的卡的数量"
			-- 让发动者宣言一个数字（1到当前上限），作为实际翻开的卡数量。
			ct=Duel.AnnounceNumber(tp,table.unpack(tbl))
		end
		-- 中断当前效果处理，使后续的翻开与除外处理成为独立的效果处理段，避免错过时点。
		Duel.BreakEffect()
		-- 将对方卡组顶ct张卡展示给双方确认。
		Duel.ConfirmDecktop(1-tp,ct)
		-- 获取对方卡组顶ct张卡，作为待选择除外的候选集合。
		local g=Duel.GetDecktopGroup(1-tp,ct)
		-- 显示选择提示，让发动者从翻开的卡中选择要除外的1张卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 开启从卡组顶选择卡片的展示流程（用于选择除外卡）。
		Duel.RevealSelectDeckSequence(true)
		local sg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp)
		-- 结束从卡组顶选择卡片的展示流程。
		Duel.RevealSelectDeckSequence(false)
		if #sg>0 then
			-- 禁用下一次操作的洗牌检测，确保将剩余卡按原顺序放回卡组顶后不触发洗切。
			Duel.DisableShuffleCheck(true)
			-- 将选择的1张卡以表侧表示除外。
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- 送墓时的触发处理：若这张卡被战斗或效果破坏且从场上送去墓地，则在墓地注册一个结束阶段可发动的特殊召唤效果。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「空尖弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,id+o)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(s.sptg)
		e1:SetOperation(s.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤的过滤条件：卡名属于「弹丸」系列、不是「空尖弹丸龙」自身、且能够被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件检查：我方主要怪兽区域有空位，且卡组中存在符合条件的「弹丸」怪兽可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认我方主要怪兽区域存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中存在至少1张满足特殊召唤条件的「弹丸」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若主要怪兽区仍有空位，则从卡组选择1只符合条件的「弹丸」怪兽以表侧表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方主要怪兽区域没有空格，则特殊召唤处理失败并直接返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，让发动者选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张符合条件的「弹丸」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到我方场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
