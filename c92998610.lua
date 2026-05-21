--孤高除獣
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤时，从手卡把1只怪兽除外才能发动。种族和除外的怪兽相同的1只怪兽从卡组除外。
-- ②：这张卡被战斗或者对方的效果破坏的场合，以自己的除外状态的1只怪兽为对象才能发动。那只怪兽加入手卡。
function c92998610.initial_effect(c)
	-- ①：这张卡召唤时，从手卡把1只怪兽除外才能发动。种族和除外的怪兽相同的1只怪兽从卡组除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92998610,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,92998610)
	e1:SetCost(c92998610.cost)
	e1:SetTarget(c92998610.target)
	e1:SetOperation(c92998610.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗或者对方的效果破坏的场合，以自己的除外状态的1只怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,92998611)
	e2:SetCondition(c92998610.thcon)
	e2:SetTarget(c92998610.thtg)
	e2:SetOperation(c92998610.thop)
	c:RegisterEffect(e2)
end
-- 效果①的Cost函数，设置Label为100以标记Cost检测通过
function c92998610.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤手牌中可作为Cost除外的怪兽，且卡组中存在同种族的怪兽
function c92998610.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查卡组中是否存在与该手牌怪兽同种族且可除外的怪兽
		and Duel.IsExistingMatchingCard(c92998610.tgfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤卡组中与除外怪兽种族相同且可除外的卡片
function c92998610.tgfilter(c,rc)
	return c:IsAbleToRemove() and c:IsRace(rc:GetRace())
end
-- 效果①的Target（发动准备）函数，处理Cost除外手牌并声明卡组除外操作
function c92998610.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查手牌中是否存在满足Cost条件的怪兽
		return Duel.IsExistingMatchingCard(c92998610.cfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c92998610.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabelObject(g:GetFirst())
	-- 将选择的手牌怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 设置效果处理信息：从卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的Operation（效果处理）函数，从卡组除外1只与Cost除外怪兽同种族的怪兽
function c92998610.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rc=e:GetLabelObject()
	-- 让玩家从卡组选择1只与Cost除外怪兽同种族的怪兽
	local g=Duel.SelectMatchingCard(tp,c92998610.tgfilter,tp,LOCATION_DECK,0,1,1,nil,rc)
	if g:GetCount()>0 then
		-- 将选择的卡组怪兽表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡被战斗破坏，或者由对方的效果破坏且原控制者为自己
function c92998610.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 过滤除外状态中表侧表示的、可以加入手牌的怪兽
function c92998610.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果②的Target（发动准备）函数，选择除外状态的1只怪兽作为对象
function c92998610.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c92998610.filter(chkc) end
	-- 检查除外状态是否存在可作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c92998610.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外状态的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c92998610.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息：将选中的对象卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的Operation（效果处理）函数，将作为对象的怪兽加入手牌
function c92998610.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
