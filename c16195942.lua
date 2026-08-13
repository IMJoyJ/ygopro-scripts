--ダーク・リベリオン・エクシーズ・ドラゴン
-- 效果：
-- 4星怪兽×2
-- ①：把这张卡2个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成一半，这张卡的攻击力上升那个数值。
function c16195942.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用2只等级为4的怪兽作为素材进行XYZ召唤（无可选额外条件）。
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
-- 效果发动的代价处理：先检查这张卡能否取除2个超量素材作为代价；若能则实际取除2个超量素材（REASON_COST）。
function c16195942.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果发动的对象选择：选择对方场上1只表侧表示且攻击力不为0的怪兽作为效果对象，并加入合法性检查和选择提示。
function c16195942.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁确认阶段检查已选对象是否合法：对象必须是对方场上表侧表示且攻击力不为0的怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	-- 发动合法性检查：确认对方场上存在至少1只表侧表示且攻击力不为0的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 实际从对方场上选择1只表侧表示且攻击力不为0的怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：先取得对象怪兽当前攻击力；给对象怪兽设置攻击力变为一半的效果；若本卡仍在该效果关联且表侧表示，则本卡攻击力上升相同数值（该上升效果不能被无效）。
function c16195942.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理阶段的对象怪兽（即发动时选择的那只对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetAttack()
		-- 那只怪兽的攻击力变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 这张卡的攻击力上升那个数值。
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
