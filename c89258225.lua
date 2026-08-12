--ハ・デスの使い魔
-- 效果：
-- 这张卡做祭品。选择场上表侧表示存在的1只恶魔族怪兽。只要那只怪兽表侧表示在场上存在，攻击力·守备力上升700。
function c89258225.initial_effect(c)
	-- 这张卡做祭品。选择场上表侧表示存在的1只恶魔族怪兽。只要那只怪兽表侧表示在场上存在，攻击力·守备力上升700。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89258225,0))  --"攻守上升"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c89258225.cost)
	e1:SetTarget(c89258225.target)
	e1:SetOperation(c89258225.operation)
	c:RegisterEffect(e1)
end
-- 发动代价处理：检查自身是否可以解放，并执行解放操作
function c89258225.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：场上表侧表示的恶魔族怪兽
function c89258225.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 效果的目标选择处理：选择场上1只表侧表示的恶魔族怪兽作为对象
function c89258225.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c89258225.filter(chkc) end
	-- 在发动阶段，检查场上是否存在可作为对象的表侧表示恶魔族怪兽
	if chk==0 then return Duel.IsExistingTarget(c89258225.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 向玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示的恶魔族怪兽作为效果对象
	Duel.SelectTarget(tp,c89258225.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使选择的对象怪兽攻击力、守备力上升700
function c89258225.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c89258225.filter(tc) then
		-- 攻击力·守备力上升700
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
