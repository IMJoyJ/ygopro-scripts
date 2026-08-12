--幻蝶の護り
-- 效果：
-- 选择场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成表侧守备表示。这张卡发动的回合，自己受到的全部伤害变成一半。
function c63630268.initial_effect(c)
	-- 选择场上表侧攻击表示存在的1只怪兽才能发动。选择的怪兽变成表侧守备表示。这张卡发动的回合，自己受到的全部伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c63630268.target)
	e1:SetOperation(c63630268.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧攻击表示且可以改变表示形式的怪兽
function c63630268.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果发动的靶向处理，用于检测和选择合法的对象怪兽
function c63630268.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c63630268.filter(chkc) end
	-- 检查场上是否存在至少1只可以改变表示形式的表侧攻击表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c63630268.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置提示信息，提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择1只符合条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,c63630268.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理，将对象怪兽变为表侧守备表示，并注册本回合自己受到的伤害减半的效果
function c63630268.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) then
		-- 将目标怪兽的表示形式改变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡发动的回合，自己受到的全部伤害变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(c63630268.damval)
		e1:SetReset(RESET_PHASE+PHASE_END,1)
		-- 将伤害减半的永续效果注册给发动卡片的玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 伤害计算函数，返回原本伤害值的一半（向下取整）
function c63630268.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
