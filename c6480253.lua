--フレンドッグ
-- 效果：
-- 这张卡被战斗破坏送去墓地时，从自己墓地选择1张名字带有「元素英雄」的卡以及1张「融合」加入手卡。
function c6480253.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，从自己墓地选择1张名字带有「元素英雄」的卡以及1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6480253,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c6480253.condition)
	e1:SetTarget(c6480253.target)
	e1:SetOperation(c6480253.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：这张卡因战斗破坏送去墓地
function c6480253.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件1：名字带有「元素英雄」且能加入手牌的卡
function c6480253.filter1(c)
	return c:IsSetCard(0x3008) and c:IsAbleToHand()
end
-- 过滤条件2：卡名为「融合」且能加入手牌的卡
function c6480253.filter2(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果发动时的对象选择处理
function c6480253.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	-- 检查自己墓地是否存在至少1张名字带有「元素英雄」的卡
	if Duel.IsExistingTarget(c6480253.filter1,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查自己墓地是否存在至少1张「融合」
		and Duel.IsExistingTarget(c6480253.filter2,tp,LOCATION_GRAVE,0,1,nil) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择自己墓地1张名字带有「元素英雄」的卡作为效果对象
		local g1=Duel.SelectTarget(tp,c6480253.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择自己墓地1张「融合」作为效果对象
		local g2=Duel.SelectTarget(tp,c6480253.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
		g1:Merge(g2)
		-- 设置将2张卡加入手牌的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
	end
end
-- 效果处理：将选择的卡加入手牌并给对方确认
function c6480253.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()==2 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
