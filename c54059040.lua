--アイスバーン
-- 效果：
-- 自己场上有水属性怪兽表侧表示存在，水属性以外的怪兽召唤·特殊召唤成功时，那些怪兽变成守备表示。
function c54059040.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_SUMMON+TIMING_SPSUMMON)
	c:RegisterEffect(e1)
	-- 自己场上有水属性怪兽表侧表示存在，水属性以外的怪兽召唤成功时，那些怪兽变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54059040,0))  --"变成守备表示"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c54059040.target)
	e2:SetOperation(c54059040.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的水属性怪兽
function c54059040.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤表侧攻击表示、水属性以外且与当前效果相关的怪兽
function c54059040.pfilter(c,e)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsNonAttribute(ATTRIBUTE_WATER) and (not e or c:IsRelateToEffect(e))
end
-- 效果发动时的可行性检查：自己场上存在表侧表示的水属性怪兽，且本次召唤·特殊召唤的怪兽中存在水属性以外的表侧攻击表示怪兽
function c54059040.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c54059040.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and eg:IsExists(c54059040.pfilter,1,nil) end
	-- 将本次召唤·特殊召唤成功的怪兽群设为效果的处理对象
	Duel.SetTargetCard(eg)
	-- 设置当前连锁的操作信息为改变表示形式，操作对象为本次召唤·特殊召唤成功的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 效果处理：将作为效果对象的怪兽中，仍满足水属性以外且表侧攻击表示的怪兽变成表侧守备表示
function c54059040.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 筛选出作为效果对象的怪兽中，仍满足水属性以外且表侧攻击表示的怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c54059040.pfilter,nil,e)
	-- 将筛选出的怪兽全部变成表侧守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
