--融合再生機構
-- 效果：
-- ①：1回合1次，丢弃1张手卡才能发动。从自己的卡组·墓地选1张「融合」加入手卡。
-- ②：自己·对方的结束阶段，以这个回合融合召唤使用过的自己墓地1只融合素材怪兽为对象才能发动。那只怪兽加入手卡。
function c22829942.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，丢弃1张手卡才能发动。从自己的卡组·墓地选1张「融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22829942,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c22829942.thcost)
	e2:SetTarget(c22829942.thtg)
	e2:SetOperation(c22829942.thop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的结束阶段，以这个回合融合召唤使用过的自己墓地1只融合素材怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(22829942,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c22829942.thtg2)
	e3:SetOperation(c22829942.thop2)
	c:RegisterEffect(e3)
end
-- 支付1张手卡丢弃的代价
function c22829942.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足支付1张手卡丢弃的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行1张手卡丢弃的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索过滤器：卡片编号为24094653且能加入手牌
function c22829942.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果发动时的处理：确认卡组或墓地是否存在满足条件的卡片
function c22829942.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或墓地是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c22829942.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息：将1张卡从卡组或墓地加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：选择并把符合条件的卡加入手牌
function c22829942.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡组或墓地的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c22829942.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果2的过滤器：卡片为融合召唤使用的素材怪兽且在本回合被加入墓地
function c22829942.thfilter2(c,id)
	return c:GetReason()&(REASON_FUSION+REASON_MATERIAL)==(REASON_FUSION+REASON_MATERIAL) and c:IsType(TYPE_MONSTER) and c:GetTurnID()==id and c:IsAbleToHand()
end
-- 效果2发动时的处理：选择并确定目标
function c22829942.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前回合数
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22829942.thfilter2(chkc,tid) end
	-- 检查是否存在满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c22829942.thfilter2,tp,LOCATION_GRAVE,0,1,nil,tid) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectTarget(tp,c22829942.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil,tid)
	-- 设置连锁操作信息：将1只怪兽从墓地加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果2处理：将目标怪兽加入手牌
function c22829942.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
