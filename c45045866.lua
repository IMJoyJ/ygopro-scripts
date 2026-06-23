--オーシャンズ・オーパー
-- 效果：
-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。这张卡被战斗破坏的场合，从自己卡组把1只「千眼卵鱼」或「母脑鱼」加入手卡。
function c45045866.initial_effect(c)
	-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	-- 这张卡被战斗破坏的场合，从自己卡组把1只「千眼卵鱼」或「母脑鱼」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45045866,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetTarget(c45045866.target)
	e2:SetOperation(c45045866.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检索满足条件的卡片组
function c45045866.filter(c)
	return c:IsCode(81434470,18828179) and c:IsAbleToHand()
end
-- 设置连锁处理时的操作信息，指定将要从卡组检索1张「千眼卵鱼」或「母脑鱼」加入手牌
function c45045866.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息，包含要处理的卡组类型和数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌的操作
function c45045866.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张「千眼卵鱼」或「母脑鱼」
	local g=Duel.SelectMatchingCard(tp,c45045866.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被送入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
