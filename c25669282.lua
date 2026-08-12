--完全燃焼
-- 效果：
-- 「完全燃烧」在1回合只能发动1张。
-- ①：把自己场上1只表侧表示的「化合兽」怪兽除外才能发动。从卡组把2只「化合兽」怪兽特殊召唤（同名卡最多1张）。
-- ②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外，以除外的1只自己的二重怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽当作再1次召唤的状态使用。这个效果在这张卡送去墓地的回合不能发动。
function c25669282.initial_effect(c)
	-- ①：把自己场上1只表侧表示的「化合兽」怪兽除外才能发动。从卡组把2只「化合兽」怪兽特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,25669282+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c25669282.cost)
	e1:SetTarget(c25669282.target)
	e1:SetOperation(c25669282.activate)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外，以除外的1只自己的二重怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽当作再1次召唤的状态使用。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25669282,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c25669282.spcon)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c25669282.sptg)
	e2:SetOperation(c25669282.spop)
	c:RegisterEffect(e2)
end
c25669282.has_text_type=TYPE_DUAL
-- 过滤函数，用于检测场上是否有满足条件的「化合兽」怪兽（表侧表示且可作为除外的cost）
function c25669282.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xeb) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的cost处理，选择场上1只「化合兽」怪兽除外
function c25669282.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即场上是否存在1只可除外的「化合兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c25669282.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上满足条件的1只怪兽作为除外对象
	local g=Duel.SelectMatchingCard(tp,c25669282.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽除外作为发动cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于检测卡组中是否存在满足条件的「化合兽」怪兽（可特殊召唤且能配合另一只怪兽）
function c25669282.spfilter1(c,e,tp)
	return c:IsSetCard(0xeb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测卡组中是否存在满足条件的第二只「化合兽」怪兽（与第一只不同名）
		and Duel.IsExistingMatchingCard(c25669282.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetCode())
end
-- 过滤函数，用于检测卡组中是否存在满足条件的「化合兽」怪兽（可特殊召唤且与第一只不同名）
function c25669282.spfilter2(c,e,tp,code)
	return c:IsSetCard(0xeb) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理，检测是否满足发动条件，即未被【青眼精灵龙】影响且卡组中存在满足条件的怪兽
function c25669282.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测场上是否有足够的位置进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测卡组中是否存在满足条件的「化合兽」怪兽
		and Duel.IsExistingMatchingCard(c25669282.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果发动时的处理，从卡组特殊召唤2只「化合兽」怪兽
function c25669282.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测场上是否有足够的位置进行特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择卡组中满足条件的第一只怪兽
		local g1=Duel.SelectMatchingCard(tp,c25669282.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g1:GetCount()<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择卡组中满足条件的第二只怪兽（与第一只不同名）
		local g2=Duel.SelectMatchingCard(tp,c25669282.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,g1:GetFirst():GetCode())
		g1:Merge(g2)
		-- 将选中的2只怪兽特殊召唤
		Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动时的条件判断，检测是否满足发动条件，即对方怪兽直接攻击且此卡未在送去墓地的回合
function c25669282.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件，即对方怪兽直接攻击且此卡未在送去墓地的回合
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil and aux.exccon(e)
end
-- 过滤函数，用于检测墓地中是否存在满足条件的二重怪兽（可特殊召唤）
function c25669282.spfilter3(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理，检测是否满足发动条件，即墓地中存在满足条件的二重怪兽
function c25669282.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c25669282.spfilter3(chkc,e,tp) end
	-- 检测场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测墓地中是否存在满足条件的二重怪兽
		and Duel.IsExistingTarget(c25669282.spfilter3,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中满足条件的1只二重怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c25669282.spfilter3,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果发动时的处理，将选中的二重怪兽特殊召唤并启用二重状态
function c25669282.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且能特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:EnableDualState()
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
