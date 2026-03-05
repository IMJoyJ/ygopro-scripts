--ダーク・リベリオン・エクシーズ・ドラゴン
-- 效果：
-- 4星怪兽×2
-- ①：把这张卡2个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成一半，这张卡的攻击力上升那个数值。
function c16195942.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为4的怪兽2只作为素材
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡2个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成一半，这张卡的攻击力上升那个数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16195942,0))  --"攻守变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c16195942.cost)
	e1:SetTarget(c16195942.target)
	e1:SetOperation(c16195942.operation)
	c:RegisterEffect(e1)
end
-- 支付效果代价，移除自身2个超量素材
function c16195942.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 设置效果目标，选择对方场上1只表侧表示的怪兽
function c16195942.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标是否为对方场上的表侧表示怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 确认对方场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，对目标怪兽和自身进行攻击力变更
function c16195942.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetAttack()
		-- 那只怪兽的攻击力变成一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 这张卡的攻击力上升那个数值
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(math.ceil(atk/2))
			c:RegisterEffect(e2)
		end
	end
end
