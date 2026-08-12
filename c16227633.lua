--メメント・ボーン・バック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的「莫忘」怪兽因对方从场上离开的场合才能发动。从手卡·卡组把1只「冥骸合龙-莫忘冥地王灵」无视召唤条件特殊召唤。
-- ②：这张卡在墓地存在的状态，自己墓地的「莫忘」怪兽因对方从墓地离开的场合，把这张卡除外才能发动。从手卡·卡组把「莫忘」怪兽尽可能特殊召唤（同名卡最多1张）。
local s,id,o=GetID()
-- 注册两个效果，分别对应卡片效果①和②
function s.initial_effect(c)
	-- ①：自己场上的表侧表示的「莫忘」怪兽因对方从场上离开的场合才能发动。从手卡·卡组把1只「冥骸合龙-莫忘冥地王灵」无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己墓地的「莫忘」怪兽因对方从墓地离开的场合，把这张卡除外才能发动。从手卡·卡组把「莫忘」怪兽尽可能特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：上一个位置为正面表示、上一个区域为怪兽区、上一个控制者为自身、离场原因控制者为对方
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x1a1) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 判断是否满足效果①的发动条件
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤条件：卡号为冥骸合龙-莫忘冥地王灵、可以特殊召唤
function s.filter(c,e,tp)
	return c:IsCode(23288411) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 判断是否满足效果①的发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或卡组是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果①的处理函数，选择并特殊召唤1只冥骸合龙-莫忘冥地王灵
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只冥骸合龙-莫忘冥地王灵
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选中的卡特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
end
-- 过滤条件：为莫忘卡组、为怪兽卡、上一个控制者为自身
function s.mfilter(c,tp)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp)
end
-- 判断是否满足效果②的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(s.mfilter,1,nil,tp)
end
-- 过滤条件：为莫忘卡组、可以特殊召唤
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x1a1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足效果②的发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或卡组是否存在满足条件的卡
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，提示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果②的处理函数，选择并特殊召唤尽可能多的莫忘怪兽（最多1张同名卡）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有满足条件的莫忘怪兽
	local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 计算可特殊召唤的数量（取场上空位和不同卡名数的最小值）
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),g:GetClassCount(Card.GetCode))
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡组（确保卡名各不相同）
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,ft,ft)
	-- 将选中的卡组特殊召唤
	if sg then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
end
