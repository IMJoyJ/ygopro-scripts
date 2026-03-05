--グランド・スパイダー
-- 效果：
-- 这张卡在自己场上表侧守备表示存在的场合对方对怪兽的召唤·特殊召唤成功时，可以把那些怪兽变成守备表示。这个效果1回合只能使用1次。
function c17243896.initial_effect(c)
	-- 效果原文内容：这张卡在自己场上表侧守备表示存在的场合对方对怪兽的召唤·特殊召唤成功时，可以把那些怪兽变成守备表示。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17243896,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c17243896.condition)
	e1:SetTarget(c17243896.target)
	e1:SetOperation(c17243896.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 检索满足条件的怪兽组，条件为：表侧攻击表示、由对方召唤或特殊召唤、可以改变表示形式、且与当前效果有关联
function c17243896.filter(c,e,tp)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSummonPlayer(1-tp) and c:IsCanChangePosition()
		and (not e or c:IsRelateToEffect(e))
end
-- 判断发动效果的怪兽是否为表侧守备表示
function c17243896.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 设置连锁处理的目标为满足条件的怪兽组，同时设置操作信息为改变表示形式
function c17243896.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c17243896.filter,1,nil,nil,tp) end
	-- 将连锁处理的对象设置为满足条件的怪兽组
	Duel.SetTargetCard(eg)
	-- 设置操作信息为改变表示形式效果，目标为满足条件的怪兽组，数量为怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 执行效果操作，将满足条件的怪兽组全部变为守备表示
function c17243896.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c17243896.filter,nil,e,tp)
	-- 将指定的怪兽组全部变为守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
