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
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「麻醉弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c53266486.regop)
	c:RegisterEffect(e2)
end
-- 检查连锁效果是否以自身为对象且对象类型为连接怪兽
function c53266486.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- 判断是否满足发动条件：自身可被破坏且场上存在表侧表示怪兽
function c53266486.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable()
		-- 场上存在表侧表示怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 设置效果处理信息：将自身破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
-- 发动效果：破坏自身并选择场上一只表侧表示怪兽使其不能攻击且效果无效
function c53266486.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自身在效果处理中且成功破坏
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 检索场上所有表侧表示怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()==0 then return end
		-- 中断当前连锁处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 提示玩家选择一张表侧表示的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 显示所选怪兽被作为对象的效果动画
		Duel.HintSelection(sg)
		local tc=sg:GetFirst()
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效化
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
-- 检查是否满足发动条件：自身因战斗或效果破坏并送入墓地
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
-- 过滤函数：判断是否为「弹丸」卡且非本卡并可特殊召唤
function c53266486.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(53266486) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理信息：从卡组特殊召唤一只「弹丸」怪兽
function c53266486.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：己方场上存在空位且卡组存在符合条件的「弹丸」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 卡组存在符合条件的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(c53266486.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤一只「弹丸」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 发动效果：从卡组特殊召唤一只「弹丸」怪兽
function c53266486.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择一张要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张符合条件的「弹丸」怪兽
	local g=Duel.SelectMatchingCard(tp,c53266486.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将所选怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
