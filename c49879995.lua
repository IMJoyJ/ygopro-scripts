--ファントム・ドラゴン
-- 效果：
-- 对方把怪兽特殊召唤成功时，可以从手卡把这张卡特殊召唤。只要这张卡在场上表侧表示存在，自己的怪兽卡区域2处变成不能使用。
function c49879995.initial_effect(c)
	-- 对方把怪兽特殊召唤成功时，可以从手卡把这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49879995,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c49879995.spcon)
	e1:SetTarget(c49879995.sptg)
	e1:SetOperation(c49879995.spop)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，自己的怪兽卡区域2处变成不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_USE_EXTRA_MZONE)
	e2:SetValue(2)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查敌方召唤的怪兽数量是否至少为1张
function c49879995.cfilter(c,tp)
	return c:IsSummonPlayer(1-tp)
end
-- 效果条件：当有敌方怪兽特殊召唤成功时触发
function c49879995.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c49879995.cfilter,1,nil,tp)
end
-- 效果处理目标：判断是否可以将自身从手卡特殊召唤
function c49879995.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，确定将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身特殊召唤到场上
function c49879995.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行将卡片以正面表示形式特殊召唤到场上的操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
