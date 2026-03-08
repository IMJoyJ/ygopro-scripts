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
-- 检查触发效果的条件：卡片在墓地且因战斗破坏被送去墓地
function c42737833.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：选择等级4以下、种族为「X-剑士」且可以特殊召唤的怪兽
function c42737833.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x100d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理：确认场上是否有空位且卡组中存在满足条件的怪兽
function c42737833.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c42737833.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：准备从卡组特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理：若场上存在空位则提示选择并特殊召唤符合条件的怪兽
function c42737833.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查场上是否有空位，若无则取消特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c42737833.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽正面表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
