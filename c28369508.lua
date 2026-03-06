--サブテラーマリスの潜伏
-- 效果：
-- ①：从自己墓地把1只「地中族」怪兽除外才能发动。直到回合结束时，自己场上的里侧表示怪兽不会被效果破坏，不会成为对方的效果的对象。
-- ②：场上的这张卡被效果破坏的场合才能发动。从卡组把1只「地中族」怪兽加入手卡。
-- ③：把墓地的这张卡除外，以自己场上1只「地中族」怪兽为对象才能发动。那只怪兽变成里侧守备表示。
function c28369508.initial_effect(c)
	-- ①：从自己墓地把1只「地中族」怪兽除外才能发动。直到回合结束时，自己场上的里侧表示怪兽不会被效果破坏，不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c28369508.cost)
	e1:SetOperation(c28369508.activate)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被效果破坏的场合才能发动。从卡组把1只「地中族」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c28369508.thcon)
	e2:SetTarget(c28369508.thtg)
	e2:SetOperation(c28369508.thop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外，以自己场上1只「地中族」怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28369508,0))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE+TIMING_BATTLE_PHASE)
	-- 将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c28369508.postg)
	e3:SetOperation(c28369508.posop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查自己墓地是否存在1只「地中族」怪兽且能除外
function c28369508.cfilter(c)
	return c:IsSetCard(0xed) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的处理：检查自己墓地是否存在1只「地中族」怪兽且能除外，若存在则选择1只除外
function c28369508.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在1只「地中族」怪兽且能除外
	if chk==0 then return Duel.IsExistingMatchingCard(c28369508.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c28369508.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将所选卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动时的处理：使自己场上的里侧表示怪兽不会被效果破坏，不会成为对方的效果的对象
function c28369508.activate(e,tp,eg,ep,ev,re,r,rp)
	-- ①：从自己墓地把1只「地中族」怪兽除外才能发动。直到回合结束时，自己场上的里侧表示怪兽不会被效果破坏，不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(c28369508.tgfilter)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果：使自己场上的里侧表示怪兽不会被效果破坏
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置效果值：使自己场上的里侧表示怪兽不会成为对方的效果的对象
	e2:SetValue(aux.tgoval)
	-- 注册效果：使自己场上的里侧表示怪兽不会成为对方的效果的对象
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数：判断目标怪兽是否为里侧表示且在场上
function c28369508.tgfilter(e,c)
	return c:IsFacedown() and c:IsLocation(LOCATION_MZONE)
end
-- 效果发动条件：确认此卡因效果被破坏且之前在场上
function c28369508.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：检查卡组是否存在1只「地中族」怪兽且能加入手牌
function c28369508.thfilter(c)
	return c:IsSetCard(0xed) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的处理：检查卡组是否存在1只「地中族」怪兽且能加入手牌
function c28369508.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在1只「地中族」怪兽且能加入手牌
	if chk==0 then return Duel.IsExistingMatchingCard(c28369508.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：准备从卡组将1只「地中族」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理：选择1只「地中族」怪兽加入手牌并确认
function c28369508.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c28369508.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认所选卡加入手牌
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：检查自己场上是否存在1只「地中族」表侧表示怪兽且能变为里侧守备表示
function c28369508.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xed) and c:IsCanTurnSet()
end
-- 效果发动时的处理：选择1只「地中族」怪兽变为里侧守备表示
function c28369508.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c28369508.filter(chkc) end
	-- 检查自己场上是否存在1只「地中族」表侧表示怪兽且能变为里侧守备表示
	if chk==0 then return Duel.IsExistingTarget(c28369508.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择1只满足条件的怪兽
	local g=Duel.SelectTarget(tp,c28369508.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：准备将1只怪兽变为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果发动时的处理：将所选怪兽变为里侧守备表示
function c28369508.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
