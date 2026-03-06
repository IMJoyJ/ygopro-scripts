--D・ゲイザー
-- 效果：
-- 名字带有「变形斗士」的怪兽召唤·反转召唤·特殊召唤成功时，可以把那些怪兽变成表侧守备表示。
function c28284902.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 名字带有「变形斗士」的怪兽召唤·反转召唤·特殊召唤成功时，可以把那些怪兽变成表侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28284902,0))  --"变成守备表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c28284902.target)
	e2:SetOperation(c28284902.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 筛选满足条件的怪兽：表侧表示、名字带有「变形斗士」、攻击表示、可以改变表示形式
function c28284902.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x26) and c:IsAttackPos() and c:IsCanChangePosition()
end
-- 效果处理时检查是否有满足条件的怪兽，若有则设置连锁对象为所有成功召唤/反转召唤/特殊召唤的怪兽，并设置操作信息为改变表示形式
function c28284902.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c28284902.cfilter,1,nil) end
	-- 将连锁对象设置为所有成功召唤/反转召唤/特殊召唤的怪兽
	Duel.SetTargetCard(eg)
	-- 设置操作信息为改变表示形式效果，目标为所有成功召唤/反转召唤/特殊召唤的怪兽，数量为怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 筛选满足条件的怪兽：表侧表示、名字带有「变形斗士」、攻击表示、与效果相关
function c28284902.filter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x26) and c:IsAttackPos() and c:IsRelateToEffect(e)
end
-- 效果处理时过滤出满足条件的怪兽并将其变为表侧守备表示
function c28284902.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c28284902.filter,nil,e)
	-- 将符合条件的怪兽变为表侧守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
