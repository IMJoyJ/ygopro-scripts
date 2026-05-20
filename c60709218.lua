--師弟の絆
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「黑魔术师」存在的场合才能发动。从自己的手卡·卡组·墓地选1只「黑魔术少女」特殊召唤。那之后，可以从卡组选「黑·魔·导」「黑·魔·导·爆·裂·破」「黑·爆·裂·破·魔·导」「黑·魔·导·连·弹」的其中1张在自己的魔法与陷阱区域盖放。
function c60709218.initial_effect(c)
	-- 在卡片中注册记载了「黑魔术师」和「黑魔术少女」的卡名。
	aux.AddCodeList(c,46986414,38033121)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「黑魔术师」存在的场合才能发动。从自己的手卡·卡组·墓地选1只「黑魔术少女」特殊召唤。那之后，可以从卡组选「黑·魔·导」「黑·魔·导·爆·裂·破」「黑·爆·裂·破·魔·导」「黑·魔·导·连·弹」的其中1张在自己的魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,60709218+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c60709218.condition)
	e1:SetTarget(c60709218.target)
	e1:SetOperation(c60709218.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「黑魔术师」。
function c60709218.cfilter(c)
	return c:IsCode(46986414) and c:IsFaceup()
end
-- 发动条件：检查自己场上是否存在表侧表示的「黑魔术师」。
function c60709218.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「黑魔术师」。
	return Duel.IsExistingMatchingCard(c60709218.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：可以特殊召唤的「黑魔术少女」。
function c60709218.spfilter(c,e,tp)
	return c:IsCode(38033121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的检测与处理，检查怪兽区域空位及是否存在可特殊召唤的「黑魔术少女」。
function c60709218.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的手卡、卡组、墓地中是否存在至少1只可以特殊召唤的「黑魔术少女」。
		and Duel.IsExistingMatchingCard(c60709218.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，准备从手卡、卡组、墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 过滤条件：卡组中可以盖放的「黑·魔·导」、「黑·魔·导·爆·裂·破」、「黑·爆·裂·破·魔·导」或「黑·魔·导·连·弹」。
function c60709218.setfilter(c)
	return c:IsCode(2314238,75190122,49702428,70168345) and c:IsSSetable()
end
-- 效果处理函数，执行特殊召唤「黑魔术少女」以及后续可选的卡组盖放魔陷处理。
function c60709218.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上没有可用的怪兽区域空格，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地中选择1只满足条件且不受「王家长眠之谷」影响的「黑魔术少女」。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c60709218.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local sc=g:GetFirst()
	-- 如果成功将选择的怪兽以表侧表示特殊召唤。
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取卡组中满足盖放条件的指定魔法·陷阱卡。
		local g2=Duel.GetMatchingGroup(c60709218.setfilter,tp,LOCATION_DECK,0,nil)
		-- 如果卡组中存在可盖放的卡，且玩家选择进行盖放。
		if g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(60709218,0)) then  --"是否把卡盖放？"
			-- 中断当前效果，使后续的盖放处理与特殊召唤不视为同时处理。
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local tc=g2:Select(tp,1,1,nil)
			-- 将选择的卡在自己的魔法与陷阱区域盖放。
			Duel.SSet(tp,tc)
		end
	end
end
