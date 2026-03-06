--インフェルノイド・ベルゼブル
-- 效果：
-- 这张卡不能通常召唤。自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地1只「狱火机」怪兽除外的场合才能从手卡特殊召唤。
-- ①：1回合1次，以对方场上1张表侧表示卡为对象才能发动。那张卡回到手卡。
-- ②：对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
function c26034577.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文：自己场上的效果怪兽的等级·阶级的合计是8以下时，把自己的手卡·墓地1只「狱火机」怪兽除外的场合才能从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c26034577.spcon)
	e2:SetTarget(c26034577.sptg)
	e2:SetOperation(c26034577.spop)
	c:RegisterEffect(e2)
	-- 效果原文：①：1回合1次，以对方场上1张表侧表示卡为对象才能发动。那张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26034577,0))  --"卡片回手"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c26034577.thtg)
	e3:SetOperation(c26034577.thop)
	c:RegisterEffect(e3)
	-- 效果原文：②：对方回合1次，把自己场上1只怪兽解放，以对方墓地1张卡为对象才能发动。那张卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(26034577,1))  --"对方墓地的卡除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCondition(c26034577.rmcon)
	e4:SetCost(c26034577.rmcost)
	e4:SetTarget(c26034577.rmtg)
	e4:SetOperation(c26034577.rmop)
	c:RegisterEffect(e4)
end
-- 检索满足条件的「狱火机」怪兽（必须是怪兽、可除外作为费用、且场上怪兽区有空位）
function c26034577.spfilter(c,tp)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 确保场上怪兽区有空位
		and Duel.GetMZoneCount(tp,c)>0
end
-- 检索满足条件的场上效果怪兽（必须是表侧表示、效果怪兽）
function c26034577.sumfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 获取怪兽的等级或阶级（如果是XYZ怪兽则返回阶级，否则返回等级）
function c26034577.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 判断特殊召唤条件是否满足（场上效果怪兽等级和小于等于8，且手卡或墓地有「狱火机」怪兽可除外）
function c26034577.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有效果怪兽的等级或阶级总和
	local sum=Duel.GetMatchingGroup(c26034577.sumfilter,tp,LOCATION_MZONE,0,nil):GetSum(c26034577.lv_or_rk)
	if sum>8 then return false end
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 检查手卡或墓地是否存在满足条件的「狱火机」怪兽
	return Duel.IsExistingMatchingCard(c26034577.spfilter,tp,loc,0,1,c,tp)
end
-- 选择并设置要除外的「狱火机」怪兽
function c26034577.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local loc=LOCATION_GRAVE+LOCATION_HAND
	if c:IsHasEffect(34822850) then loc=loc+LOCATION_MZONE end
	-- 获取满足条件的「狱火机」怪兽组
	local g=Duel.GetMatchingGroup(c26034577.spfilter,tp,loc,0,c,tp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的除外操作
function c26034577.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽除外（用于特殊召唤）
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 检索满足条件的可返回手牌的卡（必须是表侧表示、可送回手牌）
function c26034577.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 设置回手效果的目标选择逻辑
function c26034577.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c26034577.thfilter(chkc) end
	-- 检查是否存在满足条件的对方场上卡
	if chk==0 then return Duel.IsExistingTarget(c26034577.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的卡作为回手目标
	local g=Duel.SelectTarget(tp,c26034577.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置回手效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行回手效果
function c26034577.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 设置除外效果的发动条件（必须是对方回合）
function c26034577.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 设置除外效果的费用支付逻辑
function c26034577.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择要解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 设置除外效果的目标选择逻辑
function c26034577.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地的卡作为除外目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置除外效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 执行除外效果
function c26034577.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
