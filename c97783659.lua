--ブラッド・サッカー
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，从对方卡组上面把1张卡送去墓地。
function c97783659.initial_effect(c)
	-- 这张卡给与对方基本分战斗伤害时，从对方卡组上面把1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97783659,0))  --"卡组送墓"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c97783659.ddcon)
	e1:SetTarget(c97783659.ddtg)
	e1:SetOperation(c97783659.ddop)
	c:RegisterEffect(e1)
end
-- 确认受到战斗伤害的玩家是对方玩家
function c97783659.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果发动的目标确认与操作信息设置，作为必发效果直接返回true，并设置卡组送墓的操作信息
function c97783659.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为将对方卡组最上方的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,1)
end
-- 效果处理的执行，将对方卡组最上方的1张卡送去墓地
function c97783659.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方卡组最上方的1张卡因效果送去墓地
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
end
