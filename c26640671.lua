--蜘蛛の領域
-- 效果：
-- 1回合1次，选择自己场上表侧表示存在的1只昆虫族怪兽发动。和选择的怪兽进行战斗的对方怪兽在战斗阶段结束时变成守备表示，只要这张卡在场上存在不能把表示形式变更。
function c26640671.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 选择自己场上表侧表示存在的1只昆虫族怪兽发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26640671,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c26640671.target)
	e2:SetOperation(c26640671.operation)
	c:RegisterEffect(e2)
	-- 和选择的怪兽进行战斗的对方怪兽在战斗阶段结束时变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(c26640671.regop)
	c:RegisterEffect(e3)
	-- 只要这张卡在场上存在不能把表示形式变更。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetCountLimit(1)
	e4:SetOperation(c26640671.posop)
	c:RegisterEffect(e4)
	-- 1回合1次，选择自己场上表侧表示存在的1只昆虫族怪兽发动。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetTarget(c26640671.postg)
	c:RegisterEffect(e5)
end
-- 过滤满足条件的昆虫族怪兽，即：表侧表示、未被选择为目标、且为昆虫族。
function c26640671.filter(c,ec)
	return c:IsFaceup() and not ec:IsHasCardTarget(c) and c:IsRace(RACE_INSECT)
end
-- 设置效果目标为满足条件的昆虫族怪兽。
function c26640671.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c26640671.filter(chkc,e:GetHandler()) end
	-- 检查是否存在满足条件的昆虫族怪兽作为目标。
	if chk==0 then return Duel.IsExistingTarget(c26640671.filter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler()) end
	-- 提示玩家选择目标怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的昆虫族怪兽作为目标。
	Duel.SelectTarget(tp,c26640671.filter,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler())
end
-- 将选择的怪兽设置为当前效果的目标。
function c26640671.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	c:SetCardTarget(tc)
end
-- 记录战斗中的攻击怪兽和被攻击怪兽。
function c26640671.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取此次战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	if d and d:IsControler(1-tp) and e:GetHandler():IsHasCardTarget(a) then
		d:RegisterFlagEffect(26640671,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	elseif d and a:IsControler(1-tp) and e:GetHandler():IsHasCardTarget(d) then
		a:RegisterFlagEffect(26640671,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 筛选出拥有标记26640671且处于攻击表示的怪兽。
function c26640671.pfilter(c)
	return c:GetFlagEffect(26640671)~=0 and c:IsAttackPos()
end
-- 将符合条件的怪兽变为守备表示，并为其添加标记26640672。
function c26640671.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的怪兽组。
	local g=Duel.GetMatchingGroup(c26640671.pfilter,tp,0,LOCATION_MZONE,nil)
	-- 将怪兽组变为守备表示。
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(26640672,RESET_EVENT+RESETS_STANDARD,0,1)
		tc=g:GetNext()
	end
end
-- 判断怪兽是否拥有标记26640672，用于限制其表示形式变更。
function c26640671.postg(e,c)
	return c:GetFlagEffect(26640672)~=0
end
