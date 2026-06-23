--マジシャンズ・サークル
-- 效果：
-- ①：自己或者对方的魔法师族怪兽的攻击宣言时才能发动。双方玩家各自从自己卡组把1只攻击力2000以下的魔法师族怪兽攻击表示特殊召唤。
function c50755.initial_effect(c)
	-- 创建效果，设置为魔法卡发动效果，触发时点为攻击宣言，条件为对方或己方魔法师族怪兽攻击宣言，目标为双方各特殊召唤一只攻击力2000以下的魔法师族怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c50755.condition)
	e1:SetTarget(c50755.target)
	e1:SetOperation(c50755.activate)
	c:RegisterEffect(e1)
end
-- 判断是否为魔法师族怪兽攻击宣言
function c50755.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击怪兽是否为魔法师族
	return Duel.GetAttacker():IsRace(RACE_SPELLCASTER)
end
-- 过滤函数，用于筛选满足条件的魔法师族怪兽（攻击力2000以下且可特殊召唤）
function c50755.filter(c,e,tp)
	return c:IsAttackBelow(2000) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 设置发动时的处理条件，检查己方和对方卡组是否存在符合条件的怪兽，并确保双方场上都有空位
function c50755.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c50755.filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查己方和对方场上是否都有空位可用于特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 设置连锁操作信息，表示将要特殊召唤一张怪兽到己方卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 发动效果处理函数，分别从双方卡组选择符合条件的怪兽并特殊召唤
function c50755.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上是否有空位可用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从己方卡组中选择一张满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c50755.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 将选中的怪兽特殊召唤到己方场上
		if tc then Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) end
	end
	-- 判断对方场上是否有空位可用于特殊召唤
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		-- 提示对方玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从对方卡组中选择一张满足条件的怪兽
		local g=Duel.SelectMatchingCard(1-tp,c50755.filter,1-tp,LOCATION_DECK,0,1,1,nil,e,1-tp)
		local tc=g:GetFirst()
		-- 将选中的怪兽特殊召唤到对方场上
		if tc then Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK) end
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
