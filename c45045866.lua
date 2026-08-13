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
-- 筛选出卡组中卡名为「千眼卵鱼」或「母脑鱼」且能被加入手卡的卡片。
function c45045866.filter(c)
	return c:IsCode(81434470,18828179) and c:IsAbleToHand()
end
-- 效果发动时的判定：无条件通过，并预设置从卡组将1张卡加入手卡的处理信息。
function c45045866.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：从卡组将1张卡加入手卡，数量为1，检索位置为卡组，具体对象在处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时：从卡组选择1张符合条件的「千眼卵鱼」或「母脑鱼」加入手卡，并让对方确认。
function c45045866.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择卡片的提示信息：请选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组筛选并选择1张满足过滤条件的卡片（「千眼卵鱼」或「母脑鱼」且能加入手卡）。
	local g=Duel.SelectMatchingCard(tp,c45045866.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡（此时为持有者即自己的手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
