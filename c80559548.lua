--SRシェイブー・メラン
-- 效果：
-- ①：这张卡在召唤的回合不能攻击。
-- ②：1回合1次，以场上1只表侧表示怪兽为对象才能发动。这张卡变成守备表示，作为对象的怪兽的攻击力直到回合结束时下降800。
function c80559548.initial_effect(c)
	-- ①：这张卡在召唤的回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c80559548.sumop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以场上1只表侧表示怪兽为对象才能发动。这张卡变成守备表示，作为对象的怪兽的攻击力直到回合结束时下降800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80559548,0))  --"守备表示"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c80559548.atkcon)
	e2:SetTarget(c80559548.atktg)
	e2:SetOperation(c80559548.atkop)
	c:RegisterEffect(e2)
end
-- 召唤成功时的效果处理：为自身注册在召唤回合不能攻击的效果
function c80559548.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果发动条件：自身处于表侧攻击表示
function c80559548.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
-- 效果发动时的目标选择：选择场上1只表侧表示怪兽作为对象
function c80559548.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果解决：将自身变为表侧守备表示，并使作为对象的怪兽攻击力下降800
function c80559548.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 将自身表示形式变更为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		if tc:IsRelateToEffect(e) then
			-- 作为对象的怪兽的攻击力直到回合结束时下降800
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(-800)
			tc:RegisterEffect(e1)
		end
	end
end
