--ワンショット・キャノン
-- 效果：
-- 「一击喷射士」＋调整以外的怪兽1只
-- 1回合1次，把场上表侧表示存在的1只怪兽破坏，给与那个控制者破坏怪兽的攻击力一半数值的伤害。
function c13574687.initial_effect(c)
	-- 为怪兽添加融合召唤所需的素材代码列表，允许使用卡号6142213作为素材
	aux.AddMaterialCodeList(c,6142213)
	-- 为怪兽添加同调召唤手续，要求1只卡号为6142213的调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsCode,6142213),aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- 1回合1次，把场上表侧表示存在的1只怪兽破坏，给与那个控制者破坏怪兽的攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13574687,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c13574687.target)
	e1:SetOperation(c13574687.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示
function c13574687.filter(c)
	return c:IsFaceup()
end
-- 效果的发动目标选择函数，用于选择场上1只表侧表示的怪兽作为破坏对象
function c13574687.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c13574687.filter(chkc) end
	-- 判断是否满足发动条件，检查场上是否存在1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c13574687.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，提示选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择场上1只表侧表示的怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c13574687.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息，指定破坏的怪兽数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置伤害效果的操作信息，指定伤害来源为被破坏怪兽的控制者，伤害值为被破坏怪兽攻击力的一半
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,g:GetFirst():GetControler(),math.floor(g:GetFirst():GetAttack()/2))
end
-- 效果的发动处理函数，用于执行破坏和伤害效果
function c13574687.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local dam=math.floor(tc:GetAttack()/2)
		local p=tc:GetControler()
		-- 执行破坏操作，若破坏成功则继续执行伤害处理
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 对目标怪兽的控制者造成伤害，伤害值为该怪兽攻击力的一半
			Duel.Damage(p,dam,REASON_EFFECT)
		end
	end
end
