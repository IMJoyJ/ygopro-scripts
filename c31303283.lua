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
	-- 设置该免疫效果的判定函数为aux.tgoval，用于表示对方不能以这张卡为卡的效果对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，把自己场上1只炎属性怪兽解放才能发动。这张卡的攻击力上升300。
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
-- 这是起动效果的发动费用函数：检查并解放自己场上1只炎属性怪兽来支付代价。
function c31303283.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在费用检测阶段，检查自己场上是否存在除这张卡外1只炎属性且可解放的怪兽，以判断能否发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_FIRE) end
	-- 从自己场上选择1只炎属性怪兽（不能选发动效果的这张卡）作为解放代价，选择结果存为g。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_FIRE)
	-- 将选择的怪兽解放，解放原因设为REASON_COST，作为发动代价处理。
	Duel.Release(g,REASON_COST)
end
-- 效果处理函数：确认这张卡仍表侧在场且与效果关联后，给这张卡附加攻击力上升300的效果，并设置标准重置。
function c31303283.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
