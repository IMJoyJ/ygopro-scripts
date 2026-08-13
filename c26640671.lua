--蜘蛛の領域
-- 效果：
-- 1回合1次，选择自己场上表侧表示存在的1只昆虫族怪兽发动。和选择的怪兽进行战斗的对方怪兽在战斗阶段结束时变成守备表示，只要这张卡在场上存在不能把表示形式变更。
function c26640671.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，选择自己场上表侧表示存在的1只昆虫族怪兽发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26640671,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c26640671.target)
	e2:SetOperation(c26640671.operation)
	c:RegisterEffect(e2)
	-- 和选择的怪兽进行战斗的对方怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(c26640671.regop)
	c:RegisterEffect(e3)
	-- 在战斗阶段结束时变成守备表示
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetCountLimit(1)
	e4:SetOperation(c26640671.posop)
	c:RegisterEffect(e4)
	-- 只要这张卡在场上存在不能把表示形式变更。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetTarget(c26640671.postg)
	c:RegisterEffect(e5)
end
-- 选择条件：对象必须为表侧表示、昆虫族，且没有被这张卡选为永续对象。
function c26640671.filter(c,ec)
	return c:IsFaceup() and not ec:IsHasCardTarget(c) and c:IsRace(RACE_INSECT)
end
-- 目标选择处理函数：发动时确认可选对象，提示玩家选择1只符合条件的昆虫族怪兽，并设为效果对象。
function c26640671.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c26640671.filter(chkc,e:GetHandler()) end
	-- 发动条件检查：确认自己场上存在至少1只符合条件的昆虫族怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(c26640671.filter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler()) end
	-- 向操作者显示选择提示消息（此处使用“请选择要装备的卡”的提示文本）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己场上选择1只符合条件的表侧昆虫族怪兽并设为效果对象。
	Duel.SelectTarget(tp,c26640671.filter,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler())
end
-- 效果处理：若这张卡和目标怪兽仍与效果关联且目标为表侧表示，则将目标怪兽作为这张卡的永续对象记录下来。
function c26640671.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这个效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	c:SetCardTarget(tc)
end
-- 战斗事件处理：若被选择的昆虫族怪兽与对方怪兽发生战斗，则给对方战斗怪兽注册标记，用于记录其与选定怪兽战斗过。
function c26640671.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的攻击对象（被攻击的怪兽，没有则为nil）。
	local d=Duel.GetAttackTarget()
	if d and d:IsControler(1-tp) and e:GetHandler():IsHasCardTarget(a) then
		d:RegisterFlagEffect(26640671,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	elseif d and a:IsControler(1-tp) and e:GetHandler():IsHasCardTarget(d) then
		a:RegisterFlagEffect(26640671,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 过滤条件：怪兽带有“与选定昆虫战斗过”的标记，并且处于攻击表示。
function c26640671.pfilter(c)
	return c:GetFlagEffect(26640671)~=0 and c:IsAttackPos()
end
-- 战斗阶段结束时的处理：检索所有符合条件的对方怪兽，将其变为表侧守备表示，并给这些怪兽注册“不能变更表示形式”的标记（持续到离场等重置）。
function c26640671.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有带有战斗标记且攻击表示的怪兽。
	local g=Duel.GetMatchingGroup(c26640671.pfilter,tp,0,LOCATION_MZONE,nil)
	-- 将这些怪兽全部变为表侧守备表示。
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(26640672,RESET_EVENT+RESETS_STANDARD,0,1)
		tc=g:GetNext()
	end
end
-- 判定怪兽是否带有“不能变更表示形式”的标记，用于永续效果的过滤。
function c26640671.postg(e,c)
	return c:GetFlagEffect(26640672)~=0
end
