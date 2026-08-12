--ディプシーデビル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：丢弃1张手卡，宣言1个水属性以外的属性才能发动。这张卡从手卡往自己或对方的场上特殊召唤。那之后，这张卡的属性直到回合结束时变成宣言的属性。这个效果在对方场上特殊召唤的场合，可以再把原本属性和宣言的属性不同的1只4星以下的恶魔族怪兽从自己的手卡·墓地往自己场上特殊召唤。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册该卡的效果：1回合1次，在手卡发动的起动效果，包含特殊召唤和从墓地特殊召唤的效果分类。
function s.initial_effect(c)
	-- ①：丢弃1张手卡，宣言1个水属性以外的属性才能发动。这张卡从手卡往自己或对方的场上特殊召唤。那之后，这张卡的属性直到回合结束时变成宣言的属性。这个效果在对方场上特殊召唤的场合，可以再把原本属性和宣言的属性不同的1只4星以下的恶魔族怪兽从自己的手卡·墓地往自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的代价：丢弃1张手卡。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的可丢弃卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡作为发动代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 效果发动的目标：检查自身是否能特殊召唤到自己或对方场上，并让玩家宣言属性。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空位且这张卡能否在自己场上特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 或者检查对方场上是否有空位且这张卡能否在对方场上特殊召唤。
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) end
	-- 提示玩家选择要宣言的属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言1个水属性以外的属性。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~ATTRIBUTE_WATER)
	e:SetLabel(att)
	-- 设置特殊召唤自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤条件：原本属性与宣言属性不同的4星以下的恶魔族怪兽。
function s.spfilter(c,e,tp,att)
	return c:IsRace(RACE_FIEND) and c:IsLevelBelow(4)
		and c:GetOriginalAttribute()~=att
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：将这张卡特殊召唤到自己或对方场上，属性变为宣言属性。若在对方场上特召，可再从手卡·墓地特召1只满足条件的恶魔族怪兽。最后适用额外卡组特召限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 检查当前自己场上是否有空位且这张卡能否在自己场上特殊召唤。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 检查当前对方场上是否有空位且这张卡能否在对方场上特殊召唤。
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
	local op=-1
	if b1 and b2 then
		-- 让玩家选择在自己场上特殊召唤还是在对方场上特殊召唤。
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"在自己场上特殊召唤/在对方场上特殊召唤"
	elseif b1 then
		-- 只能选择在自己场上特殊召唤。
		op=Duel.SelectOption(tp,aux.Stringid(id,1))  --"在自己场上特殊召唤"
	elseif b2 then
		-- 只能选择在对方场上特殊召唤。
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1  --"在对方场上特殊召唤"
	else
		-- 若双方场上都无法特殊召唤，则根据规则将该卡送去墓地。
		Duel.SendtoGrave(c,REASON_RULE)
	end
	local sp=nil
	if op==0 then
		-- 准备将这张卡在自己场上表侧表示特殊召唤。
		sp=Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
	elseif op==1 then
		-- 准备将这张卡在对方场上表侧表示特殊召唤。
		sp=Duel.SpecialSummonStep(c,0,tp,1-tp,false,false,POS_FACEUP)
	end
	local att=e:GetLabel()
	if sp~=nil then
		-- 那之后，这张卡的属性直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(att)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的处理。
	if op>=0 then Duel.SpecialSummonComplete() end
	-- 检查是否在对方场上特殊召唤，且自己场上有空余的怪兽区域。
	if op==1 and Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查自己的手卡或墓地中是否存在满足条件的恶魔族怪兽（受王家长眠之谷影响）。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,att)
		-- 询问玩家是否选择进行追加的特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否再把恶魔族怪兽特殊召唤？"
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或墓地选择1只满足条件的恶魔族怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,att)
		if g:GetCount()>0 then
			-- 中断当前效果，使后续的特殊召唤与前面的特殊召唤不视为同时处理。
			Duel.BreakEffect()
			-- 将选中的恶魔族怪兽在自己场上表侧表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该回合内的额外卡组特殊召唤限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤恶魔族以外的怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_FIEND) and c:IsLocation(LOCATION_EXTRA)
end
