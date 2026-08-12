--斬機マルチプライヤー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只电子界族·4星怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成8星。
-- ②：这张卡被送去墓地的场合，以额外怪兽区域1只自己的电子界族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成2倍。
function c52354896.initial_effect(c)
	-- ①：以自己场上1只电子界族·4星怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成8星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,52354896)
	e1:SetTarget(c52354896.target)
	e1:SetOperation(c52354896.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以额外怪兽区域1只自己的电子界族怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,52354897)
	e2:SetTarget(c52354896.datg)
	e2:SetOperation(c52354896.daop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的卡片组：表侧表示、4星、电子界族
function c52354896.filter(c)
	return c:IsFaceup() and c:IsLevel(4) and c:IsRace(RACE_CYBERSE)
end
-- 选择目标：自己场上满足条件的1只怪兽
function c52354896.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52354896.filter(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c52354896.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c52354896.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果①：将目标怪兽等级变为8星
function c52354896.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 设置效果：使目标怪兽等级变为8星，并在回合结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 检索满足条件的卡片组：表侧表示、电子界族、在额外怪兽区域
function c52354896.dafilter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:GetSequence()>=5
end
-- 选择目标：自己场上满足条件的1只怪兽
function c52354896.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52354896.dafilter(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c52354896.dafilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c52354896.dafilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果②：将目标怪兽攻击力变为2倍
function c52354896.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		-- 设置效果：使目标怪兽攻击力变为2倍，并在回合结束时重置
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(atk*2)
		tc:RegisterEffect(e1)
	end
end
