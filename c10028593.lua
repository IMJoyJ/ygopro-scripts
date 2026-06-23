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
-- 发动条件：判断这张卡在离场前是否为表侧表示
function c10028593.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 特殊召唤效果的目标选择与操作信息设置：在连锁中注册从卡组将1张卡特殊召唤的操作
function c10028593.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：在连锁中注册特殊召唤操作，目标为自己卡组的1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：判断卡片是否为「轮回天狗」，且可以被特殊召唤
function c10028593.spfilter(c,e,tp)
	return c:IsCode(10028593) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的执行操作：若自己怪兽区有空位，从卡组检索1只「轮回天狗」并特殊召唤
function c10028593.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己怪兽区是否存在可用的空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组中检索第一张满足过滤条件的「轮回天狗」
	local tc=Duel.GetFirstMatchingCard(c10028593.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 以效果将检索到的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
