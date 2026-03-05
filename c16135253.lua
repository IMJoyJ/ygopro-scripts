--アギド
-- 效果：
-- 这张卡被战斗破坏送去墓地时，掷1次骰子。可以从自己的墓地中特殊召唤1只等级与掷出点数相同的天使族怪兽上场。（若掷出6，则包括6星以上的怪兽）。
function c16135253.initial_effect(c)
	-- 效果原文：这张卡被战斗破坏送去墓地时，掷1次骰子。可以从自己的墓地中特殊召唤1只等级与掷出点数相同的天使族怪兽上场。（若掷出6，则包括6星以上的怪兽）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16135253,0))  --"掷骰子"
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c16135253.condition)
	e1:SetTarget(c16135253.target)
	e1:SetOperation(c16135253.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：判断此卡是否因战斗破坏而送入墓地
function c16135253.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 效果作用：过滤满足等级条件且为天使族的怪兽
function c16135253.filter(c,e,tp,lv)
	if (lv~=6 and not c:IsLevel(lv) and c:IsLevelAbove(1)) or (lv==6 and c:IsLevelBelow(5)) then return false end
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置骰子效果的连锁信息
function c16135253.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置骰子效果的连锁信息
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果原文：这张卡被战斗破坏送去墓地时，掷1次骰子。可以从自己的墓地中特殊召唤1只等级与掷出点数相同的天使族怪兽上场。（若掷出6，则包括6星以上的怪兽）。
function c16135253.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断场上是否有特殊召唤怪兽的空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果作用：让玩家投掷一次骰子
	local dc=Duel.TossDice(tp,1)
	-- 效果作用：检索满足等级和种族条件的墓地怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c16135253.filter),tp,LOCATION_GRAVE,0,nil,e,tp,dc)
	-- 效果作用：判断是否有符合条件的怪兽且玩家选择特殊召唤
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(16135253,1)) then  --"是否要特殊召唤天使族怪兽？"
		-- 效果作用：提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 效果作用：将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
