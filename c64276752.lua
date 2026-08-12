--アーク・リベリオン・エクシーズ・ドラゴン
-- 效果：
-- 5星怪兽×3
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：超量召唤的这张卡不会被效果破坏。
-- ②：把这张卡1个超量素材取除才能发动。这张卡的攻击力上升这张卡以外的场上的怪兽的原本攻击力的合计数值。这张卡有暗属性超量怪兽在作为超量素材的场合，再让这张卡以外的场上的全部表侧表示怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不用这张卡不能攻击宣言。
function c64276752.initial_effect(c)
	-- 添加超量召唤手续：5星怪兽×3。
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：超量召唤的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetCondition(c64276752.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除才能发动。这张卡的攻击力上升这张卡以外的场上的怪兽的原本攻击力的合计数值。这张卡有暗属性超量怪兽在作为超量素材的场合，再让这张卡以外的场上的全部表侧表示怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不用这张卡不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64276752,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,64276752)
	e2:SetCost(c64276752.cost)
	e2:SetTarget(c64276752.target)
	e2:SetOperation(c64276752.operation)
	c:RegisterEffect(e2)
end
-- 检查自身是否为超量召唤状态，用于判断是否适用不会被效果破坏的永续效果。
function c64276752.indcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果②的代价：取除这张卡的1个超量素材。
function c64276752.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动准备：检查场上是否存在除自身以外原本攻击力合计大于0的表侧表示怪兽。
function c64276752.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上除自身以外所有表侧表示怪兽的原本攻击力合计是否大于0。
	if chk==0 then return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler()):GetSum(Card.GetBaseAttack)>0 end
end
-- 过滤条件：作为素材的暗属性超量怪兽。
function c64276752.mgfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 效果②的效果处理：使自身攻击力上升，若有暗属性超量怪兽作为素材则无效场上其他怪兽的效果，并限制本回合其他怪兽的攻击宣言。
function c64276752.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 计算场上除自身以外所有表侧表示怪兽的原本攻击力合计数值。
		local atk=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,c):GetSum(Card.GetBaseAttack)
		if atk>0 then
			-- 这张卡的攻击力上升这张卡以外的场上的怪兽的原本攻击力的合计数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			e1:SetValue(atk)
			c:RegisterEffect(e1)
			local mg=c:GetOverlayGroup()
			if mg:IsExists(c64276752.mgfilter,1,nil) then
				-- 获取场上除自身以外所有可以被无效效果的表侧表示怪兽。
				local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,c)
				-- 遍历所有符合无效条件的怪兽。
				for tc in aux.Next(g) do
					-- 再让这张卡以外的场上的全部表侧表示怪兽的效果无效化。
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e2)
					-- 再让这张卡以外的场上的全部表侧表示怪兽的效果无效化。
					local e3=Effect.CreateEffect(c)
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetCode(EFFECT_DISABLE_EFFECT)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e3)
				end
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不用这张卡不能攻击宣言。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetTarget(c64276752.ftarget)
	e0:SetLabel(c:GetFieldID())
	e0:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制玩家本回合的攻击宣言。
	Duel.RegisterEffect(e0,tp)
end
-- 过滤不能攻击宣言的怪兽：除自身（通过FieldID匹配）以外的怪兽。
function c64276752.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
