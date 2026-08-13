--アギド
-- 效果：
-- 这张卡被战斗破坏送去墓地时，掷1次骰子。可以从自己的墓地中特殊召唤1只等级与掷出点数相同的天使族怪兽上场。（若掷出6，则包括6星以上的怪兽）。
function c16135253.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，掷1次骰子。可以从自己的墓地中特殊召唤1只等级与掷出点数相同的天使族怪兽上场。（若掷出6，则包括6星以上的怪兽）。
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
-- 诱发条件判定：效果持有者必须位于墓地，且是因为被战斗破坏而送去墓地，满足条件时才发动。
function c16135253.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选墓地中可被特殊召唤的天使族怪兽：骰子点数不为6时要求等级与点数相同；点数为6时要求6星以上；同时满足种族为天使族且可被当前效果特殊召唤。
function c16135253.filter(c,e,tp,lv)
	if (lv~=6 and not c:IsLevel(lv) and c:IsLevelAbove(1)) or (lv==6 and c:IsLevelBelow(5)) then return false end
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时无需选择对象，直接返回可发动；同时登记操作信息，表明本效果将进行掷骰子。
function c16135253.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次连锁包含“由我方掷1次骰子”的操作信息，供骰子相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理时：先检查我方怪兽区域是否有空格，然后掷骰子，按点数从墓地筛选符合条件的可特殊召唤的天使族怪兽；若有候选则询问是否特殊召唤，选定后将其特殊召唤。
function c16135253.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果我方主要怪兽区域没有可用空格，则不能进行特殊召唤，效果处理直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 我方投掷1次骰子，结果dc为1至6的整数，作为后续筛选等级的依据。
	local dc=Duel.TossDice(tp,1)
	-- 从我方墓地将满足等级/种族/可特殊召唤条件且不受王家长眠之谷影响的天使族怪兽全部选出，作为候选组g。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c16135253.filter),tp,LOCATION_GRAVE,0,nil,e,tp,dc)
	-- 若存在候选怪兽，则向玩家弹出“是否要特殊召唤天使族怪兽？”的确认询问，玩家确认后才继续处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(16135253,1)) then  --"是否要特殊召唤天使族怪兽？"
		-- 发送“请选择要特殊召唤的卡”的提示，并进入卡牌选择流程。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的目标以表侧表示特殊召唤到我方场上；此处不跳过召唤条件与苏生限制的检查。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
