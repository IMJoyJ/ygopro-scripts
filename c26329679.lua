--セイクリッド・オメガ
-- 效果：
-- 光属性4星怪兽×2
-- ①：自己·对方回合1次，把这张卡1个超量素材取除才能发动。自己场上的全部「星圣」怪兽直到回合结束时不受魔法·陷阱卡的效果影响。
function c26329679.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以2只光属性4星怪兽作为超量素材叠放召唤。
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
-- 发动代价：从这张卡上取除1个超量素材。chk==0时仅检查是否存在可取除的超量素材；实际发动时执行取除1个。
function c26329679.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：表侧表示且属于「星圣」字段的怪兽，用于筛选自己场上的「星圣」怪兽。
function c26329679.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x53)
end
-- 效果处理：获取自己场上全部表侧表示的「星圣」怪兽，为每只赋予“直到回合结束时不受魔法·陷阱卡的效果影响”的免疫效果。
function c26329679.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足filter条件的「星圣」怪兽（不取对象，自动选择全部符合的怪兽）。
	local g=Duel.GetMatchingGroup(c26329679.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对应效果：自己场上的全部「星圣」怪兽直到回合结束时不受魔法·陷阱卡的效果影响。
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
-- 免疫判定条件：仅当来源效果的类型为魔法卡或陷阱卡时，该效果才被免疫，从而实现对魔法·陷阱卡效果的抗性。
function c26329679.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
