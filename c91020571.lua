--地征竜－リアクタン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把1只龙族或地属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把1只「岩征龙-锈龙」特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c91020571.initial_effect(c)
	-- 记录这张卡的效果中记有「岩征龙-锈龙」的卡名
	aux.AddCodeList(c,90411554)
	-- ①：把1只龙族或地属性的怪兽和这张卡从手卡丢弃才能发动。从卡组把1只「岩征龙-锈龙」特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91020571,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,91020571)
	e1:SetCost(c91020571.spcost)
	e1:SetTarget(c91020571.sptg)
	e1:SetOperation(c91020571.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：手牌中可丢弃的龙族或地属性怪兽
function c91020571.costfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_EARTH)) and c:IsDiscardable()
end
-- 代价检查：自身可丢弃，且手牌中存在除自身以外满足过滤条件的怪兽
function c91020571.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable()
		-- 检查手牌中是否存在至少1只除自身以外的龙族或地属性怪兽
		and Duel.IsExistingMatchingCard(c91020571.costfilter,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家选择1只除自身以外的手牌中的龙族或地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c91020571.costfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选中的怪兽和这张卡作为发动代价一起送去墓地（丢弃）
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中可以特殊召唤的「岩征龙-锈龙」
function c91020571.spfilter(c,e,tp)
	return c:IsCode(90411554) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标检查：检查怪兽区域是否有空位，且卡组中是否存在可特殊召唤的「岩征龙-锈龙」
function c91020571.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只可以特殊召唤的「岩征龙-锈龙」
		and Duel.IsExistingMatchingCard(c91020571.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组特殊召唤1只「岩征龙-锈龙」，并使其在本回合不能攻击
function c91020571.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取卡组中第1只满足条件的「岩征龙-锈龙」
	local tc=Duel.GetFirstMatchingCard(c91020571.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 若存在该怪兽，则尝试将其以表侧表示特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
