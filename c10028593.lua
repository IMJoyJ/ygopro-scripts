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
-- 特殊召唤效果的发动条件判断：判断离场前的此卡是否为表侧表示
function c10028593.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 特殊召唤效果的发动条件与靶指向：设定特殊召唤的操作信息
function c10028593.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：从卡组把1只卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤条件：卡组中卡名为「轮回天狗」且可以特殊召唤的怪兽
function c10028593.spfilter(c,e,tp)
	return c:IsCode(10028593) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的处理：从卡组把1只「轮回天狗」特殊召唤
function c10028593.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在可用于特殊召唤的空余怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组获取第1只符合特殊召唤条件且卡名为「轮回天狗」的怪兽
	local tc=Duel.GetFirstMatchingCard(c10028593.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 以效果将该怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
