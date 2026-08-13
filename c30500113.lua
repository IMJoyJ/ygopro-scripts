--RR－リターン
-- 效果：
-- 「急袭猛禽-归来」的②的效果1回合只能使用1次。
-- ①：自己场上的「急袭猛禽」怪兽被战斗破坏的场合，以自己墓地1只「急袭猛禽」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：自己场上的「急袭猛禽」怪兽被效果破坏的场合，把墓地的这张卡除外才能发动。从卡组把1张「急袭猛禽」卡加入手卡。
function c30500113.initial_effect(c)
	-- ①：自己场上的「急袭猛禽」怪兽被战斗破坏的场合，以自己墓地1只「急袭猛禽」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c30500113.condition)
	e1:SetTarget(c30500113.target)
	e1:SetOperation(c30500113.activate)
	c:RegisterEffect(e1)
	-- 「急袭猛禽-归来」的②的效果1回合只能使用1次。②：自己场上的「急袭猛禽」怪兽被效果破坏的场合，把墓地的这张卡除外才能发动。从卡组把1张「急袭猛禽」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,30500113)
	e2:SetCondition(c30500113.thcon)
	-- 设置②效果的发动COST：将墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c30500113.thtg)
	e2:SetOperation(c30500113.thop)
	c:RegisterEffect(e2)
end
-- ①效果的筛选条件：判定被战斗破坏的卡是否为「急袭猛禽」怪兽且被破坏前的控制者是己方。
function c30500113.cfilter1(c,tp)
	return c:IsSetCard(0xba) and c:IsPreviousControler(tp)
end
-- ①效果的发动条件：本连锁被破坏的怪兽中存在至少1只满足cfilter1的己方「急袭猛禽」怪兽（即己方场上的「急袭猛禽」怪兽被战斗破坏）。
function c30500113.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c30500113.cfilter1,1,nil,tp)
end
-- ①效果的对象筛选条件：墓地中的「急袭猛禽」怪兽且可以被加入手卡。
function c30500113.filter(c)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果发动时：选择自己墓地1只符合条件的「急袭猛禽」怪兽作为对象，并设置为回手牌的操作信息。
function c30500113.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30500113.filter(chkc) end
	-- 发动时合法性检查：确认墓地存在至少1只可以作为对象的「急袭猛禽」怪兽（且能被加入手卡）。
	if chk==0 then return Duel.IsExistingTarget(c30500113.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家显示选择提示：选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己墓地选择1张符合条件的「急袭猛禽」怪兽，将其指定为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c30500113.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本连锁的处理信息：将对象卡加入手卡，数量为1，对象为已选择的g。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果结算：取得对象怪兽，若仍与效果关联则将其加入手卡。
function c30500113.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象怪兽（第一张目标卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象怪兽以效果原因送回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的筛选条件：判定被破坏的怪兽是否为「急袭猛禽」怪兽，且因效果破坏、破坏前在己方场上表侧表示。
function c30500113.cfilter2(c,tp)
	return c:IsSetCard(0xba) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP)
end
-- ②效果的发动条件：本连锁被破坏的怪兽中存在至少1只满足cfilter2的己方表侧「急袭猛禽」怪兽；若本卡自身也在破坏集合中则不能发动（因为本卡不是怪兽，不属于触发源）。
function c30500113.thcon(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsContains(e:GetHandler()) then return false end
	return eg:IsExists(c30500113.cfilter2,1,nil,tp)
end
-- ②效果的检索筛选条件：卡组中的「急袭猛禽」卡（不限怪兽/魔陷）且可以被加入手卡。
function c30500113.thfilter(c)
	return c:IsSetCard(0xba) and c:IsAbleToHand()
end
-- ②效果发动时：确认卡组存在符合条件的「急袭猛禽」卡，设置不取对象的检索回手牌操作信息。
function c30500113.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认卡组中至少存在1张符合条件的「急袭猛禽」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c30500113.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的处理信息：从卡组将1张「急袭猛禽」卡加入手卡（不取对象，故targets为nil，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果结算：从卡组选择1张符合条件的「急袭猛禽」卡加入手卡，并向对方展示。
function c30500113.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示：选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「急袭猛禽」卡（不取对象，在效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c30500113.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
