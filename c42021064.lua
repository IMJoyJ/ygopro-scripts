--機動石器ドグラード
-- 效果：
-- 包含岩石族怪兽的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己墓地1只岩石族怪兽为对象才能发动。这张卡的攻击力上升作为对象的怪兽的攻击力数值。
-- ②：对方主要阶段，以持有这张卡的攻击力以下的攻击力的场上1只其他怪兽为对象才能发动。这张卡的攻击力下降作为对象的怪兽的攻击力数值，作为对象的怪兽破坏。
local s,id,o=GetID()
-- 初始化效果函数，设置连接召唤手续、启用特殊召唤限制，并注册两个效果
function s.initial_effect(c)
	-- 为该卡添加连接召唤手续，要求使用2到99个满足s.lcheck条件的怪兽作为连接素材
	aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以自己墓地1只岩石族怪兽为对象才能发动。这张卡的攻击力上升作为对象的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段，以持有这张卡的攻击力以下的攻击力的场上1只其他怪兽为对象才能发动。这张卡的攻击力下降作为对象的怪兽的攻击力数值，作为对象的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力下降并破坏"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 连接召唤条件检查函数，判断连接怪兽组中是否存在岩石族怪兽
function s.lcheck(g)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_ROCK)
end
-- 攻击力上升效果的对象过滤函数，筛选墓地中的岩石族怪兽且攻击力大于等于1
function s.atkfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAttackAbove(1)
end
-- 效果①的目标选择函数，选择墓地中的岩石族怪兽作为对象
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and s.atkfilter(chk) end
	-- 判断效果①是否可以发动，检查是否存在满足条件的墓地岩石族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果①的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从墓地选择满足条件的岩石族怪兽作为效果①的对象
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- 效果①的处理函数，将目标怪兽的攻击力加到自身
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 创建攻击力变更效果，使自身攻击力增加目标怪兽的攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件函数，判断是否为对方主要阶段且不是自己回合
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方主要阶段且不是自己回合
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 效果②的目标过滤函数，筛选场上攻击力低于或等于自身攻击力的怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsAttackAbove(1)
end
-- 效果②的目标选择函数，选择场上满足条件的怪兽作为对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local atk=c:GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,atk) end
	-- 判断效果②是否可以发动，检查是否存在满足条件的场上怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,atk) end
	-- 提示玩家选择效果②的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择满足条件的怪兽作为效果②的对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,atk)
	-- 设置效果②的处理信息，确定将要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的处理函数，使自身攻击力下降并破坏目标怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果②的目标怪兽
	local tc=Duel.GetFirstTarget()
	local atk=tc:GetAttack()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:GetAttack()<atk
		or not tc:IsRelateToEffect(e) or not tc:IsFaceup() or not tc:IsType(TYPE_MONSTER) or atk<=0 then
		return
	end
	-- 创建攻击力变更效果，使自身攻击力减少目标怪兽的攻击力
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-atk)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
