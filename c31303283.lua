--陽炎獣 ヒッポグリフォ
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。此外，1回合1次，把自己场上1只炎属性怪兽解放才能发动。这张卡的攻击力上升300。
function c31303283.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果值为aux.tgoval函数，用于判断是否能成为对方效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 1回合1次，把自己场上1只炎属性怪兽解放才能发动。这张卡的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31303283,0))  --"攻击上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c31303283.atkcost)
	e2:SetOperation(c31303283.atkop)
	c:RegisterEffect(e2)
end
-- 检查玩家场上是否存在至少1张满足条件的炎属性怪兽（不包括自身），并选择其中1张进行解放
function c31303283.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的炎属性怪兽（不包括自身）
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_FIRE) end
	-- 从玩家场上选择1张满足条件的炎属性怪兽（不包括自身）
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_FIRE)
	-- 以REASON_COST原因解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 如果这张卡表侧表示存在且与效果相关，则使其攻击力上升300
function c31303283.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使这张卡的攻击力上升300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
