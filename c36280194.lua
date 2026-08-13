--補充要員
-- 效果：
-- 自己的墓地的怪兽卡5张以上存在时才能发动。最多选择3张自己的墓地效果怪兽以外的攻击力1500以下的怪兽卡加入手卡。
function c36280194.initial_effect(c)
	-- 自己的墓地的怪兽卡5张以上存在时才能发动。最多选择3张自己的墓地效果怪兽以外的攻击力1500以下的怪兽卡加入手卡。
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
-- 发动条件判定函数：检查自己墓地是否存在至少5张怪兽卡，作为“补充要员”的发动前提。
function c36280194.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地中是否存在5张以上（含5张）的怪兽卡，满足发动条件。
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,5,nil,TYPE_MONSTER)
end
-- 定义可选卡片筛选条件：该卡必须是攻击力1500以下的怪兽卡，且不是效果怪兽，并且能够被加入手卡。
function c36280194.filter(c)
	return c:IsAttackBelow(1500) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT) and c:IsAbleToHand()
end
-- 发动时选择对象：从自己墓地选择1~3张满足筛选条件的怪兽卡作为效果对象，并登记加入手牌的操作信息；同时处理对象卡的合法性检查（chkc分支）和可发动性检查。
function c36280194.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36280194.filter(chkc) end
	-- 在发动时确认自己墓地是否存在至少1张满足筛选条件的怪兽卡，以判断效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(c36280194.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1~3张满足筛选条件的怪兽卡，并将其设为连锁的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c36280194.filter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 将本次连锁的处理信息登记为“将上述数量的卡加入手牌”，供相关效果检测或后续处理使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理函数：从连锁信息中取出对象卡，筛选出仍与该效果相关的卡片，将其加入持有者手牌，并让对方确认。
function c36280194.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将筛选后的对象卡以效果原因加入持有者手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认本次加入手牌的卡片。
		Duel.ConfirmCards(1-tp,sg)
	end
end
