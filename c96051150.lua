--陽炎獣 メコレオス
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。此外，1回合1次，把手卡或者自己场上表侧表示存在的1只炎属性怪兽送去墓地才能发动。这个回合，这张卡不会被卡的效果破坏。这个效果在对方回合也能发动。
function c96051150.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置不能成为对方卡片效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，把手卡或者自己场上表侧表示存在的1只炎属性怪兽送去墓地才能发动。这个回合，这张卡不会被卡的效果破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96051150,0))  --"破坏耐性"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c96051150.cost)
	e2:SetOperation(c96051150.operation)
	c:RegisterEffect(e2)
end
-- 过滤手卡或场上表侧表示的、可作为代价送去墓地的炎属性怪兽
function c96051150.cfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost()
end
-- 发动代价：把手卡或者自己场上表侧表示存在的1只炎属性怪兽送去墓地
function c96051150.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡或自己场上（除自身外）是否存在至少1只满足条件的炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96051150.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,e:GetHandler()) end
	-- 向玩家发送提示信息，要求选择送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或自己场上（除自身外）选择1只满足条件的炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c96051150.cfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理：使自身在本回合内获得不会被卡的效果破坏的耐性
function c96051150.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这个回合，这张卡不会被卡的效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
