--ナチュル・バタフライ
-- 效果：
-- 1回合1次，对方怪兽的攻击宣言时才能发动。把自己卡组最上面1张卡送去墓地，那次攻击无效。
function c42110434.initial_effect(c)
	-- 创建一个字段触发效果，用于在对方怪兽攻击宣言时发动，效果描述为“攻击无效”，生效区域为主怪兽区，限制每回合发动一次
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
-- 效果发动条件：攻击方怪兽的控制者不是自己
function c42110434.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():GetControler()~=tp
end
-- 效果目标设定：检查自己是否可以将卡组最上面1张卡送去墓地，并设置操作信息为将1张卡从卡组送去墓地
function c42110434.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以将卡组最上面1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置操作信息为将1张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 效果处理：将自己卡组最上面1张卡送去墓地，并无效此次攻击
function c42110434.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组最上面1张卡以效果原因送去墓地
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	-- 无效此次攻击
	Duel.NegateAttack()
end
