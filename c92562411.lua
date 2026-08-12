--星遺物の導く先
-- 效果：
-- ①：「星遗物引导的前路」在自己场上只能有1张表侧表示存在。
-- ②：每次场上的5星以上的表侧表示怪兽被送去墓地，每有1只给这张卡放置1个指示物（最多7个）。
-- ③：把有7个指示物放置的这张卡送去墓地才能发动。从额外卡组把1只电子界族连接怪兽特殊召唤。
function c92562411.initial_effect(c)
	c:SetUniqueOnField(1,0,92562411)
	c:EnableCounterPermit(0x54)
	c:SetCounterLimit(0x54,7)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：每次场上的5星以上的表侧表示怪兽被送去墓地，每有1只给这张卡放置1个指示物（最多7个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c92562411.ctop)
	c:RegisterEffect(e2)
	-- ③：把有7个指示物放置的这张卡送去墓地才能发动。从额外卡组把1只电子界族连接怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92562411,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c92562411.spcon)
	e3:SetCost(c92562411.spcost)
	e3:SetTarget(c92562411.sptg)
	e3:SetOperation(c92562411.spop)
	c:RegisterEffect(e3)
end
-- 过滤原本在场上是5星以上的表侧表示且被送去墓地的怪兽
function c92562411.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousLevelOnField()>=5
end
-- 统计送去墓地的符合条件的怪兽数量，并为这张卡放置对应数量的指示物
function c92562411.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c92562411.ctfilter,nil)
	if ct>0 then
		e:GetHandler():AddCounter(0x54,ct,true)
	end
end
-- 检查这张卡上的指示物数量是否等于7，作为效果发动的条件
function c92562411.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x54)==7
end
-- 效果发动的代价处理：检查并把这张卡送去墓地
function c92562411.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将这张卡送去墓地作为发动的代价
	Duel.SendtoGrave(c,REASON_COST)
end
-- 过滤额外卡组中可以特殊召唤的电子界族连接怪兽，并确保有可用的额外怪兽区域或连接端
function c92562411.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查在额外卡组特殊召唤该怪兽时，是否有可用的怪兽区域
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动的目标处理：检查是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c92562411.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查额外卡组是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92562411.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表明将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：让玩家从额外卡组选择1只满足条件的电子界族连接怪兽特殊召唤
function c92562411.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的电子界族连接怪兽
	local g=Duel.SelectMatchingCard(tp,c92562411.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
