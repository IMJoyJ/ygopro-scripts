--野性解放
-- 效果：
-- 选择场上1只兽族·兽战士族怪兽才能发动。选择的兽族·兽战士族怪兽的攻击力上升那只怪兽的守备力数值。受到这个效果影响的怪兽在结束阶段时破坏。
function c61166988.initial_effect(c)
	-- 选择场上1只兽族·兽战士族怪兽才能发动。选择的兽族·兽战士族怪兽的攻击力上升那只怪兽的守备力数值。受到这个效果影响的怪兽在结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c61166988.target)
	e1:SetOperation(c61166988.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选场上守备力不为0且是兽族或兽战士族的怪兽
function c61166988.filter(c)
	-- 判断卡片是否为表侧表示且守备力大于0，并且种族为兽族或兽战士族
	return aux.nzdef(c) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR)
end
-- 效果发动的靶向处理（Target）函数，用于检测和选择合法的对象怪兽
function c61166988.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c61166988.filter(chkc) end
	-- 在发动阶段，检测场上是否存在至少1只满足过滤条件的兽族或兽战士族怪兽作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c61166988.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示其选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动效果的玩家选择1只满足过滤条件的怪兽，并将其作为效果的对象
	Duel.SelectTarget(tp,c61166988.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理（Operation）函数，实现攻击力上升以及结束阶段破坏的逻辑
function c61166988.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRace(RACE_BEAST+RACE_BEASTWARRIOR) then
		-- 选择的兽族·兽战士族怪兽的攻击力上升那只怪兽的守备力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetDefense())
		tc:RegisterEffect(e1)
		-- 受到这个效果影响的怪兽在结束阶段时破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetOperation(c61166988.desop)
		tc:RegisterEffect(e2)
	end
end
-- 定义结束阶段破坏怪兽的具体操作函数
function c61166988.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将受到该效果影响的怪兽因效果破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
