--追い剥ぎゾンビ
-- 效果：
-- 每当自己场上的怪兽对对方造成战斗伤害时，对方将其卡组最上面1张卡送去墓地。
function c83258273.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每当自己场上的怪兽对对方造成战斗伤害时，对方将其卡组最上面1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83258273,0))  --"卡组送墓"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c83258273.condition)
	e2:SetTarget(c83258273.target)
	e2:SetOperation(c83258273.operation)
	c:RegisterEffect(e2)
end
-- 检查触发事件是否为对方受到战斗伤害，且造成伤害的怪兽由自己控制
function c83258273.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():GetControler()==tp
end
-- 效果发动时的目标处理，必发效果直接返回true，并设置卡组送墓的操作信息
function c83258273.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明此效果会使对方卡组最上方1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,1)
end
-- 效果处理的执行函数，将对方卡组最上面1张卡送去墓地
function c83258273.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方卡组最上面1张卡因效果送去墓地
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
end
