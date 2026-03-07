--掃除機塊バキューネシア
-- 效果：
-- 「机块」怪兽1只
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。这张卡在连接召唤的回合不能作为连接素材。
-- ①：把1张手卡送去墓地，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡是互相连接状态的场合，以对方的主要怪兽区域1只怪兽为对象才能发动。那只怪兽破坏。
-- ③：这张卡不是互相连接状态的场合，这张卡可以直接攻击。
function c30118200.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要1张以上满足过滤条件的「机块」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x14b),1,1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c30118200.lmlimit)
	c:RegisterEffect(e1)
	-- ①：把1张手卡送去墓地，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30118200,0))  --"丢弃手卡破坏对方1张卡"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,30118200)
	e2:SetCost(c30118200.descost)
	e2:SetTarget(c30118200.destg1)
	e2:SetOperation(c30118200.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡是互相连接状态的场合，以对方的主要怪兽区域1只怪兽为对象才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30118200,1))  --"破坏对方1只怪兽"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,30118200)
	e3:SetCondition(c30118200.descon)
	e3:SetTarget(c30118200.destg2)
	e3:SetOperation(c30118200.desop)
	c:RegisterEffect(e3)
	-- ③：这张卡不是互相连接状态的场合，这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c30118200.dircon)
	c:RegisterEffect(e4)
end
-- 限制此卡在连接召唤的回合不能作为连接素材
function c30118200.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 当此卡不是互相连接状态时可以进行直接攻击
function c30118200.dircon(e)
	return e:GetHandler():GetMutualLinkedGroupCount()==0
end
-- 支付1张手卡送去墓地的代价
function c30118200.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付代价的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张手卡送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置①效果的目标选择处理
function c30118200.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查是否有满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行①效果的破坏处理
function c30118200.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断此卡是否处于互相连接状态
function c30118200.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
-- 过滤函数，判断目标是否在主要怪兽区域
function c30118200.desfilter(c)
	return c:GetSequence()<5
end
-- 设置②效果的目标选择处理
function c30118200.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c30118200.desfilter(chkc) end
	-- 检查是否有满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(c30118200.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方主要怪兽区域的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c30118200.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
