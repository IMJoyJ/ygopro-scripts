--エクスプロードヴァレット・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，双方受到2000伤害。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「爆炸弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
function c31353051.initial_effect(c)
	-- ①：场上的这张卡为对象的连接怪兽的效果发动时才能发动。这张卡破坏。那之后，双方受到2000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31353051,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,31353051)
	e1:SetCondition(c31353051.descon)
	e1:SetTarget(c31353051.destg)
	e1:SetOperation(c31353051.desop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「爆炸弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c31353051.regop)
	c:RegisterEffect(e2)
end
-- 检查连锁效果是否以这张卡为对象且对象为连接怪兽
function c31353051.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- 设置效果处理时的破坏和伤害操作信息
function c31353051.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable() end
	-- 设置将此卡破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置双方各受到2000伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,2000)
end
-- 处理效果发动时的破坏和伤害效果
function c31353051.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡存在于场上且成功破坏
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 给发动者造成2000伤害
		Duel.Damage(tp,2000,REASON_EFFECT,true)
		-- 给对方玩家造成2000伤害
		Duel.Damage(1-tp,2000,REASON_EFFECT,true)
		-- 完成伤害处理时点
		Duel.RDComplete()
	end
end
-- 当此卡因战斗或效果被破坏并送入墓地时，注册结束阶段触发效果
function c31353051.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- ②：场上的这张卡被战斗·效果破坏送去墓地的回合的结束阶段才能发动。从卡组把「爆炸弹丸龙」以外的1只「弹丸」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(31353051,1))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,31353052)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c31353051.sptg)
		e1:SetOperation(c31353051.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数：检查是否为「弹丸」卡组且非本卡，且可特殊召唤
function c31353051.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(31353051) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件
function c31353051.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「弹丸」怪兽
		and Duel.IsExistingMatchingCard(c31353051.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理特殊召唤效果
function c31353051.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「弹丸」怪兽
	local g=Duel.SelectMatchingCard(tp,c31353051.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
