--XX－セイバー エマーズブレイド
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只4星以下的「X-剑士」怪兽特殊召唤。
function c42737833.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只4星以下的「X-剑士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42737833,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c42737833.condition)
	e1:SetTarget(c42737833.target)
	e1:SetOperation(c42737833.operation)
	c:RegisterEffect(e1)
end
-- 判定发动条件：效果持有者位于墓地，且是被战斗破坏（满足“这张卡被战斗破坏送去墓地时”）。
function c42737833.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义可特殊召唤的卡牌条件：4星以下、卡名含有「X-剑士」字段、并且可以被特殊召唤。
function c42737833.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x100d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时可行性检查：自己主要怪兽区有空位，且卡组中存在符合条件的「X-剑士」怪兽。
function c42737833.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足filter条件的「X-剑士」怪兽。
		and Duel.IsExistingMatchingCard(c42737833.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置本次连锁的特殊召唤操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若场上仍有空位，则从卡组选择1只符合条件的「X-剑士」怪兽，以表侧表示特殊召唤。
function c42737833.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有可用主要怪兽区空位，没有则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家展示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选出1张满足filter条件的「X-剑士」怪兽。
	local g=Duel.SelectMatchingCard(tp,c42737833.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上（默认表侧攻击表示）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
