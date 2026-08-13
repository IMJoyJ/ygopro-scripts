--真六武衆－シエン
-- 效果：
-- 战士族调整＋调整以外的「六武众」怪兽1只以上
-- ①：1回合1次，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1只「六武众」怪兽破坏。
function c29981921.initial_effect(c)
	-- 为这张卡添加同调召唤手续：要求素材为1只战士族调整怪兽和1只以上（默认最多99只）调整以外的「六武众」怪兽。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),aux.NonTuner(Card.IsSetCard,0x103d),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29981921,0))  --"魔法陷阱发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c29981921.discon)
	e1:SetTarget(c29981921.distg)
	e1:SetOperation(c29981921.disop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1只「六武众」怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c29981921.desreptg)
	e2:SetOperation(c29981921.desrepop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定：自身没有处于战斗破坏确定状态，且当前连锁的发动者是对方，并且该发动是魔法·陷阱卡的发动且该连锁可以被无效。
function c29981921.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 进一步判断：该连锁的发动者是对方，且发动的是魔法·陷阱卡（卡片发动），并且该连锁的发动可以被无效。
		and ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果①的目标判定：发动时无需取对象，直接允许发动，并登记操作信息：将无效并破坏的对象设为当前连锁的卡（eg）；若该卡能被破坏且仍与效果相关，则一并登记破坏。
function c29981921.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次操作包含“无效发动”，对象为当前连锁上发动的卡（eg），数量1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 登记本次操作还包含“破坏”，对象同样是该连锁上发动的卡（eg），数量1（若该卡可破坏且关联）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果①的处理：无效对方那次魔法·陷阱卡的发动，若无效成功且该卡仍与效果相关，则将其破坏。
function c29981921.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断无效发动是否成功，且对方发动的卡仍与本次效果关联，若成立则执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因本次效果破坏该连锁上发动的魔法·陷阱卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 代替破坏对象的筛选条件：表侧表示的「六武众」怪兽，可被效果破坏，且未处于破坏确定或战斗破坏确定状态。
function c29981921.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x103d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 效果②代破的触发判定：当此卡将被战斗或效果破坏（且不是由代替破坏导致）时，检查自己场上是否存在符合条件的「六武众」怪兽。
function c29981921.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 并且确认自己场上存在至少1张满足 repfilter 条件的「六武众」怪兽（排除此卡自身）。
		and Duel.IsExistingMatchingCard(c29981921.repfilter,tp,LOCATION_MZONE,0,1,c,e) end
	-- 询问玩家是否发动代替破坏效果（选择是/否）。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 向玩家发送‘请选择要代替破坏的卡’的选择提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家从自己场上选择1张满足条件的「六武众」怪兽（不能选此卡自身）作为代破对象。
		local g=Duel.SelectMatchingCard(tp,c29981921.repfilter,tp,LOCATION_MZONE,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代破效果处理：将被选择卡的破坏确定状态清除，然后将其作为代替破坏。
function c29981921.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果破坏并同时标记为“代替破坏”的方式，将被选定的「六武众」怪兽破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
