--スネークアイ・ワイトバーチ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：对方回合，把包含这张卡的自己场上2张表侧表示卡送去墓地才能发动。从手卡·卡组把「蛇眼桦树灵」以外的1只「蛇眼」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片的两个效果：①特殊召唤条件；②对方回合发动的效果
function s.initial_effect(c)
	-- ①：自己场上有炎属性怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.spscon)
	c:RegisterEffect(e1)
	-- ②：对方回合，把包含这张卡的自己场上2张表侧表示卡送去墓地才能发动。从手卡·卡组把「蛇眼桦树灵」以外的1只「蛇眼」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在正面表示的炎属性怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 判断手牌特殊召唤的条件：场上存在怪兽区且有炎属性怪兽
function s.spscon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断手牌特殊召唤的条件：场上存在怪兽区
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌特殊召唤的条件：场上存在正面表示的炎属性怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断对方回合发动效果的条件：当前回合玩家为对方
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方回合发动效果的条件：当前回合玩家为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤函数，用于判断场上正面表示且能作为墓地代价的卡
function s.cfilter(c,tc,tp)
	-- 判断场上正面表示且能作为墓地代价的卡
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,Group.FromCards(c,tc))>0
end
-- 处理发动效果的费用：选择场上2张表侧表示卡送去墓地
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断发动效果的费用是否满足：手牌能送去墓地且场上存在满足条件的卡
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,c,c,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上满足条件的卡并加上自身组成送去墓地的卡组
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,c,tp)+c
	-- 将卡组送去墓地作为发动效果的费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于筛选「蛇眼」怪兽且能特殊召唤的卡
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x19c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- 设置发动效果的目标：从手卡或卡组特殊召唤一只「蛇眼」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断发动效果是否满足：场上存在怪兽区或已支付费用
	if chk==0 then return (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		-- 判断发动效果是否满足：手卡或卡组存在满足条件的「蛇眼」怪兽
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理的操作信息：准备特殊召唤一只「蛇眼」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 处理发动效果的执行：选择并特殊召唤一只「蛇眼」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否能特殊召唤：场上存在怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「蛇眼」怪兽
	local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将卡组中的「蛇眼」怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
