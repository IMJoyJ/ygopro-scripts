--ヴェルズ・タナトス
-- 效果：
-- 暗属性4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。这个回合，这张卡不受这张卡以外的怪兽的效果影响。这个效果在对方回合也能发动。
function c65884091.initial_effect(c)
	-- 添加XYZ召唤手续：需要2只4星暗属性怪兽
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。这个回合，这张卡不受这张卡以外的怪兽的效果影响。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65884091,0))  --"效果免疫"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c65884091.cost)
	e1:SetOperation(c65884091.operation)
	c:RegisterEffect(e1)
end
-- 检查并移除这张卡的1个超量素材作为发动代价
function c65884091.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果处理：若这张卡在场上表侧表示存在，则为其注册不受自身以外怪兽效果影响的免疫效果，持续到回合结束
function c65884091.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这个回合，这张卡不受这张卡以外的怪兽的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c65884091.efilter)
		c:RegisterEffect(e1)
	end
end
-- 免疫效果的过滤条件：判定来源是否为怪兽效果且不是这张卡自身
function c65884091.efilter(e,te)
	return te:IsActiveType(TYPE_EFFECT) and te:GetOwner()~=e:GetOwner()
end
