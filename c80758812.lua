--デュアル・アブレーション
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，可以丢弃1张手卡，从以下效果选择1个发动。
-- ●从卡组把1只二重怪兽特殊召唤。这个效果特殊召唤的怪兽当作再1次召唤的状态使用。
-- ●自己场上1只二重怪兽解放，从手卡·卡组把1只战士族·炎属性怪兽特殊召唤。把再1次召唤状态的二重怪兽解放的场合，可以再选场上1张卡破坏。
function c80758812.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的主要阶段，可以丢弃1张手卡，从以下效果选择1个发动。●从卡组把1只二重怪兽特殊召唤。这个效果特殊召唤的怪兽当作再1次召唤的状态使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80758812,0))  --"特殊召唤二重怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,80758812)
	e2:SetCondition(c80758812.condition)
	e2:SetCost(c80758812.cost)
	e2:SetTarget(c80758812.sptg1)
	e2:SetOperation(c80758812.spop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(80758812,1))  --"解放并特殊召唤战士族·炎属性怪兽"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e3:SetTarget(c80758812.sptg2)
	e3:SetOperation(c80758812.spop2)
	c:RegisterEffect(e3)
end
c80758812.has_text_type=TYPE_DUAL
-- 定义效果发动的阶段条件函数
function c80758812.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己或对方的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义效果发动的Cost（丢弃手牌）函数
function c80758812.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 让玩家选择并丢弃1张手牌作为发动Cost
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：检查卡片是否为二重怪兽且可以被特殊召唤
function c80758812.spfilter1(c,e,tp)
	return c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果1（特殊召唤二重怪兽）的目标确认与操作信息设置函数
function c80758812.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查卡组中是否存在至少1只满足条件的二重怪兽
		and Duel.IsExistingMatchingCard(c80758812.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示此效果包含从卡组特殊召唤1只怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果1（特殊召唤二重怪兽）的效果处理函数
function c80758812.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否仍存在于场上，且自己场上是否有可用的怪兽区域空格，若不满足则不处理
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的二重怪兽
	local g=Duel.SelectMatchingCard(tp,c80758812.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选择怪兽，则将其以表侧表示特殊召唤到场上
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:EnableDualState()
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 过滤函数：检查卡片是否为二重怪兽，且解放该卡后自己场上是否有可用的怪兽区域空格
function c80758812.relfilter(c,tp)
	-- 检查卡片是否为二重怪兽，且解放该卡后自己场上是否有可用的怪兽区域空格
	return c:IsType(TYPE_DUAL) and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数：检查卡片是否为战士族·炎属性怪兽且可以被特殊召唤
function c80758812.spfilter2(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果2（解放二重特召战士族·炎属性）的目标确认与操作信息设置函数
function c80758812.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，检查自己场上是否存在至少1只可解放的满足条件的二重怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c80758812.relfilter,1,REASON_EFFECT,false,nil)
		-- 且检查手牌或卡组中是否存在至少1只满足条件的战士族·炎属性怪兽
		and Duel.IsExistingMatchingCard(c80758812.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示此效果包含从手牌或卡组特殊召唤1只怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果2（解放二重特召战士族·炎属性，并视情况破坏场上的卡）的效果处理函数
function c80758812.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择1只自己场上满足条件的二重怪兽作为解放对象
	local rg=Duel.SelectReleaseGroupEx(tp,c80758812.relfilter,1,1,REASON_EFFECT,false,nil,tp)
	if rg:GetCount()==0 then return end
	local relchk=rg:GetFirst():IsDualState()
	-- 解放选中的怪兽，若解放失败则不继续处理
	if Duel.Release(rg,REASON_EFFECT)==0 then return end
	-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或卡组选择1只满足条件的战士族·炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c80758812.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若成功选择怪兽，则将其特殊召唤到场上
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取场上所有的卡片
		local dg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		-- 若场上有卡存在，且被解放的二重怪兽处于再1次召唤状态，则询问玩家是否选择场上1张卡破坏
		if dg:GetCount()>0 and relchk and Duel.SelectYesNo(tp,aux.Stringid(80758812,2)) then  --"是否选场上1张卡破坏？"
			-- 中断当前效果处理，使后续的破坏处理不与特殊召唤同时进行
			Duel.BreakEffect()
			-- 设置选择卡片时的提示信息为“请选择要破坏的卡”
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=dg:Select(tp,1,1,nil)
			-- 给选中的卡片显示被选为对象的动画效果
			Duel.HintSelection(sg)
			-- 破坏选中的卡片
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
