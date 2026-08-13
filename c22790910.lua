--智の賢者－ヒンメル
-- 效果：
-- 这个卡名在规则上也当作「闪刀」卡使用。这个卡名的①②③的效果1回合各能使用1次。
-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上的连接怪兽为对象的效果由对方发动时，从自己墓地把2张魔法卡除外才能发动。那个效果无效。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，以除外的1张自己的「闪刀」魔法卡为对象才能发动。那张卡加入手卡。
function c22790910.initial_effect(c)
	-- 这个卡名在规则上也当作「闪刀」卡使用。这个卡名的①②③的效果1回合各能使用1次。①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22790910,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,22790910)
	e1:SetCost(c22790910.spcost)
	e1:SetTarget(c22790910.sptg)
	e1:SetOperation(c22790910.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的连接怪兽为对象的效果由对方发动时，从自己墓地把2张魔法卡除外才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22790910,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,22790911)
	e2:SetCondition(c22790910.discon)
	e2:SetCost(c22790910.discost)
	e2:SetTarget(c22790910.distg)
	e2:SetOperation(c22790910.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏送去墓地的场合，以除外的1张自己的「闪刀」魔法卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22790910,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,22790912)
	e3:SetCondition(c22790910.thcon)
	e3:SetTarget(c22790910.thtg)
	e3:SetOperation(c22790910.thop)
	c:RegisterEffect(e3)
end
-- 筛选可作为①效果丢弃代价的卡：必须是魔法卡且可以被丢弃。
function c22790910.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- ①效果的发动代价：确认手卡中存在1张可丢弃的魔法卡，然后从手卡选择1张魔法卡丢弃。
function c22790910.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡中存在1张魔法卡且该卡可以丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c22790910.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手卡选择1张魔法卡丢弃，弃牌原因标记为代价和丢弃。
	Duel.DiscardHand(tp,c22790910.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ①效果发动时可以执行的条件：自己场上有可用怪兽区，且这张卡自身能够被特殊召唤。
function c22790910.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次效果处理的信息为特殊召唤这张卡，用于连锁和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：这张卡仍与效果关联时，将其表侧表示特殊召唤到自己场上。
function c22790910.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 实际将这张卡以表侧表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的判定过滤器：用于确认某张卡是自己场上的连接怪兽且位于主要怪兽区。
function c22790910.tfilter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- ②效果的发动条件：这张卡未被战斗破坏确定，对方发动的效果以取对象方式指定自己场上的连接怪兽，且该连锁效果可以被无效。
function c22790910.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被对方效果指定的对象卡集合。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 综合判断：该连锁效果可被无效、由对方玩家发动、且对象中包含自己场上的连接怪兽，满足时②效果可发动。
	return Duel.IsChainDisablable(ev) and rp==1-tp and tg and tg:IsExists(c22790910.tfilter,1,nil,tp)
end
-- 筛选可作为②效果代价的卡：自己墓地的魔法卡且能够作为代价除外。
function c22790910.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价：确认墓地有至少2张可除外的魔法卡，然后从自己墓地选择2张魔法卡除外。
function c22790910.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己墓地存在至少2张可以除外的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c22790910.rmfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 显示选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2张符合条件的魔法卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c22790910.rmfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的2张魔法卡以表侧表示除外作为代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的发动目标：不取对象，仅需满足条件即可，并登记将对方那个效果无效的信息。
function c22790910.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次操作信息为无效对方效果，对象为当前连锁的那次效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果处理：将对方发动的那个连锁效果无效化。
function c22790910.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际无效对方发动的那次连锁效果。
	Duel.NegateEffect(ev)
end
-- ③效果的发动条件：这张卡被战斗破坏或效果破坏送去墓地。
function c22790910.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 筛选③效果的对象：除外的自己的表侧表示「闪刀」魔法卡，且可以加入手卡。
function c22790910.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ③效果发动时选择对象：从自己除外的卡中选择1张符合条件的「闪刀」魔法卡为对象；同时进行对象合法性检查并设置回手牌操作信息。
function c22790910.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c22790910.thfilter(chkc) end
	-- 检查是否存在至少1张满足条件的除外中的自己的「闪刀」魔法卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c22790910.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 显示选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从除外的自己的卡中选择1张符合条件的「闪刀」魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,c22790910.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置本次操作信息为将选中的卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果处理：将对象卡加入手卡，前提是该对象仍与效果关联。
function c22790910.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
