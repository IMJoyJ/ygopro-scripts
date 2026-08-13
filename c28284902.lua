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
-- 判断是否存在符合条件的怪兽：表侧表示、属于「变形斗士」、攻击表示且能够被效果改变表示形式，用于发动条件与筛选。
function c28284902.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x26) and c:IsAttackPos() and c:IsCanChangePosition()
end
-- 效果发动条件判定与对象登记：若本次召唤成功的怪兽群中不存在至少1只满足cfilter的怪兽则不能发动；否则将整个召唤成功的怪兽群设为效果对象，并登记改变表示形式的操作信息。
function c28284902.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c28284902.cfilter,1,nil) end
	-- 将本次召唤成功的所有怪兽（eg）标记为当前连锁的效果关联对象，确保后续处理时只处理仍与此效果有关的怪兽。
	Duel.SetTargetCard(eg)
	-- 向连锁登记操作信息：效果类别为改变表示形式（CATEGORY_POSITION），预定对象为eg中的全部怪兽，数量为eg:GetCount()，供后续时点检测与其他效果参照。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 效果处理时对召唤成功怪兽群的最终筛选条件：表侧表示、属于「变形斗士」、攻击表示、且仍与本效果保持关联（未离场或被重置关联）。
function c28284902.filter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x26) and c:IsAttackPos() and c:IsRelateToEffect(e)
end
-- 实际处理部分：从本次召唤成功的怪兽群中筛出仍然符合条件的怪兽，统一将其变为表侧守备表示。
function c28284902.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c28284902.filter,nil,e)
	-- 将筛选出的怪兽群的表示形式全部改为表侧守备表示。
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
