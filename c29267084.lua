--闇の呪縛
-- 效果：
-- 以对方场上1只表侧表示怪兽为对象才能把这张卡发动。
-- ①：作为对象的怪兽的攻击力下降700，不能攻击，也不能作表示形式的变更。那只怪兽从场上离开时这张卡破坏。
function c29267084.initial_effect(c)
	-- 以对方场上1只表侧表示怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤限制：只能在伤害步骤且伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c29267084.target)
	e1:SetOperation(c29267084.operation)
	c:RegisterEffect(e1)
	-- 作为对象的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_TARGET)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(-700)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	c:RegisterEffect(e4)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(c29267084.descon)
	e5:SetOperation(c29267084.desop)
	c:RegisterEffect(e5)
end
-- 效果发动时的目标处理：仅在对方怪兽区存在表侧表示怪兽时，选择其中1只作为对象。
function c29267084.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1只表侧表示怪兽，若不存在则效果无法发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的1只表侧表示怪兽作为效果对象，并登记为当前连锁的取对象目标。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时，若这张卡和对象怪兽均仍然与效果关联，则将对象怪兽设置为这张卡的永续对象，以便后续持续施加影响。
function c29267084.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
-- 破坏效果的触发条件：这张卡未被预定破坏时，若其永续对象怪兽从场上离开，则返回真。
function c29267084.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 破坏效果处理：将这张卡本身破坏。
function c29267084.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
