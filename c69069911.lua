--カチコチドラゴン
-- 效果：
-- 4星怪兽×2
-- 这张卡战斗破坏对方怪兽送去墓地时，可以把这张卡1个超量素材取除，只有1次继续攻击。这个效果1回合只能使用1次。
function c69069911.initial_effect(c)
	-- 为卡片添加超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 这张卡战斗破坏对方怪兽送去墓地时，可以把这张卡1个超量素材取除，只有1次继续攻击。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69069911,0))  --"连续攻击"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCountLimit(1)
	e1:SetCondition(c69069911.atcon)
	e1:SetCost(c69069911.atcost)
	e1:SetOperation(c69069911.atop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：被破坏的怪兽在墓地且是怪兽，自身可以进行连续攻击，且是与对方怪兽进行的战斗
function c69069911.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER) and c:IsChainAttackable() and c:IsStatus(STATUS_OPPO_BATTLE)
end
-- 判断并执行发动代价：取除这张卡的1个超量素材
function c69069911.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 执行效果：使这张卡可以再进行1次攻击
function c69069911.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使进行攻击的怪兽可以再进行1次攻击
	Duel.ChainAttack()
end
