--マジシャンズ・サルベーション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「永远之魂」在自己场上盖放。
-- ②：自己把「黑魔术师」或「黑魔术少女」召唤·特殊召唤的场合，以那之内的1只为对象才能发动。和那只怪兽卡名不同的1只「黑魔术师」或「黑魔术少女」从自己墓地特殊召唤。
function c95477924.initial_effect(c)
	-- 注册该卡片效果中记载了「黑魔术师」和「黑魔术少女」的卡片密码。
	aux.AddCodeList(c,46986414,38033121)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「永远之魂」在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,95477924+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c95477924.activate)
	c:RegisterEffect(e1)
	-- ②：自己把「黑魔术师」或「黑魔术少女」召唤·特殊召唤的场合，以那之内的1只为对象才能发动。和那只怪兽卡名不同的1只「黑魔术师」或「黑魔术少女」从自己墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95477924,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,95477925)
	e2:SetCondition(c95477924.spcon)
	e2:SetTarget(c95477924.sptg)
	e2:SetOperation(c95477924.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数：检索卡组中卡名为「永远之魂」且可以盖放的卡。
function c95477924.setfilter(c)
	return c:IsCode(48680970) and c:IsSSetable()
end
-- ①号效果（卡片发动时的效果处理）的执行函数：可以从卡组选择1张「永远之魂」在自己场上盖放。
function c95477924.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的「永远之魂」卡片组。
	local g=Duel.GetMatchingGroup(c95477924.setfilter,tp,LOCATION_DECK,0,nil)
	-- 如果卡组中存在「永远之魂」，则询问玩家是否选择发动该效果进行盖放。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(95477924,0)) then  --"是否从卡组把「永远之魂」盖放？"
		-- 提示玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「永远之魂」在自己场上盖放。
		Duel.SSet(tp,sg)
	end
end
-- 过滤函数：检查是否为自己召唤·特殊召唤的表侧表示的「黑魔术师」或「黑魔术少女」。
function c95477924.cfilter(c,tp)
	return c:IsFaceup() and c:IsCode(46986414,38033121) and c:IsSummonPlayer(tp)
end
-- ②号效果的发动条件：自己召唤·特殊召唤了「黑魔术师」或「黑魔术少女」。
function c95477924.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c95477924.cfilter,1,nil,tp)
end
-- 过滤函数：用于选择召唤·特殊召唤的怪兽作为对象，且墓地中存在与之卡名不同、可特殊召唤的「黑魔术师」或「黑魔术少女」。
function c95477924.tgfilter(c,e,tp,g)
	-- 检查该怪兽是否在本次召唤·特殊召唤的怪兽组中，且自己墓地中是否存在与之卡名不同的另一只可特殊召唤的「黑魔术师」或「黑魔术少女」。
	return g:IsContains(c) and Duel.IsExistingMatchingCard(c95477924.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
-- 过滤函数：检索自己墓地中与作为对象的怪兽卡名不同、且可以特殊召唤的「黑魔术师」或「黑魔术少女」。
function c95477924.spfilter(c,e,tp,code)
	return c:IsCode(46986414,38033121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code)
end
-- ②号效果的目标选择与检测函数：确认场上是否有符合条件的对象，并进行取对象操作，同时设置特殊召唤的操作信息。
function c95477924.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c95477924.cfilter,nil,tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c95477924.tgfilter(chkc,e,tp,g) end
	-- 效果发动时的检测：检查场上是否存在可以作为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c95477924.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp,g)
		-- 并且检查自己的怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	if g:GetCount()==1 then
		-- 如果本次召唤·特殊召唤的符合条件的怪兽只有1只，则直接将其设为效果的对象。
		Duel.SetTargetCard(g)
	else
		-- 提示玩家选择表侧表示的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家选择1只本次召唤·特殊召唤的怪兽作为效果的对象。
		Duel.SelectTarget(tp,c95477924.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp,g)
	end
	-- 设置效果处理的操作信息为：从自己墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②号效果的执行函数：将与对象怪兽卡名不同的1只「黑魔术师」或「黑魔术少女」从自己墓地特殊召唤。
function c95477924.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍在该效果的影响下、是否表侧表示存在，且自己场上仍有可用的怪兽区域。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local code=tc:GetCode()
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只与对象怪兽卡名不同的「黑魔术师」或「黑魔术少女」。
		local g=Duel.SelectMatchingCard(tp,c95477924.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,code)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
