--ベビケラサウルス
-- 效果：
-- ①：这张卡被效果破坏送去墓地的场合发动。从卡组把1只4星以下的恐龙族怪兽特殊召唤。
function c36042004.initial_effect(c)
	-- 效果原文内容：①：这张卡被效果破坏送去墓地的场合发动。从卡组把1只4星以下的恐龙族怪兽特殊召唤。
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
-- 规则层面操作：判断破坏原因是否包含效果破坏（REASON_EFFECT）和送去墓地（REASON_DESTROY）
function c36042004.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41
end
-- 规则层面操作：过滤满足等级4以下、恐龙族、可以特殊召唤的怪兽
function c36042004.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DINOSAUR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：设置连锁处理信息，表示将要从卡组特殊召唤1只怪兽
function c36042004.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置连锁处理信息，表示将要从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：检查场上是否有空位，若无则不执行特殊召唤；否则提示选择并执行特殊召唤
function c36042004.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查玩家场上是否有空位，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：从卡组选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c36042004.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
