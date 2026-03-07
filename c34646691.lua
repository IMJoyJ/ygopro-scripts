--つまずき
-- 效果：
-- 召唤·反转召唤·特殊召唤成功的怪兽成为守备表示。
function c34646691.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 召唤·反转召唤·特殊召唤成功的怪兽成为守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34646691,0))  --"变成守备表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c34646691.target)
	e2:SetOperation(c34646691.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 设置连锁处理的目标卡片为eg，并设置操作信息为改变表示形式
function c34646691.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁处理的对象设置为eg
	Duel.SetTargetCard(eg)
	-- 设置操作信息为改变表示形式效果，目标为eg，数量为eg的数量
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 过滤函数，筛选满足条件的卡片：表侧表示、攻击表示且与效果相关
function c34646691.filter(c,e)
	return c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e)
end
-- 效果处理函数，将符合条件的怪兽改变为守备表示
function c34646691.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c34646691.filter,nil,e)
	-- 将目标怪兽改变为表侧守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
