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
-- 效果发动时的条件判断，确保该卡离开场上的位置是正面表示
function c10028593.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 效果的处理目标设定，表示将要特殊召唤1只轮回天狗
function c10028593.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息，表明本次效果会将卡组中的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 用于筛选卡组中符合条件的轮回天狗卡片
function c10028593.spfilter(c,e,tp)
	return c:IsCode(10028593) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的处理流程，执行从卡组特殊召唤的操作
function c10028593.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有足够空间进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组中检索满足条件的轮回天狗卡片
	local tc=Duel.GetFirstMatchingCard(c10028593.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将检索到的轮回天狗从卡组特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
