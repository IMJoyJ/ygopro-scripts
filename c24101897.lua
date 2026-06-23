--ゴーストリックの猫娘
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，只要场上有这张卡以外的名字带有「鬼计」的怪兽存在，4星以上的怪兽召唤·特殊召唤成功时，那些怪兽变成里侧守备表示。
function c24101897.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合不能让这张卡表侧表示召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c24101897.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24101897,0))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c24101897.postg)
	e2:SetOperation(c24101897.posop)
	c:RegisterEffect(e2)
	-- 只要场上有这张卡以外的名字带有「鬼计」的怪兽存在，4星以上的怪兽召唤·特殊召唤成功时，那些怪兽变成里侧守备表示
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24101897,1))  --"变成里侧守备"
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c24101897.condition)
	e3:SetTarget(c24101897.target)
	e3:SetOperation(c24101897.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在名字带有「鬼计」的表侧表示怪兽
function c24101897.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 判断自己场上有无名字带有「鬼计」的怪兽
function c24101897.sumcon(e)
	-- 检查自己场上有无名字带有「鬼计」的怪兽
	return not Duel.IsExistingMatchingCard(c24101897.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 设置效果处理时的条件，判断是否可以将此卡变为里侧守备表示
function c24101897.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(24101897)==0 end
	c:RegisterFlagEffect(24101897,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息，表示此效果会将目标怪兽变为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理函数，将此卡变为里侧守备表示
function c24101897.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 判断场上有无名字带有「鬼计」的怪兽（除自身外）
function c24101897.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上有无名字带有「鬼计」的怪兽（除自身外）
	return Duel.IsExistingMatchingCard(c24101897.sfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 过滤函数，用于筛选满足条件的怪兽（表侧表示、4星以上、可以变为里侧守备）
function c24101897.filter(c,e)
	return c:IsFaceup() and c:IsLevelAbove(4) and c:IsCanTurnSet() and (not e or c:IsRelateToEffect(e))
end
-- 设置效果处理时的目标，筛选满足条件的怪兽并设置操作信息
function c24101897.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c24101897.filter,1,nil) end
	-- 设置当前处理的连锁的目标为怪兽群
	Duel.SetTargetCard(eg)
	local g=eg:Filter(c24101897.filter,nil)
	-- 设置操作信息，表示此效果会将目标怪兽变为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理函数，将满足条件的怪兽变为里侧守备表示
function c24101897.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上有无名字带有「鬼计」的怪兽（除自身外）
	if not Duel.IsExistingMatchingCard(c24101897.sfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then return end
	local g=eg:Filter(c24101897.filter,nil,e)
	-- 将目标怪兽变为里侧守备表示
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
