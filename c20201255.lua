--再起する剣闘獣
-- 效果：
-- ①：从自己的手卡·墓地选相同种族的怪兽不在自己场上存在的1只「剑斗兽」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏。
function c20201255.initial_effect(c)
	-- 效果发动时点为自由时点，可以随时发动，效果分类为特殊召唤，效果目标为手卡或墓地的剑斗兽怪兽，效果处理为特殊召唤该怪兽并使其不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20201255.target)
	e1:SetOperation(c20201255.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的剑斗兽怪兽：必须是剑斗兽种族、可以被特殊召唤、且场上不存在同种族的表侧表示怪兽。
function c20201255.filter(c,e,tp)
	return c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确保场上不存在与该怪兽种族相同的表侧表示怪兽。
		and not Duel.IsExistingMatchingCard(c20201255.filter1,tp,LOCATION_MZONE,0,1,c,c:GetRace())
end
-- 辅助过滤函数，用于判断场上是否存在指定种族的表侧表示怪兽。
function c20201255.filter1(c,race)
	return c:IsFaceup() and c:IsRace(race)
end
-- 效果的处理目标函数，检查是否满足发动条件：场上存在空位且手卡或墓地存在符合条件的剑斗兽怪兽。
function c20201255.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡或墓地是否存在符合条件的剑斗兽怪兽。
		and Duel.IsExistingMatchingCard(c20201255.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，表示将要特殊召唤1只来自手卡或墓地的剑斗兽怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数，检查是否有空位，提示玩家选择要特殊召唤的怪兽，并执行特殊召唤操作。
function c20201255.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果场上没有空位则不执行效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地选择1只符合条件的剑斗兽怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20201255.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 如果成功选择并特殊召唤了怪兽，则给该怪兽添加不会被战斗破坏的效果。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 给特殊召唤的怪兽添加不会被战斗破坏的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
	end
end
