--CNo.39 希望皇ホープレイ
-- 效果：
-- 光属性4星怪兽×3
-- 这张卡也能在自己场上的「No.39 希望皇 霍普」上面重叠来超量召唤。
-- ①：把这张卡1个超量素材取除才能发动。直到回合结束时这张卡的攻击力上升500，选对方场上1只怪兽那个攻击力直到回合结束时下降1000。这个效果在自己基本分是1000以下的场合才能发动和处理。
function c56840427.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),4,3,c56840427.ovfilter,aux.Stringid(56840427,1))  --"是否在「No.39 希望皇 霍普」上面重叠超量召唤？"
	-- ①：把这张卡1个超量素材取除才能发动。直到回合结束时这张卡的攻击力上升500，选对方场上1只怪兽那个攻击力直到回合结束时下降1000。这个效果在自己基本分是1000以下的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(56840427,0))  --"攻击变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c56840427.condition)
	e1:SetCost(c56840427.cost)
	e1:SetOperation(c56840427.operation)
	c:RegisterEffect(e1)
end
-- 设置该怪兽的「No.」数值为39（用于判定是否属于「No.」系列怪兽）
aux.xyz_number[56840427]=39
-- 过滤用于重叠超量召唤的怪兽：自己场上表侧表示的「No.39 希望皇 霍普」
function c56840427.ovfilter(c)
	return c:IsFaceup() and c:IsCode(84013237)
end
-- 定义效果发动条件：自己基本分在1000以下
function c56840427.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家（发动者）的生命值（LP）是否小于或等于1000
	return Duel.GetLP(tp)<=1000
end
-- 定义效果发动代价：检查并取除这张卡的1个超量素材
function c56840427.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果处理：若满足生命值条件，则自身攻击力上升500，并使对方场上1只表侧表示怪兽的攻击力下降1000
function c56840427.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己基本分大于1000，则不进行效果处理
	if Duel.GetLP(tp)>1000 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 直到回合结束时这张卡的攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 给玩家发送提示信息，要求选择一只表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家选择对方场上1只表侧表示的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 为选中的怪兽显示被选为对象的动画效果
			Duel.HintSelection(g)
			-- 选对方场上1只怪兽那个攻击力直到回合结束时下降1000
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(-1000)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			g:GetFirst():RegisterEffect(e2)
		end
	end
end
