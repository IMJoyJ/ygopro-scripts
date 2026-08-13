--マジシャンズ・サークル
-- 效果：
-- ①：自己或者对方的魔法师族怪兽的攻击宣言时才能发动。双方玩家各自从自己卡组把1只攻击力2000以下的魔法师族怪兽攻击表示特殊召唤。
function c50755.initial_effect(c)
	-- ①：自己或者对方的魔法师族怪兽的攻击宣言时才能发动。双方玩家各自从自己卡组把1只攻击力2000以下的魔法师族怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c50755.condition)
	e1:SetTarget(c50755.target)
	e1:SetOperation(c50755.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：仅在攻击宣言时且攻击怪兽为魔法师族的情况下允许发动。
function c50755.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发起攻击宣言的怪兽是否属于魔法师族，是则满足发动条件。
	return Duel.GetAttacker():IsRace(RACE_SPELLCASTER)
end
-- 定义怪兽筛选函数：要求攻击力2000以下、种族为魔法师族，且能被效果以表侧攻击表示特殊召唤。
function c50755.filter(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 定义发动前确认函数：检查双方卡组是否各有至少1只符合条件的怪兽，且双方主要怪兽区均有空位。
function c50755.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家卡组中是否存在至少1只符合条件的魔法师族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c50755.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查双方玩家主要怪兽区是否都有空位，以保证双方都能进行特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 设置操作信息，宣告本效果包含特殊召唤操作，来源为卡组，供连锁检测与响应使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理函数：双方玩家各自从自己卡组选择符合条件的怪兽，以表侧攻击表示特殊召唤到各自场上。
function c50755.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前玩家场上主要怪兽区有空位，则开始处理己方的特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向当前玩家显示选择要特殊召唤的怪兽的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让当前玩家从自己卡组选择1张符合条件的魔法师族怪兽。
		local g=Duel.SelectMatchingCard(tp,c50755.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 若成功选择到怪兽，则将其以表侧攻击表示特殊召唤到当前玩家场上，作为连续特殊召唤的一步。
		if tc then Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) end
	end
	-- 若对方玩家场上主要怪兽区有空位，则开始处理对方的特殊召唤。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		-- 向对方玩家显示选择要特殊召唤的怪兽的提示。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让对方玩家从自己卡组选择1张符合条件的魔法师族怪兽。
		local g=Duel.SelectMatchingCard(1-tp,c50755.filter,1-tp,LOCATION_DECK,0,1,1,nil,e,1-tp)
		local tc=g:GetFirst()
		-- 若成功选择到怪兽，则将其以表侧攻击表示特殊召唤到对方玩家场上，作为连续特殊召唤的一步。
		if tc then Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK) end
	end
	-- 完成所有特殊召唤手续，统一触发特殊召唤成功的相关时点。
	Duel.SpecialSummonComplete()
end
