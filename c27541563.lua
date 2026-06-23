--オルターガイスト・プロトコル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「幻变骚灵」卡的效果的发动以及那些发动的效果不会被无效化。
-- ②：对方把怪兽的效果发动时，把这张卡以外的自己场上1张表侧表示的「幻变骚灵」卡送去墓地才能发动。那个发动无效并破坏。
function c27541563.initial_effect(c)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「幻变骚灵」卡的效果的发动以及那些发动的效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27541563,0))  --"发动但不使用②效果"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果发动时，把这张卡以外的自己场上1张表侧表示的「幻变骚灵」卡送去墓地才能发动。那个发动无效并破坏。
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
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「幻变骚灵」卡的效果的发动以及那些发动的效果不会被无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_INACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetValue(c27541563.effectfilter)
	c:RegisterEffect(e4)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「幻变骚灵」卡的效果的发动以及那些发动的效果不会被无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_DISEFFECT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetValue(c27541563.effectfilter)
	c:RegisterEffect(e5)
end
-- 检查连锁是否为对方怪兽效果发动且可无效
function c27541563.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 对方怪兽效果发动且该连锁可被无效
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 过滤满足条件的「幻变骚灵」卡
function c27541563.discfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103) and c:IsAbleToGraveAsCost() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 选择并把满足条件的「幻变骚灵」卡送去墓地作为代价
function c27541563.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在满足条件的「幻变骚灵」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c27541563.discfilter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「幻变骚灵」卡
	local g=Duel.SelectMatchingCard(tp,c27541563.discfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置连锁处理时的操作信息
function c27541563.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏发动卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行无效发动和破坏操作
function c27541563.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效发动并确认目标卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 判断是否为己方场上的「幻变骚灵」卡发动的效果
function c27541563.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	-- 获取连锁信息中的效果、玩家和位置
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsSetCard(0x103) and bit.band(loc,LOCATION_ONFIELD)~=0
end
