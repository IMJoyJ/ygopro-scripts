--レッド・スプリンター
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤时，若自己场上没有其他怪兽存在则能发动。从自己的手卡·墓地把1只3星以下的恶魔族调整特殊召唤。
function c14886469.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·特殊召唤时，若自己场上没有其他怪兽存在则能发动。从自己的手卡·墓地把1只3星以下的恶魔族调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14886469,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,14886469)
	e1:SetCondition(c14886469.spcon)
	e1:SetTarget(c14886469.sptg)
	e1:SetOperation(c14886469.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 发动条件函数：检查自己场上是否不存在除这张卡以外的其他怪兽（排除效果持有者自身），满足才能发动。
function c14886469.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回自己场上不存在其他怪兽的判定结果：若存在任意除自身以外的怪兽则条件不满足，否则条件成立。
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 筛选条件函数：对象须为等级3以下、恶魔族、调整怪兽，并且能够被当前效果特殊召唤（不忽略召唤条件与苏生限制）。
function c14886469.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时目标处理：确认有可用的主要怪兽区且手卡·墓地存在符合条件的怪兽；若满足则设置操作信息为特殊召唤。
function c14886469.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己场上有空闲的主要怪兽区可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且手卡·墓地存在至少1张满足筛选条件（等级3以下、恶魔族、调整、可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c14886469.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本连锁的操作信息：类别为特殊召唤，来源为手卡·墓地，数量为1，归属玩家为tp，区域为手卡+墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数：若仍有空位，则提示玩家选择1张符合条件的怪兽，从手卡·墓地以表侧表示特殊召唤到自己的场上。
function c14886469.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理阶段再次检查：若自己场上没有可用的主要怪兽区，则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示提示信息：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·墓地选择1张满足条件（等级3以下、恶魔族、调整、可特殊召唤且不受王家长眠之谷影响）的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c14886469.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己的场上（不无视召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
