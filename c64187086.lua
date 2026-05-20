--地縛神の復活
-- 效果：
-- 丢弃1张手卡发动。选择自己墓地存在的1只名字带有「地缚神」的怪兽和1张场地魔法卡加入手卡。
function c64187086.initial_effect(c)
	-- 丢弃1张手卡发动。选择自己墓地存在的1只名字带有「地缚神」的怪兽和1张场地魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c64187086.cost)
	e1:SetTarget(c64187086.target)
	e1:SetOperation(c64187086.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理：丢弃1张手卡
function c64187086.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃1张手卡作为发动的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件1：自己墓地中名字带有「地缚神」的怪兽且能加入手卡
function c64187086.filter1(c)
	return c:IsSetCard(0x1021) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤条件2：自己墓地中的场地魔法卡且能加入手卡
function c64187086.filter2(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 效果的目标选择（Target）处理
function c64187086.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动阶段（chk==0）检查自己墓地是否存在满足条件1的「地缚神」怪兽
	if chk==0 then return Duel.IsExistingTarget(c64187086.filter1,tp,LOCATION_GRAVE,0,1,nil)
		-- 并且检查自己墓地是否存在满足条件2的场地魔法卡
		and Duel.IsExistingTarget(c64187086.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只名字带有「地缚神」的怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c64187086.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张场地魔法卡作为效果对象
	local g2=Duel.SelectTarget(tp,c64187086.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息：将这2张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果处理（Operation）函数：将选择的对象卡加入手卡
function c64187086.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍与效果关联的对象卡加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
