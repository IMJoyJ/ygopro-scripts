--アルカナフォースEX－THE CHAOS RULER
-- 效果：
-- 卡名不同的「秘仪之力」怪兽×3
-- 把自己·对方场上的上记的卡送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。
-- ●表：把1只10星「秘仪之力」怪兽无视召唤条件从手卡·卡组特殊召唤。
-- ●里：把持有进行投掷硬币效果的1张卡从卡组加入手卡。
-- ②：只要「光之结界」在场地区域存在，对方不能把场上的怪兽的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 为卡片注册「秘仪之力」系列代码列表
	aux.AddCodeList(c,73206827)
	-- 添加接触融合程序，需要3个「秘仪之力」融合素材
	aux.AddFusionProcFunRep(c,s.ffilter,3,false)
	c:EnableReviveLimit()
	-- 添加接触融合的代价条件，需将场上怪兽送去墓地
	aux.AddContactFusionProcedure(c,s.cffilter,LOCATION_MZONE,LOCATION_MZONE,Duel.SendtoGrave,REASON_COST)
	-- 特殊召唤条件：必须通过接触融合特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 效果①：特殊召唤成功时进行硬币投掷，选择表或里效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.cointg)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
	-- 效果②：只要「光之结界」在场地区域存在，对方不能发动怪兽效果
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
-- 融合素材过滤函数，用于筛选「秘仪之力」融合素材
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x5) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
-- 接触融合代价过滤函数，用于判断场上怪兽是否可作为代价
function s.cffilter(c,fc)
	return c:IsAbleToGraveAsCost() and (c:IsControler(fc:GetControler()) or c:IsFaceup())
end
-- 硬币效果目标设定函数
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，提示进行1次硬币投掷
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 特殊召唤过滤函数，用于筛选10星「秘仪之力」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 检索卡组加入手卡过滤函数，用于筛选具有硬币效果的卡
function s.thfilter(c)
	-- 判断卡是否具有硬币效果且可加入手卡
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsAbleToHand()
end
-- 硬币效果处理函数
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=-1
	-- 判断玩家是否受到「秘仪之力EX-混沌支配者」效果影响
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 判断是否可以特殊召唤10星「秘仪之力」怪兽
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
		-- 判断是否可以从卡组检索具有硬币效果的卡
		local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		if b1 and not b2 then
			-- 提示对方选择了表效果
			Duel.Hint(HINT_OPSELECTED,1-tp,60)
			res=1
		end
		if b2 and not b1 then
			-- 提示对方选择了里效果
			Duel.Hint(HINT_OPSELECTED,1-tp,61)
			res=0
		end
		if b1 and b2 then
			-- 让玩家选择表或里效果
			res=aux.SelectFromOptions(tp,
				{b1,60,1},
				{b2,61,0})
		end
	-- 进行1次硬币投掷
	else res=Duel.TossCoin(tp,1) end
	if res==1 then
		-- 判断是否有足够怪兽区域进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示选择特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择满足条件的10星「秘仪之力」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽无视召唤条件特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	elseif res==0 then
		-- 提示选择加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		-- 选择满足条件的具有硬币效果的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看选中的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 判断「光之结界」是否在场地区域存在
function s.condition(e)
	-- 判断「光之结界」是否在场地区域存在
	return Duel.IsEnvironment(73206827,PLAYER_ALL,LOCATION_FZONE)
end
-- 限制对方发动怪兽效果的函数
function s.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc&LOCATION_ONFIELD~=0 and re:IsActiveType(TYPE_MONSTER)
end
