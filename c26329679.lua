--セイクリッド・オメガ
-- 效果：
-- 光属性4星怪兽×2
-- ①：自己·对方回合1次，把这张卡1个超量素材取除才能发动。自己场上的全部「星圣」怪兽直到回合结束时不受魔法·陷阱卡的效果影响。
function c26329679.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用满足光属性条件的4星怪兽作为素材进行叠放，最少需要2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),4,2)
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，把这张卡1个超量素材取除才能发动。自己场上的全部「星圣」怪兽直到回合结束时不受魔法·陷阱卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26329679,0))  --"效果免疫"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c26329679.cost)
	e1:SetOperation(c26329679.operation)
	c:RegisterEffect(e1)
end
-- 检查是否可以移除1个超量素材作为发动代价，若可以则执行移除操作
function c26329679.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：场上正面表示的「星圣」怪兽
function c26329679.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x53)
end
-- 检索满足条件的「星圣」怪兽组，并为每只怪兽添加效果免疫
function c26329679.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足过滤条件的「星圣」怪兽组
	local g=Duel.GetMatchingGroup(c26329679.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为每只符合条件的怪兽添加效果免疫，使其不受魔法·陷阱卡的效果影响
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c26329679.efilter)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 效果过滤函数：判断效果是否为魔法卡或陷阱卡类型
function c26329679.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
