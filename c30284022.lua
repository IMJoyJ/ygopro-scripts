--暗黒界の傀儡
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以双方墓地的卡合计最多3张为对象才能发动。那些卡除外。那之后，从手卡选1只恶魔族怪兽丢弃。
-- ②：自己主要阶段把墓地的这张卡除外，以除外的1只自己的恶魔族怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c30284022.initial_effect(c)
	-- ①：以双方墓地的卡合计最多3张为对象才能发动。那些卡除外。那之后，从手卡选1只恶魔族怪兽丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30284022,0))  --"双方墓地除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,30284022+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c30284022.rmtg)
	e1:SetOperation(c30284022.rmop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以除外的1只自己的恶魔族怪兽为对象才能发动。那只怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30284022,1))  --"回收除外的怪兽"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 效果发动时，若此卡已在墓地则不能发动，用于限制效果发动的条件
	e2:SetCondition(aux.exccon)
	-- 效果发动时，需要将此卡从场上除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c30284022.thtg)
	e2:SetOperation(c30284022.thop)
	c:RegisterEffect(e2)
end
-- 用于筛选手牌中可丢弃的恶魔族怪兽的过滤函数
function c30284022.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FIEND) and c:IsDiscardable(REASON_EFFECT)
end
-- 效果发动时的处理函数，用于判断是否满足发动条件
function c30284022.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 判断是否在双方墓地中存在至少1张可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
		-- 判断是否在自己手牌中存在至少1张可丢弃的恶魔族怪兽
		and Duel.IsExistingMatchingCard(c30284022.rmfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1至3张双方墓地的卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	-- 设置效果处理时要除外的卡组及数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	-- 设置效果处理时要丢弃的手牌数量
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果发动时的处理函数，执行除外和丢弃操作
function c30284022.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的除外对象卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 判断被选择的卡组是否有效且成功除外
	if #tg>0 and Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)>0
		-- 判断自己手牌是否大于0
		and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
		-- 中断当前效果处理，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 从手牌中丢弃1张恶魔族怪兽
		Duel.DiscardHand(tp,c30284022.rmfilter,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	end
end
-- 用于筛选可加入手牌的恶魔族怪兽的过滤函数
function c30284022.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FIEND) and c:IsAbleToHand() and c:IsFaceup()
end
-- 效果发动时的处理函数，用于判断是否满足发动条件
function c30284022.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c30284022.thfilter(chkc) end
	-- 判断是否在自己除外区中存在至少1张可加入手牌的恶魔族怪兽
	if chk==0 then return Duel.IsExistingTarget(c30284022.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张自己除外区的恶魔族怪兽作为对象
	local g=Duel.SelectTarget(tp,c30284022.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理时要加入手牌的卡组及数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动时的处理函数，执行将怪兽加入手牌的操作
function c30284022.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
