--ヘル・セキュリティ
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合发动。从卡组把1只恶魔族·1星怪兽特殊召唤。
function c50732780.initial_effect(c)
	-- 效果原文内容：①：这张卡被战斗破坏送去墓地的场合发动。从卡组把1只恶魔族·1星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50732780,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c50732780.condition)
	e1:SetTarget(c50732780.target)
	e1:SetOperation(c50732780.operation)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断该卡是否因战斗破坏而送入墓地
function c50732780.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 规则层面操作：筛选满足条件的卡片组（恶魔族、1星、可特殊召唤）
function c50732780.filter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：设置连锁处理信息，确定将要特殊召唤的卡的类型为CATEGORY_SPECIAL_SUMMON
function c50732780.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置当前处理的连锁的操作信息，指定目标为卡组中的一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：检查场上是否有空位，若无则不执行；若有则提示选择并特殊召唤符合条件的怪兽
function c50732780.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断玩家场上是否还有可用区域用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：向玩家发送提示信息“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：从卡组中选择满足条件的1只怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,c50732780.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
