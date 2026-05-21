--ファミリア・ナイト
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。双方玩家可以从手卡把1只4星怪兽特殊召唤。
function c89731911.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地的场合发动。双方玩家可以从手卡把1只4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89731911,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c89731911.condition)
	e1:SetTarget(c89731911.target)
	e1:SetOperation(c89731911.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否被战斗破坏并送去墓地。
function c89731911.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤手牌中等级为4且可以特殊召唤的怪兽。
function c89731911.filter(c,e,tp)
	return c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的效果处理目标确认，由于是必发效果，直接返回true，并设置特殊召唤的操作信息。
function c89731911.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数，依次处理回合玩家和对方玩家是否从手牌特殊召唤4星怪兽。
function c89731911.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家场上是否有可用的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查回合玩家手牌中是否存在满足条件的4星怪兽。
		and Duel.IsExistingMatchingCard(c89731911.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 询问回合玩家是否选择进行特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(89731911,1)) then  --"是否要特殊召唤？"
		-- 提示回合玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让回合玩家从手牌选择1只满足条件的4星怪兽。
		local g1=Duel.SelectMatchingCard(tp,c89731911.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将回合玩家选择的怪兽以表侧表示特殊召唤的准备步骤。
		Duel.SpecialSummonStep(g1:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
	end
	-- 检查对方玩家场上是否有可用的怪兽区域。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查对方玩家手牌中是否存在满足条件的4星怪兽。
		and Duel.IsExistingMatchingCard(c89731911.filter,1-tp,LOCATION_HAND,0,1,nil,e,1-tp)
		-- 询问对方玩家是否选择进行特殊召唤。
		and Duel.SelectYesNo(1-tp,aux.Stringid(89731911,1)) then  --"是否要特殊召唤？"
		-- 提示对方玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让对方玩家从手牌选择1只满足条件的4星怪兽。
		local g2=Duel.SelectMatchingCard(1-tp,c89731911.filter,1-tp,LOCATION_HAND,0,1,1,nil,e,1-tp)
		-- 将对方玩家选择的怪兽以表侧表示特殊召唤的准备步骤。
		Duel.SpecialSummonStep(g2:GetFirst(),0,1-tp,1-tp,false,false,POS_FACEUP)
	end
	-- 完成所有被特殊召唤怪兽的特殊召唤处理。
	Duel.SpecialSummonComplete()
end
