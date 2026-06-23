--深海のセントリー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡为让水属性怪兽的效果发动而被送去墓地的场合才能发动。对方选1张手卡直到结束阶段表侧表示除外。
-- ②：这张卡特殊召唤成功的场合，从自己卡组上面把2张卡送去墓地，以「深海哨兵」以外的自己墓地1只4星以下的水属性怪兽为对象才能发动。那只怪兽加入手卡。
function c45483489.initial_effect(c)
	-- ①：这张卡为让水属性怪兽的效果发动而被送去墓地的场合才能发动。对方选1张手卡直到结束阶段表侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45483489,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,45483489)
	e1:SetCondition(c45483489.rmcon)
	e1:SetTarget(c45483489.rmtg)
	e1:SetOperation(c45483489.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，从自己卡组上面把2张卡送去墓地，以「深海哨兵」以外的自己墓地1只4星以下的水属性怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45483489,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,45483490)
	e2:SetCost(c45483489.thcost)
	e2:SetTarget(c45483489.thtg)
	e2:SetOperation(c45483489.thop)
	c:RegisterEffect(e2)
end
-- 效果条件：这张卡因支付费用而送去墓地，且是水属性怪兽的效果被发动
function c45483489.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
-- 效果目标：对方手牌中存在可除外的卡
function c45483489.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌中是否存在可除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil,1-tp) end
	-- 设置连锁操作信息：将对方手牌中一张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- 效果处理：检索对方手牌中可除外的卡并除外，结束后在结束阶段将该卡送回手牌
function c45483489.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方手牌中可除外的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,1-tp)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:Select(1-tp,1,1,nil):GetFirst()
	-- 将选中的卡除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 注册一个在结束阶段触发的效果，用于将除外的卡送回手牌
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(c45483489.retcon)
	e1:SetOperation(c45483489.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
	tc:RegisterFlagEffect(45483489,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
end
-- 判断是否为该效果所除外的卡
function c45483489.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(45483489)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 将卡送回手牌
function c45483489.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将卡送回手牌
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
-- ②效果的费用：自己支付2张卡组最上端的卡送去墓地
function c45483489.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能支付2张卡组最上端的卡作为费用
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
	-- 将自己卡组最上端的2张卡送去墓地
	Duel.DiscardDeck(tp,2,REASON_COST)
end
-- ②效果的过滤函数：筛选4星以下、水属性、非深海哨兵、可加入手牌的怪兽
function c45483489.thfilter(c)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WATER) and not c:IsCode(45483489) and c:IsAbleToHand()
end
-- ②效果的目标选择：选择墓地中的1只符合条件的怪兽
function c45483489.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c45483489.thfilter(chkc) end
	-- 检查墓地中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c45483489.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择墓地中符合条件的1只怪兽
	local g=Duel.SelectTarget(tp,c45483489.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：将选中的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理：将选中的怪兽加入手牌
function c45483489.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
