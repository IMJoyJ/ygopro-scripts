--先史遺産クリスタル・エイリアン
-- 效果：
-- 3星怪兽×2
-- 1回合1次，这张卡被选择作为攻击对象时，把这张卡1个超量素材取除才能发动。这个回合，这张卡不会被战斗以及卡的效果破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
function c93730230.initial_effect(c)
	-- 添加XYZ召唤手续，素材为2只3星怪兽
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- 1回合1次，这张卡被选择作为攻击对象时，把这张卡1个超量素材取除才能发动。这个回合，这张卡不会被战斗以及卡的效果破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93730230,0))  --"伤害转移"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c93730230.cost)
	e1:SetOperation(c93730230.operation)
	c:RegisterEffect(e1)
end
-- 检查并取除这张卡的1个超量素材作为发动的代价
function c93730230.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 若此卡仍表侧表示存在，则在回合结束前赋予其不会被战斗、效果破坏以及战斗伤害由对方代受的效果
function c93730230.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这个回合，这张卡不会被战斗……破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
		c:RegisterEffect(e3)
	end
end
