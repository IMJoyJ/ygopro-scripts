--宝玉の導き
-- 效果：
-- ①：从卡组把1只「宝玉兽」怪兽特殊召唤。这个效果在自己的魔法与陷阱区域有「宝玉兽」卡2张以上存在的场合才能发动和处理。
function c95326659.initial_effect(c)
	-- ①：从卡组把1只「宝玉兽」怪兽特殊召唤。这个效果在自己的魔法与陷阱区域有「宝玉兽」卡2张以上存在的场合才能发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c95326659.condition)
	e1:SetTarget(c95326659.target)
	e1:SetOperation(c95326659.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示的「宝玉兽」卡片
function c95326659.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
-- 发动条件：自己的魔法与陷阱区域有「宝玉兽」卡2张以上存在
function c95326659.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的魔法与陷阱区域是否存在至少2张表侧表示的「宝玉兽」卡
	return Duel.IsExistingMatchingCard(c95326659.cfilter,tp,LOCATION_SZONE,0,2,nil)
end
-- 过滤条件：卡组中可以被特殊召唤的「宝玉兽」怪兽
function c95326659.filter(c,e,tp)
	return c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检测
function c95326659.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在至少1只可以特殊召唤的「宝玉兽」怪兽
		and Duel.IsExistingMatchingCard(c95326659.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：在效果处理时将从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理函数：从卡组特殊召唤1只「宝玉兽」怪兽
function c95326659.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域空格，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时，若自己的魔法与陷阱区域没有「宝玉兽」卡2张以上存在，则不处理效果
	if not Duel.IsExistingMatchingCard(c95326659.cfilter,tp,LOCATION_SZONE,0,2,nil) then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足特殊召唤条件的「宝玉兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c95326659.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
