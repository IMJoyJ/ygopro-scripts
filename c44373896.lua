--デストロイ・ドラゴン
-- 效果：
-- 这张卡在用「克里底亚之牙」的效果把自己的手卡·场上的「破坏轮」送去墓地的场合才能特殊召唤。
-- ①：1回合1次，以对方场上1张卡为对象才能发动。那张卡破坏。那之后，破坏的卡是怪兽卡的场合，给与对方那个原本攻击力数值的伤害。
function c44373896.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡在用「克里底亚之牙」的效果把自己的手卡·场上的「破坏轮」送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以对方场上1张卡为对象才能发动。那张卡破坏。那之后，破坏的卡是怪兽卡的场合，给与对方那个原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetDescription(aux.Stringid(44373896,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c44373896.target)
	e2:SetOperation(c44373896.operation)
	c:RegisterEffect(e2)
end
c44373896.material_trap=83555666
-- 设置效果目标为对方场上的任意一张卡
function c44373896.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		local atk=g:GetFirst():GetTextAttack()
		if atk<0 then atk=0 end
		-- 设置对对方造成伤害的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	end
end
-- 处理效果的发动和执行
function c44373896.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 判断目标卡是否被破坏且为怪兽卡
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and tc:IsType(TYPE_MONSTER) then
			-- 中断当前效果，使后续处理视为错时点
			Duel.BreakEffect()
			-- 对对方造成相当于目标卡攻击力的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
