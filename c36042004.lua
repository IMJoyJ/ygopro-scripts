--ベビケラサウルス
-- 效果：
-- ①：这张卡被效果破坏送去墓地的场合发动。从卡组把1只4星以下的恐龙族怪兽特殊召唤。
function c36042004.initial_effect(c)
	-- ①：这张卡被效果破坏送去墓地的场合发动。从卡组把1只4星以下的恐龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36042004,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c36042004.condition)
	e1:SetTarget(c36042004.target)
	e1:SetOperation(c36042004.operation)
	c:RegisterEffect(e1)
end
-- 判定这张卡被送去墓地的原因是否为效果破坏（通过位运算检查r同时包含效果破坏相关标志位）。
function c36042004.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41
end
-- 筛选条件：满足4星以下、恐龙族且能被当前效果特殊召唤的怪兽。
function c36042004.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DINOSAUR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标阶段：仅在发动时返回true，并设置本次操作的信息为从卡组特殊召唤1只怪兽。
function c36042004.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果属于特殊召唤分类，从卡组特殊召唤1只怪兽（处理时确定具体卡），目标玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：先确认我方主要怪兽区有空位，然后从卡组选择1只符合条件的恐龙族怪兽以表侧表示特殊召唤。
function c36042004.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方主要怪兽区没有可用的空格，则效果处理失败，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家tp弹出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从tp的卡组中选择1张满足filter过滤条件的卡，不取对象，在处理时确定具体特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,c36042004.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到tp的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
