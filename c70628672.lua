--レッド・ロイド・コール
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有「机人」融合怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。那之后，从发动的那个玩家的卡组·额外卡组把同名卡全部送去墓地。
-- ②：把墓地的这张卡除外，以自己墓地1只「机人」怪兽为对象才能发动。那只怪兽加入手卡。
function c70628672.initial_effect(c)
	-- ①：自己场上有「机人」融合怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。那之后，从发动的那个玩家的卡组·额外卡组把同名卡全部送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c70628672.condition)
	e1:SetTarget(c70628672.target)
	e1:SetOperation(c70628672.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「机人」怪兽为对象才能发动。那只怪兽加入手卡。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,70628672)
	-- 把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c70628672.thtg)
	e2:SetOperation(c70628672.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「机人」融合怪兽
function c70628672.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x16) and c:IsType(TYPE_FUSION)
end
-- 效果①的发动条件判定
function c70628672.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「机人」融合怪兽
	return Duel.IsExistingMatchingCard(c70628672.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查发动的效果是否为怪兽效果、魔法或陷阱卡的发动，且该发动可以被无效
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 效果①的发动准备与操作信息设置
function c70628672.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：将发动效果的玩家的卡组·额外卡组中的同名卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,rp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果①的处理逻辑
function c70628672.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该连锁的发动，若成功则继续处理
	if Duel.NegateActivation(ev) then
		local cd=re:GetHandler():GetCode()
		-- 获取发动效果的玩家的卡组·额外卡组中与被无效卡同名的所有卡
		local g=Duel.GetMatchingGroup(Card.IsCode,rp,LOCATION_DECK+LOCATION_EXTRA,0,nil,cd)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的送去墓地处理不与无效发动同时进行
			Duel.BreakEffect()
			-- 将同名卡全部送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 过滤条件：自己墓地的「机人」怪兽且能加入手卡
function c70628672.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x16) and c:IsAbleToHand()
end
-- 效果②的对象选择与操作信息设置
function c70628672.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c70628672.thfilter(chkc) end
	-- 检查自己墓地是否存在符合条件的「机人」怪兽
	if chk==0 then return Duel.IsExistingTarget(c70628672.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「机人」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c70628672.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理逻辑
function c70628672.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
