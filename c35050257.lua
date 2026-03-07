--サイバー・ラーバァ
-- 效果：
-- ①：这张卡被选择作为攻击对象的场合发动。这个回合，自己受到的全部战斗伤害变成0。
-- ②：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只「电子幼体」特殊召唤。
function c35050257.initial_effect(c)
	-- ①：这张卡被选择作为攻击对象的场合发动。这个回合，自己受到的全部战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35050257,0))  --"战斗伤害变成0"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetOperation(c35050257.op1)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只「电子幼体」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35050257,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c35050257.condition)
	e2:SetTarget(c35050257.target)
	e2:SetOperation(c35050257.operation)
	c:RegisterEffect(e2)
end
-- 效果作用：使自己在该回合内不会受到战斗伤害
function c35050257.op1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：使自己在该回合内不会受到战斗伤害
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家的全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：判断卡片是否因战斗破坏而送入墓地
function c35050257.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果作用：过滤满足条件的「电子幼体」卡片
function c35050257.filter(c,e,tp)
	return c:IsCode(35050257) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否满足发动特殊召唤的条件
function c35050257.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的「电子幼体」卡片
		and Duel.IsExistingMatchingCard(c35050257.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行特殊召唤操作
function c35050257.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组中检索满足条件的第一张「电子幼体」卡片
	local tc=Duel.GetFirstMatchingCard(c35050257.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将检索到的卡片特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
