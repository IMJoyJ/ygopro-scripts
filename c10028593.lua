--輪廻天狗
-- 效果：
-- ①：表侧表示的这张卡从场上离开的场合发动。从卡组把1只「轮回天狗」特殊召唤。
function c10028593.initial_effect(c)
	-- ①：表侧表示的这张卡从场上离开的场合发动。从卡组把1只「轮回天狗」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10028593,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCondition(c10028593.spcon)
	e1:SetTarget(c10028593.sptg)
	e1:SetOperation(c10028593.spop)
	c:RegisterEffect(e1)
end
-- 效果触发条件：表侧表示离场
function c10028593.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 特殊召唤效果的目标锁定与声明
function c10028593.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 声明特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中的「轮回天狗」
function c10028593.spfilter(c,e,tp)
	return c:IsCode(10028593) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的实际操作
function c10028593.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空余的怪兽位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取卡组中的第一只「轮回天狗」
	local tc=Duel.GetFirstMatchingCard(c10028593.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将选中的轮回天狗特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
