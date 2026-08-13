--オルターガイスト・プロトコル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「幻变骚灵」卡的效果的发动以及那些发动的效果不会被无效化。
-- ②：对方把怪兽的效果发动时，把这张卡以外的自己场上1张表侧表示的「幻变骚灵」卡送去墓地才能发动。那个发动无效并破坏。
function c27541563.initial_effect(c)
	-- （卡片自身的发动）陷阱卡发动本身，不发动②效果；发动后这张卡在魔法与陷阱区域存在，以适用①效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27541563,0))  --"发动但不使用②效果"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方把怪兽的效果发动时，把这张卡以外的自己场上1张表侧表示的「幻变骚灵」卡送去墓地才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27541563,1))  --"发动并使用②效果"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,27541563)
	e2:SetCondition(c27541563.discon)
	e2:SetCost(c27541563.discost)
	e2:SetTarget(c27541563.distg)
	e2:SetOperation(c27541563.disop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「幻变骚灵」卡的效果的发动不会被无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_INACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetValue(c27541563.effectfilter)
	c:RegisterEffect(e4)
	-- 以及那些发动的效果不会被无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_DISEFFECT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetValue(c27541563.effectfilter)
	c:RegisterEffect(e5)
end
-- ②效果的发动条件判断：对方玩家把怪兽效果发动，且该效果的发动可以被无效化时才满足发动条件。
function c27541563.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定当前连锁的发动者为对方、发动的是怪兽效果、且该连锁可被无效化。
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 定义可供②效果作为代价送去墓地的卡的条件：自己场上的表侧表示「幻变骚灵」卡、可作为代价送去墓地、且不是战斗破坏确定状态的卡。
function c27541563.discfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:IsAbleToGraveAsCost() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果的代价处理：确认存在符合条件的卡时，从自己场上选择这张卡以外的1张表侧表示「幻变骚灵」卡送去墓地作为发动代价。
function c27541563.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价确认（chk==0）：检查自己场上是否存在满足discfilter条件的卡（且不能选择这张协议卡自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(c27541563.discfilter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 显示“请选择要送去墓地的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1张满足discfilter条件的卡（除这张协议卡以外）作为代价。
	local g=Duel.SelectMatchingCard(tp,c27541563.discfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 将选择的卡送去墓地，作为发动②效果的代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果发动时无取对象目标；设定本次处理的操作信息，登记无效对方怪兽效果发动并可能破坏的类别。
function c27541563.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将以当前连锁的对方怪兽效果（eg）作为无效对象，类别为CATEGORY_NEGATE。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若对方发动效果的怪兽可以被破坏且仍与效果关联，则登记破坏该怪兽的操作信息（CATEGORY_DESTROY）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果处理：无效对方怪兽效果的发动，并破坏那只怪兽。
function c27541563.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若对方怪兽效果的发动被成功无效，且其怪兽仍与效果关联，则继续执行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果（REASON_EFFECT）破坏对方发动效果的那只怪兽。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ①效果的保护过滤：判断连锁中的效果是否由自己场上的「幻变骚灵」卡发动（满足条件时其发动/效果不能被无效）。
function c27541563.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	-- 获取当前连锁的触发效果、触发玩家以及触发位置，用于判断是否满足①效果的保护条件。
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsSetCard(0x103) and bit.band(loc,LOCATION_ONFIELD)~=0
end
