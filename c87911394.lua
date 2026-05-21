--CNo.39 希望皇ホープレイ・ヴィクトリー
-- 效果：
-- 5星怪兽×3
-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
-- ②：这张卡有「希望皇 霍普」怪兽在作为超量素材的场合，得到以下效果。
-- ●这张卡向对方的表侧表示怪兽攻击宣言时，把这张卡1个超量素材取除才能发动。直到回合结束时，那只对方怪兽的效果无效化，这张卡的攻击力上升那只对方怪兽的攻击力数值。
function c87911394.initial_effect(c)
	-- 添加超量召唤手续：5星怪兽×3
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c87911394.aclimit)
	e1:SetCondition(c87911394.actcon)
	c:RegisterEffect(e1)
	-- ②：这张卡有「希望皇 霍普」怪兽在作为超量素材的场合，得到以下效果。●这张卡向对方的表侧表示怪兽攻击宣言时，把这张卡1个超量素材取除才能发动。直到回合结束时，那只对方怪兽的效果无效化，这张卡的攻击力上升那只对方怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87911394,0))  --"效果无效化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(c87911394.atkcon)
	e2:SetCost(c87911394.atkcost)
	e2:SetTarget(c87911394.atktg)
	e2:SetOperation(c87911394.atkop)
	c:RegisterEffect(e2)
end
-- 设置该卡片的「No.」数值为39
aux.xyz_number[87911394]=39
-- 定义不能发动的卡片类型为魔法·陷阱卡的发动
function c87911394.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 定义魔法·陷阱卡不能发动的条件：此卡进行攻击
function c87911394.actcon(e)
	-- 判断当前进行攻击的怪兽是否为这张卡自身
	return Duel.GetAttacker()==e:GetHandler()
end
-- 定义攻击宣言时效果的发动条件：攻击对象为表侧表示怪兽，且自身拥有「希望皇 霍普」怪兽作为超量素材
function c87911394.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local at=Duel.GetAttackTarget()
	return at and at:IsFaceup() and e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,0x107f)
end
-- 定义效果发动的代价：取除这张卡的1个超量素材
function c87911394.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果的目标：将当前的攻击目标怪兽设为效果处理对象
function c87911394.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前的攻击目标怪兽设为效果处理的对象
	Duel.SetTargetCard(Duel.GetAttackTarget())
end
-- 定义效果的处理：使目标怪兽效果无效，并使自身攻击力上升该怪兽攻击力的数值
function c87911394.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取之前设定的效果处理对象（即被攻击的对方怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只对方怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只对方怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 手动刷新场上目标怪兽的状态，使其效果无效化立刻生效
		Duel.AdjustInstantly(tc)
		local atk=tc:GetAttack()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 这张卡的攻击力上升那只对方怪兽的攻击力数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
