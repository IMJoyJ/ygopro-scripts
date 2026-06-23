--補充要員
-- 效果：
-- 自己的墓地的怪兽卡5张以上存在时才能发动。最多选择3张自己的墓地效果怪兽以外的攻击力1500以下的怪兽卡加入手卡。
function c36280194.initial_effect(c)
	-- 创建效果，设置为发动时点，需要选择对象，效果分类为回手牌
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c36280194.condition)
	e1:SetTarget(c36280194.target)
	e1:SetOperation(c36280194.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：自己墓地存在5张以上怪兽卡
function c36280194.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少5张怪兽卡
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,5,nil,TYPE_MONSTER)
end
-- 过滤函数：选择攻击力1500以下、怪兽类型、非效果怪兽且可以加入手牌的卡
function c36280194.filter(c)
	return c:IsAttackBelow(1500) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT) and c:IsAbleToHand()
end
-- 设置效果目标，允许选择1到3张符合条件的墓地怪兽卡
function c36280194.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36280194.filter(chkc) end
	-- 检查是否至少存在1张符合条件的墓地怪兽卡
	if chk==0 then return Duel.IsExistingTarget(c36280194.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1到3张符合条件的墓地怪兽卡作为效果对象
	local g=Duel.SelectTarget(tp,c36280194.filter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置效果操作信息，指定将选择的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理函数，将符合条件的卡加入手牌并确认对方查看
function c36280194.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将符合条件的卡以效果原因送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认查看送入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
