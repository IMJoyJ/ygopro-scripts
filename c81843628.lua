--ニードルワーム
-- 效果：
-- 反转：对方卡组最上面的5张卡送去墓地。
function c81843628.initial_effect(c)
	-- 反转：对方卡组最上面的5张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81843628,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c81843628.target)
	e1:SetOperation(c81843628.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标与检测函数
function c81843628.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将对方卡组的5张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,5)
end
-- 定义效果处理的执行函数
function c81843628.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方卡组最上面的5张卡因效果送去墓地
	Duel.DiscardDeck(1-tp,5,REASON_EFFECT)
end
