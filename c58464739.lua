--パルス・ボム
-- 效果：
-- ①：自己场上有机械族怪兽存在的场合才能发动。对方场上有攻击表示怪兽存在的场合，那些怪兽全部变成守备表示。直到回合结束时，对方场上有怪兽召唤·特殊召唤的场合，那些怪兽变成守备表示。
function c58464739.initial_effect(c)
	-- ①：自己场上有机械族怪兽存在的场合才能发动。对方场上有攻击表示怪兽存在的场合，那些怪兽全部变成守备表示。直到回合结束时，对方场上有怪兽召唤·特殊召唤的场合，那些怪兽变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c58464739.condition)
	e1:SetTarget(c58464739.target)
	e1:SetOperation(c58464739.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的机械族怪兽
function c58464739.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 发动条件：自己场上有机械族怪兽存在
function c58464739.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的机械族怪兽
	return Duel.IsExistingMatchingCard(c58464739.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：对方场上表侧攻击表示且可以改变表示形式的怪兽
function c58464739.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 发动准备：获取对方场上符合条件的怪兽并设置改变表示形式的操作信息
function c58464739.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上所有表侧攻击表示且可以改变表示形式的怪兽
	local g=Duel.GetMatchingGroup(c58464739.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：改变符合条件的怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：将对方场上攻击表示怪兽全部变成守备表示，并注册后续召唤·特殊召唤怪兽变守备表示的效果
function c58464739.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前所有表侧攻击表示且可以改变表示形式的怪兽
	local g=Duel.GetMatchingGroup(c58464739.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将这些怪兽全部变成表侧守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
	-- 直到回合结束时，对方场上有怪兽召唤·特殊召唤的场合，那些怪兽变成守备表示。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c58464739.posop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：对方通常召唤成功时将其变成守备表示，持续到回合结束
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	-- 注册全局效果：对方特殊召唤成功时将其变成守备表示，持续到回合结束
	Duel.RegisterEffect(e2,tp)
end
-- 过滤条件：对方场上新召唤或特殊召唤的、可以改变表示形式的表侧攻击表示怪兽
function c58464739.posfilter(c,tp)
	return c58464739.filter(c) and c:IsControler(1-tp)
end
-- 对方召唤或特殊召唤成功时的效果处理：将新召唤或特殊召唤的怪兽变成表侧守备表示
function c58464739.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c58464739.posfilter,nil,tp)
	if g:GetCount()>0 then
		-- 将新召唤或特殊召唤的怪兽全部变成表侧守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
