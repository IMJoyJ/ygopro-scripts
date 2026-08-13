--星因士 リゲル
-- 效果：
-- 「星因士 参宿七」的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合，以场上1只「星骑士」怪兽为对象才能发动。那只怪兽攻击力上升500，结束阶段送去墓地。
function c13851202.initial_effect(c)
	-- 「星因士 参宿七」的效果1回合只能使用1次。①：这张卡召唤·反转召唤·特殊召唤成功的场合，以场上1只「星骑士」怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,13851202)
	e1:SetTarget(c13851202.target)
	e1:SetOperation(c13851202.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c13851202.star_knight_summon_effect=e1
end
-- 筛选出场上表侧表示且属于「星骑士」字段的怪兽。
function c13851202.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9c)
end
-- 效果发动时的取对象处理：确认存在符合条件的对象后，选择场上1只表侧表示的「星骑士」怪兽作为效果对象。
function c13851202.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c13851202.filter(chkc) end
	-- 发动条件检查：场上是否存在至少1只表侧表示且属于「星骑士」字段的怪兽，若有才能发动。
	if chk==0 then return Duel.IsExistingTarget(c13851202.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从双方怪兽区域选择1只表侧表示的「星骑士」怪兽，并将其登记为本次效果的对象。
	Duel.SelectTarget(tp,c13851202.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时的操作：使对象怪兽攻击力上升500，并附加结束阶段将其送去墓地的效果。
function c13851202.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽攻击力上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 结束阶段送去墓地。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetRange(LOCATION_MZONE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCountLimit(1)
		e2:SetOperation(c13851202.tgop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 结束阶段送去墓地效果的触发操作：将持有该效果的那只怪兽送去墓地。
function c13851202.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将效果持有者（对象怪兽）以效果原因送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
end
