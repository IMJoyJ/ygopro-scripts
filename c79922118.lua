--おかしの家
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方准备阶段才能发动。对方场上的全部怪兽的攻击力上升600。那之后，对方场上的攻击力2500以上的怪兽全部破坏，自己回复破坏的怪兽数量×500基本分。
function c79922118.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：对方准备阶段才能发动。对方场上的全部怪兽的攻击力上升600。那之后，对方场上的攻击力2500以上的怪兽全部破坏，自己回复破坏的怪兽数量×500基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1,79922118)
	e2:SetCondition(c79922118.descon)
	e2:SetTarget(c79922118.destg)
	e2:SetOperation(c79922118.desop)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动条件函数。
function c79922118.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方（即对方回合）。
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数：筛选表侧表示的卡片。
function c79922118.filter(c)
	return c:IsFaceup()
end
-- 过滤函数：筛选表侧表示且攻击力在2500以上的卡片。
function c79922118.desfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2500)
end
-- 定义①效果的发动检测与效果分类注册函数。
function c79922118.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在至少1只表侧表示的怪兽作为可操作对象。
	if chk==0 then return Duel.IsExistingMatchingCard(c79922118.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有攻击力在2500以上的表侧表示怪兽，用于预估破坏目标。
	local g=Duel.GetMatchingGroup(c79922118.desfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏操作的连锁信息，向系统宣告将要破坏的怪兽组和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 定义①效果的处理函数，执行攻击力上升、破坏怪兽以及回复基本分的操作。
function c79922118.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示的怪兽。
	local g=Duel.GetMatchingGroup(c79922118.filter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力上升600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 获取攻击力上升后，对方场上所有攻击力在2500以上的表侧表示怪兽。
	local dg=Duel.GetMatchingGroup(c79922118.desfilter,tp,0,LOCATION_MZONE,nil)
	if dg:GetCount()>0 then
		-- 中断效果处理，使前后的“攻击力上升”与“破坏并回复”不视为同时处理。
		Duel.BreakEffect()
		-- 因效果破坏符合条件的怪兽，并记录实际破坏的数量。
		local ct=Duel.Destroy(dg,REASON_EFFECT)
		-- 自己回复破坏的怪兽数量×500基本分。
		Duel.Recover(tp,ct*500,REASON_EFFECT)
	end
end
