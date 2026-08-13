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
-- 在战斗伤害区域内生成一个永续效果：本回合内使己方玩家受到的全部战斗伤害变为0。
function c35050257.op1(e,tp,eg,ep,ev,re,r,rp)
	-- ②：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只「电子幼体」特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新生成的“己方不受战斗伤害”的永续效果注册到当前决斗中，并指定由己方玩家tp作为该效果的承受者。
	Duel.RegisterEffect(e1,tp)
end
-- 判定效果②的发动条件：这张卡当前位于墓地，并且是被战斗破坏而送去墓地的。
function c35050257.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：候选卡必须是卡号35050257（电子幼体），并且可以进行特殊召唤。
function c35050257.filter(c,e,tp)
	return c:IsCode(35050257) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动与处理目标设定：检查能否满足特殊召唤条件，并检索卡组中符合条件的电子幼体。
function c35050257.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时（chk==0）检查：自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果发动时（chk==0）继续检查：卡组中是否存在1张以上满足特招条件的电子幼体。
		and Duel.IsExistingMatchingCard(c35050257.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次连锁的处理信息设置为：从卡组把1只电子幼体特殊召唤（数量为1，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②处理时执行特殊召唤整个流程：先确认空位，再从卡组找符合条件的卡并特殊召唤。
function c35050257.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的主要怪兽区空格，则终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组获取第一张满足特招条件的电子幼体。
	local tc=Duel.GetFirstMatchingCard(c35050257.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将选中的电子幼体以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
