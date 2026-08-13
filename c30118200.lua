--掃除機塊バキューネシア
-- 效果：
-- 「机块」怪兽1只
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。这张卡在连接召唤的回合不能作为连接素材。
-- ①：把1张手卡送去墓地，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡是互相连接状态的场合，以对方的主要怪兽区域1只怪兽为对象才能发动。那只怪兽破坏。
-- ③：这张卡不是互相连接状态的场合，这张卡可以直接攻击。
function c30118200.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册连接召唤手续，素材为仅1只「机块」怪兽（setcode 0x14b）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x14b),1,1)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(c30118200.lmlimit)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：把1张手卡送去墓地，以对方场上1张卡为对象才能发动。那张卡破坏。
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡是互相连接状态的场合，以对方的主要怪兽区域1只怪兽为对象才能发动。那只怪兽破坏。
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
-- 判断这张卡是否在本回合通过连接召唤特殊召唤，若是则适用不能作为连接素材的限制。
function c30118200.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 判断这张卡是否不是互相连接状态（互相连接状态卡组数为0），用于③的直接攻击条件。
function c30118200.dircon(e)
	return e:GetHandler():GetMutualLinkedGroupCount()==0
end
-- ①效果的发动代价：从手卡将1张卡送去墓地。先检查手卡是否有可用卡，再选择1张并送去墓地。
function c30118200.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost合法性检查时（chk==0），确认自己手卡是否存在至少1张可作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 显示选择提示，提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1张满足代价条件的卡（选择1张送去墓地作为cost）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡送去墓地，作为代价支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的取对象处理：以对方场上1张卡为对象（包括怪兽/魔法/陷阱，表里侧均可），选择后设置破坏该卡的操作信息。
function c30118200.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在取对象检查时（chk==0），确认对方场上是否存在至少1张可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息：将所选择的1张卡破坏（CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①②共用的效果处理：取得效果对象，若该对象仍与效果关联，则将其破坏。
function c30118200.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的第一个对象卡（即效果指定的卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡处于互相连接状态（互相连接状态的卡组数量大于0）。
function c30118200.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
-- 筛选位于对方主要怪兽区域的怪兽（区域序号0-4，不含额外怪兽区）。
function c30118200.desfilter(c)
	return c:GetSequence()<5
end
-- ②效果的取对象处理：选择对方主要怪兽区域的1只怪兽作为对象，并设置破坏该怪兽的操作信息。
function c30118200.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c30118200.desfilter(chkc) end
	-- 在取对象检查时（chk==0），确认对方主要怪兽区域是否存在至少1只可以作为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c30118200.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，提示玩家选择要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方主要怪兽区域选择1只怪兽作为对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c30118200.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：将所选择的1只怪兽破坏（CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
