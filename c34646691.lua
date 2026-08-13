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
-- 效果发动时：满足条件则允许发动，将本次召唤/反转召唤/特殊召唤成功的怪兽组设为效果关联对象，并登记将改变其表示形式的操作信息。
function c34646691.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将触发本效果的怪兽组（eg）设为当前连锁的关联对象，使这些怪兽与效果建立联系，供处理阶段判断哪些怪兽仍受本效果影响。
	Duel.SetTargetCard(eg)
	-- 登记操作信息：本效果将处理表示形式变更（CATEGORY_POSITION），涉及对象为eg中的全部怪兽，数量为eg:GetCount()，玩家和位置参数为0（不限定）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 筛选函数：选出处理时仍与效果e相关且满足“表侧表示、攻击表示”的怪兽，用于确定实际变为守备表示的怪兽。
function c34646691.filter(c,e)
	return c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e)
end
-- 效果处理时，从触发怪兽组eg中筛选出符合条件的怪兽，并将它们全部变为表侧守备表示。
function c34646691.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c34646691.filter,nil,e)
	-- 将筛选出的怪兽组g的表示形式全部改为表侧守备表示。
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
