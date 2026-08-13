--マジシャンズ・クロス
-- 效果：
-- ①：自己场上有攻击表示的魔法师族怪兽2只以上存在的场合，以那之内的1只为对象才能发动。那只怪兽的攻击力直到回合结束时变成3000。这张卡的发动后，直到回合结束时那只怪兽以外的魔法师族怪兽不能攻击。
function c36045450.initial_effect(c)
	-- ①：自己场上有攻击表示的魔法师族怪兽2只以上存在的场合，以那之内的1只为对象才能发动。那只怪兽的攻击力直到回合结束时变成3000。这张卡的发动后，直到回合结束时那只怪兽以外的魔法师族怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c36045450.condition)
	e1:SetTarget(c36045450.target)
	e1:SetOperation(c36045450.operation)
	c:RegisterEffect(e1)
end
-- 筛选表侧攻击表示且为魔法师族的怪兽。
function c36045450.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsRace(RACE_SPELLCASTER)
end
-- 发动条件：自己场上存在至少2只表侧攻击表示的魔法师族怪兽。
function c36045450.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只满足filter条件的怪兽。
	return Duel.IsExistingMatchingCard(c36045450.filter,tp,LOCATION_MZONE,0,2,nil)
end
-- 目标选择函数：若在检查特定卡时验证该卡是否符合对象条件；若为发动合法性检查则确认有可选对象；发动时提示玩家选择1只表侧攻击表示的魔法师族怪兽作为对象。
function c36045450.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36045450.filter(chkc) end
	-- 发动合法性检查：确认自己场上存在至少1只可被选择为对象的表侧攻击表示魔法师族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c36045450.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只表侧攻击表示的魔法师族怪兽，并将其设置为效果对象。
	Duel.SelectTarget(tp,c36045450.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：选中的对象怪兽若仍表侧且与效果关联，则其攻击力变成3000直到回合结束；之后给自己场上该对象以外的魔法师族怪兽附加不能攻击的限制。
function c36045450.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时变成3000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时那只怪兽以外的魔法师族怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c36045450.ftarget)
	e1:SetLabel(tc:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击的场地效果以tp为控制者注册并生效，作用于tp场上的魔法师族怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 判断某张卡是否为“对象以外的魔法师族怪兽”：不是选中的那只（通过FieldID比较不同）且种族为魔法师族。
function c36045450.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID() and c:IsRace(RACE_SPELLCASTER)
end
