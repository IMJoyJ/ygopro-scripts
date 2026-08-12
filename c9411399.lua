--D-HERO ディアボリックガイ
function c9411399.initial_effect(c)
	-- 把墓地的这张卡除外才能发动。从卡组把1只「D-HERO ディアボリックガイ」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9411399,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置发动代价为将墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c9411399.target)
	e1:SetOperation(c9411399.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：卡名是「D-HERO ディアボリックガイ」且可以被特殊召唤的卡
function c9411399.filter(c,e,sp)
	return c:IsCode(9411399) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果发动的目标选择与检测函数
function c9411399.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9411399.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 并且检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数
function c9411399.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果此时自己场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取卡组中第一张满足过滤条件的卡
	local sc=Duel.GetFirstMatchingCard(c9411399.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if sc then
		-- 将该卡以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end
