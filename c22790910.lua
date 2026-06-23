--智の賢者－ヒンメル
-- 效果：
-- 这个卡名在规则上也当作「闪刀」卡使用。这个卡名的①②③的效果1回合各能使用1次。
-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上的连接怪兽为对象的效果由对方发动时，从自己墓地把2张魔法卡除外才能发动。那个效果无效。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，以除外的1张自己的「闪刀」魔法卡为对象才能发动。那张卡加入手卡。
function c22790910.initial_effect(c)
	-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
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
-- 过滤函数，用于判断手卡中是否存在可丢弃的魔法卡
function c22790910.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 检查手卡是否存在满足条件的魔法卡，若存在则丢弃1张魔法卡作为费用
function c22790910.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c22790910.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1张满足条件的魔法卡
	Duel.DiscardHand(tp,c22790910.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 检查是否满足特殊召唤条件，包括场地上有空位且自身可特殊召唤
function c22790910.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场地上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c22790910.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于判断场上是否存在己方的连接怪兽
function c22790910.tfilter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判断连锁是否可被无效，且对象为己方连接怪兽
function c22790910.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断连锁是否可被无效且对象为己方连接怪兽
	return Duel.IsChainDisablable(ev) and rp==1-tp and tg and tg:IsExists(c22790910.tfilter,1,nil,tp)
end
-- 过滤函数，用于判断墓地中是否存在可除外的魔法卡
function c22790910.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
-- 检查墓地是否存在满足条件的魔法卡，若存在则选择2张除外作为费用
function c22790910.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c22790910.rmfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择2张满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c22790910.rmfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置无效效果的处理信息
function c22790910.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 执行无效效果操作
function c22790910.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的效果无效
	Duel.NegateEffect(ev)
end
-- 判断此卡是否因战斗或效果破坏而送入墓地
function c22790910.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤函数，用于判断除外的卡是否为己方「闪刀」魔法卡
function c22790910.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置从除外区选择「闪刀」魔法卡的处理信息
function c22790910.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c22790910.thfilter(chkc) end
	-- 检查除外区是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c22790910.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张满足条件的魔法卡
	local g=Duel.SelectTarget(tp,c22790910.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置将卡加入手牌的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行将卡加入手牌的操作
function c22790910.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
