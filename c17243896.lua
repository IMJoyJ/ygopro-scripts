--グランド・スパイダー
-- 效果：
-- 这张卡在自己场上表侧守备表示存在的场合对方对怪兽的召唤·特殊召唤成功时，可以把那些怪兽变成守备表示。这个效果1回合只能使用1次。
function c17243896.initial_effect(c)
	-- 这张卡在自己场上表侧守备表示存在的场合对方对怪兽的召唤·特殊召唤成功时，可以把那些怪兽变成守备表示。这个效果1回合只能使用1次。
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
-- 过滤条件：对象必须是表侧攻击表示、由对方玩家召唤/特殊召唤、可以变更表示形式，且在效果处理时仍与该效果关联（未离场）。
function c17243896.filter(c,e,tp)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsSummonPlayer(1-tp) and c:IsCanChangePosition()
		and (not e or c:IsRelateToEffect(e))
end
-- 发动条件：效果持有者（这张卡）必须在自己场上表侧守备表示存在。
function c17243896.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
-- 效果发动时的处理：chk==0时检查eg中是否存在至少1只符合条件的怪兽；确定发动后，将eg全体设为效果对象，并设置操作信息为变更表示形式，数量为eg数量。
function c17243896.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c17243896.filter,1,nil,nil,tp) end
	-- 将本次召唤/特殊召唤成功的怪兽群eg登记为当前连锁的对象，使它们在效果处理时可被确认关联。
	Duel.SetTargetCard(eg)
	-- 设置操作信息：该效果将使eg中的怪兽变更表示形式（CATEGORY_POSITION），预定处理数量为eg的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 效果处理时：从eg中筛选出仍然满足条件的怪兽（表侧攻击表示、对方召唤、可变更且与效果关联），并将它们全部变为守备表示。
function c17243896.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c17243896.filter,nil,e,tp)
	-- 将筛选出的怪兽g全部变为表侧守备表示。
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
end
