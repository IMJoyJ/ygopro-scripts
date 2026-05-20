--創造の代行者 ヴィーナス
-- 效果：
-- ①：支付500基本分才能发动。从手卡·卡组把1只「神圣球体」特殊召唤。
function c64734921.initial_effect(c)
	-- ①：支付500基本分才能发动。从手卡·卡组把1只「神圣球体」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64734921,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c64734921.spcost)
	e1:SetTarget(c64734921.sptg)
	e1:SetOperation(c64734921.spop)
	c:RegisterEffect(e1)
end
-- 效果发动代价处理：检查并支付500基本分
function c64734921.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤条件：卡名是「神圣球体」且可以被特殊召唤
function c64734921.filter(c,e,tp)
	return c:IsCode(39552864) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标处理：检查怪兽区域空位及手卡·卡组是否存在可特召的「神圣球体」，并设置操作信息
function c64734921.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或卡组中是否存在至少1只满足条件的「神圣球体」
		and Duel.IsExistingMatchingCard(c64734921.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果运行处理：从手卡·卡组将1只「神圣球体」特殊召唤
function c64734921.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡或卡组中选择1只满足条件的「神圣球体」
	local g=Duel.SelectMatchingCard(tp,c64734921.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
