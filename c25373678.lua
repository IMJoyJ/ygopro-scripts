--旋風のボルテクス
-- 效果：
-- 调整＋调整以外的鸟兽族怪兽1只以上
-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只4星以下的鸟兽族怪兽特殊召唤。
function c25373678.initial_effect(c)
	-- 为这张卡添加同调召唤手续：要求“调整＋调整以外的鸟兽族怪兽1只以上”作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_WINDBEAST),1)
	c:EnableReviveLimit()
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只4星以下的鸟兽族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25373678,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c25373678.condition)
	e1:SetTarget(c25373678.target)
	e1:SetOperation(c25373678.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：该卡必须位于墓地且破坏原因为战斗，即满足“被战斗破坏送去墓地”这一时点。
function c25373678.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义可特殊召唤的怪兽的过滤条件：等级4以下、鸟兽族、且可以被特殊召唤。
function c25373678.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的合法性检查：自己主要怪兽区有空位，并且卡组中存在符合特殊召唤条件的鸟兽族怪兽。
function c25373678.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区域是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足filter条件的鸟兽族怪兽。
		and Duel.IsExistingMatchingCard(c25373678.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果处理将进行特殊召唤，处理玩家为tp，从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的实际操作：确认空位后，从卡组选择1只符合条件的鸟兽族怪兽，以表侧表示特殊召唤到自己场上。
function c25373678.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理阶段再次确认自己主要怪兽区有空位，若没有空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向tp玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让tp玩家从自己卡组选择1张满足filter条件的鸟兽族怪兽（4星以下且可特殊召唤）作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c25373678.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
