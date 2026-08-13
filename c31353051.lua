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
-- ①效果的发动条件：检测到以这张卡为对象的连接怪兽效果发动时才允许发动本效果。
function c31353051.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中对方发动的效果所取的对象卡组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return re:IsActiveType(TYPE_LINK)
end
-- ①效果的发动时需要满足的条件及操作信息设定：此卡可破坏，并设定将破坏此卡、双方受到2000伤害。
function c31353051.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable() end
	-- 设定本次效果处理中包含破坏这张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设定本次效果处理中双方玩家各受到2000伤害的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,2000)
end
-- ①效果处理：若此卡仍与效果关联且破坏成功，则先破坏此卡，再分别给予双方2000伤害。
function c31353051.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡没有被无效或离开过导致与效果失去关联，然后以效果破坏此卡；只有破坏成功才继续后续伤害。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 中断当前效果处理，使后续的伤害视为另一次处理，避免与破坏同时处理。
		Duel.BreakEffect()
		-- 给发动方玩家造成2000点效果伤害。
		Duel.Damage(tp,2000,REASON_EFFECT,true)
		-- 给对方玩家造成2000点效果伤害。
		Duel.Damage(1-tp,2000,REASON_EFFECT,true)
		-- 完成伤害/回复的过程，触发因伤害产生的时点。
		Duel.RDComplete()
	end
end
-- ②效果的诱发注册：当这张卡因战斗或效果被破坏并送去墓地时，在结束阶段设置一个可选发动的特殊召唤效果。
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
-- 从卡组选择满足条件的怪兽：持有「弹丸」字段、不是「爆炸弹丸龙」本身、且能够被特殊召唤。
function c31353051.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and not c:IsCode(31353051) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动条件：自己主要怪兽区有空位，且卡组中存在符合条件的「弹丸」怪兽。满足则设定特殊召唤的操作信息。
function c31353051.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己场上是否有可用的怪兽区区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足 spfilter 条件的「弹丸」怪兽。
		and Duel.IsExistingMatchingCard(c31353051.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设定本次效果处理为从卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若仍有空位，则从卡组选择1只符合条件的「弹丸」怪兽以表侧攻击表示特殊召唤。
function c31353051.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有可用的怪兽区区域，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求玩家从卡组选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选出1只符合条件的「弹丸」怪兽。
	local g=Duel.SelectMatchingCard(tp,c31353051.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
