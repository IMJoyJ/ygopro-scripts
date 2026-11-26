--アルカナフォースEX－THE CHAOS RULER
-- 效果：
-- 卡名不同的「秘仪之力」怪兽×3
-- 把自己·对方场上的上记的卡送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。
-- ●表：把1只10星「秘仪之力」怪兽无视召唤条件从手卡·卡组特殊召唤。
-- ●里：把持有进行投掷硬币效果的1张卡从卡组加入手卡。
-- ②：只要「光之结界」在场地区域存在，对方不能把场上的怪兽的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡名记述、融合召唤及接触融合手续，以及①②效果。
function s.initial_effect(c)
	-- 记录这张卡的卡文本中记述了「光之结界」。
	aux.AddCodeList(c,73206827)
	-- 注册融合召唤所需素材为3只满足特定条件的怪兽。
	aux.AddFusionProcFunRep(c,s.ffilter,3,false)
	c:EnableReviveLimit()
	-- 注册接触融合手续：把己方·对方场上符合条件的素材送去墓地即可特殊召唤。
	aux.AddContactFusionProcedure(c,s.cffilter,LOCATION_MZONE,LOCATION_MZONE,Duel.SendtoGrave,REASON_COST)
	-- 卡名不同的「秘仪之力」怪兽×3 把自己·对方场上的上记的卡送去墓地的场合才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。●表：把1只10星「秘仪之力」怪兽无视召唤条件从手卡·卡组特殊召唤。●里：把持有进行投掷硬币效果的1张卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e1:SetCategory(CATEGORY_COIN+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.cointg)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
	-- ②：只要「光之结界」在场地区域存在，对方不能把场上的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.condition)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)
end
s.toss_coin=true
-- 融合素材过滤函数：要求是卡名互不相同的「秘仪之力」融合素材怪兽。
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x5) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
-- 接触融合素材过滤函数：可作为代价送墓，且为己方控制或对方场上的表侧表示怪兽。
function s.cffilter(c,fc)
	return c:IsAbleToGraveAsCost() and (c:IsControler(fc:GetControler()) or c:IsFaceup())
end
-- ①效果的目标处理函数：必发效果始终返回可发动，并设置投掷1次硬币的操作信息。
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：预计自己进行1次投掷硬币。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 过滤条件：检查卡片是否为可无视召唤条件特殊召唤的10星「秘仪之力」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 过滤条件：检查卡片是否为可加入手卡且具有投掷硬币效果的卡。
function s.thfilter(c)
	-- 判断卡片效果是否带有硬币标记且能够加入手卡。
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsAbleToHand()
end
-- ①效果的处理函数：判定硬币结果（受光之结界影响时可自选里表），并适用对应的特招或检索效果。
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=-1
	-- 检测【光之结界】(73206827)的效果是否生效中。若在生效中，自己的「秘仪之力」怪兽的召唤·反转召唤·特殊召唤时发动的效果不进行投掷硬币而选里表的其中1个适用。
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 检查「表」效果是否可适用：确认己方怪兽区有空位且手卡·卡组存在可特招的10星「秘仪之力」怪兽。
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
		-- 检查「里」效果是否可适用：确认卡组存在可加入手卡的带投掷硬币效果的卡。
		local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		if b1 and not b2 then
			-- 若仅「表」效果可适用，向对方提示己方选择了正面（表）效果。
			Duel.Hint(HINT_OPSELECTED,1-tp,60)
			res=1
		end
		if b2 and not b1 then
			-- 若仅「里」效果可适用，向对方提示己方选择了反面（里）效果。
			Duel.Hint(HINT_OPSELECTED,1-tp,61)
			res=0
		end
		if b1 and b2 then
			-- 若里表效果均可适用，让己方玩家从中选择适用正面（1）或反面（0）。
			res=aux.SelectFromOptions(tp,
				{b1,60,1},
				{b2,61,0})
		end
	-- 若「光之结界」未生效，则由己方投掷1次硬币决定正反面结果。
	else res=Duel.TossCoin(tp,1) end
	if res==1 then
		-- 适用「表」效果时检查己方怪兽区是否有空位，没有则结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 发送提示信息，引导玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己手卡·卡组选择1只10星「秘仪之力」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将所选怪兽无视召唤条件以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	elseif res==0 then
		-- 发送提示信息，引导玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己卡组选择1张持有投掷硬币效果的卡。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将所选卡以效果加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方确认。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的适用条件：检查双方场地区域是否存在生效的「光之结界」。
function s.condition(e)
	-- 判断当前场地区域是否存在卡号为「光之结界」的场地。
	return Duel.IsEnvironment(73206827,PLAYER_ALL,LOCATION_FZONE)
end
-- ②效果的封锁目标判定：限制对方不能发动位于场上且为怪兽卡的效果。
function s.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc&LOCATION_ONFIELD~=0 and re:IsActiveType(TYPE_MONSTER)
end
