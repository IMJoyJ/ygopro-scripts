--毒蛇の怨念
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，爬虫类族以外的自己怪兽不能攻击，不能把效果发动。
-- ②：自己场上的表侧表示的爬虫类族怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。从卡组把1只4星以下的爬虫类族怪兽特殊召唤。
-- ③：魔法与陷阱区域的这张卡被破坏的场合才能发动。除外的自己的爬虫类族怪兽全部回到墓地。
function c1683982.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在魔法与陷阱区域存在，爬虫类族以外的自己怪兽不能攻击，不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c1683982.atktg)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e2)
	-- ②：自己场上的表侧表示的爬虫类族怪兽被战斗破坏的场合或者被送去墓地的场合才能发动。从卡组把1只4星以下的爬虫类族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1683982,1))  --"从卡组特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,1683982)
	e3:SetCondition(c1683982.spcon)
	e3:SetTarget(c1683982.sptg)
	e3:SetOperation(c1683982.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c1683982.spcon2)
	c:RegisterEffect(e4)
	-- ③：魔法与陷阱区域的这张卡被破坏的场合才能发动。除外的自己的爬虫类族怪兽全部回到墓地。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(1683982,2))
	e6:SetCategory(CATEGORY_TOGRAVE)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCountLimit(1,1683983)
	e6:SetCondition(c1683982.tgcon)
	e6:SetTarget(c1683982.tgtg)
	e6:SetOperation(c1683982.tgop)
	c:RegisterEffect(e6)
end
-- 效果作用：禁止非爬虫类族的自己怪兽攻击
function c1683982.atktg(e,c)
	return not c:IsRace(RACE_REPTILE)
end
-- 效果作用：判断被破坏或送去墓地的怪兽是否为爬虫类族且为自己的怪兽
function c1683982.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE) and c:GetPreviousRaceOnField()&RACE_REPTILE~=0
end
-- 效果作用：满足条件时发动②效果
function c1683982.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1683982.cfilter,1,nil,tp)
end
-- 效果作用：判断送去墓地的怪兽是否为爬虫类族且为自己的怪兽
function c1683982.cfilter2(c,tp)
	return not c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetPreviousRaceOnField()&RACE_REPTILE~=0 and c:IsRace(RACE_REPTILE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果作用：满足条件时发动②效果
function c1683982.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c1683982.cfilter2,1,nil,tp)
end
-- 效果作用：筛选满足条件的爬虫类族4星以下怪兽
function c1683982.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足②效果发动条件
function c1683982.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c1683982.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 效果作用：设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行②效果的处理
function c1683982.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c1683982.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果作用：判断此卡是否从魔法与陷阱区域被破坏
function c1683982.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 效果作用：筛选满足条件的爬虫类族怪兽
function c1683982.filter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsFaceup()
end
-- 效果作用：判断是否满足③效果发动条件
function c1683982.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断除外区是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c1683982.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 效果作用：获取满足条件的除外怪兽
	local g=Duel.GetMatchingGroup(c1683982.filter,tp,LOCATION_REMOVED,0,nil)
	-- 效果作用：设置操作信息为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
-- 效果作用：执行③效果的处理
function c1683982.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取满足条件的除外怪兽
	local g=Duel.GetMatchingGroup(c1683982.filter,tp,LOCATION_REMOVED,0,nil)
	-- 效果作用：将选中的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
end
