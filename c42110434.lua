--ナチュル・バタフライ
-- 效果：
-- 1回合1次，对方怪兽的攻击宣言时才能发动。把自己卡组最上面1张卡送去墓地，那次攻击无效。
function c42110434.initial_effect(c)
	-- 1回合1次，对方怪兽的攻击宣言时才能发动。把自己卡组最上面1张卡送去墓地，那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42110434,0))  --"攻击无效"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c42110434.condition)
	e1:SetTarget(c42110434.target)
	e1:SetOperation(c42110434.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：攻击宣言的怪兽的控制者不是效果发动方（即对方怪兽进行了攻击宣言）。
function c42110434.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():GetControler()~=tp
end
-- 效果发动时的目标处理：先检查能否把卡组最上方1张送去墓地，并设置“从卡组送墓”的操作信息。
function c42110434.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查时，判断自己能否将自己卡组最上面1张卡送去墓地；若不能则无法发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 将本次连锁的操作信息设定为：从发动者卡组上方将1张卡送去墓地，用于供其他效果互动的检测。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 效果处理时执行：将自己卡组最上面1张卡送去墓地，然后无效那次攻击。
function c42110434.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将发动者卡组最上面1张卡送入墓地。
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	-- 无效当前攻击宣言，使那次攻击无效化。
	Duel.NegateAttack()
end
