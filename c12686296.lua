--アルカナフォースEX－THE CHAOS RULER
-- 效果：
-- 卡名不同的「秘仪之力」怪兽×3
-- 把自己·对方场上的上记的卡送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤的场合发动。进行1次投掷硬币，那个里表的以下效果适用。
-- ●表：把1只10星「秘仪之力」怪兽无视召唤条件从手卡·卡组特殊召唤。
-- ●里：把持有进行投掷硬币效果的1张卡从卡组加入手卡。
-- ②：只要「光之结界」在场地区域存在，对方不能把场上的怪兽的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤条件、接触融合、特殊召唤条件和触发效果
function s.initial_effect(c)
	-- 记录该卡与「秘仪之力」卡组的关联
	aux.AddCodeList(c,73206827)
	-- 设置融合召唤需要3个满足条件的「秘仪之力」怪兽作为素材
	aux.AddFusionProcFunRep(c,s.ffilter,3,false)
	c:EnableReviveLimit()
	-- 设置接触融合的特殊召唤规则，需要将场上符合条件的怪兽送去墓地作为召唤代价
	aux.AddContactFusionProcedure(c,s.cffilter,LOCATION_MZONE,LOCATION_MZONE,Duel.SendtoGrave,REASON_COST)
	-- 设置该卡不能被无效且不能被复制的特殊召唤条件效果
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 设置该卡特殊召唤成功后触发的投掷硬币效果，包含硬币、检索、回手、特殊召唤和卡组破坏的分类
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e1:SetCategory(CATEGORY_COIN+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.cointg)
	e1:SetOperation(s.coinop)
	c:RegisterEffect(e1)
	-- 设置该卡在场地区域存在时，对方不能发动场上怪兽的效果
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
-- 融合素材过滤函数，筛选「秘仪之力」卡组且不重复融合代码的怪兽
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x5) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
-- 接触融合素材过滤函数，筛选可以送去墓地的怪兽
function s.cffilter(c,fc)
	return c:IsAbleToGraveAsCost() and (c:IsControler(fc:GetControler()) or c:IsFaceup())
end
-- 投掷硬币效果的处理函数，设置操作信息为投掷硬币
function s.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为投掷硬币
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 特殊召唤过滤函数，筛选10星「秘仪之力」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5) and c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 回手卡牌过滤函数，筛选具有投掷硬币效果的卡
function s.thfilter(c)
	-- 筛选具有投掷硬币效果的卡
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsAbleToHand()
end
-- 投掷硬币效果的处理函数，根据是否受效果影响决定选择或投掷硬币，并执行表/里效果
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=-1
	-- 判断玩家是否受「秘仪之力EX-混沌支配者」效果影响
	if Duel.IsPlayerAffectedByEffect(tp,73206827) then
		-- 判断是否满足特殊召唤10星「秘仪之力」怪兽的条件
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
		-- 判断是否满足从卡组加入手卡的条件
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
			-- 通过选项选择表/里效果
			res=aux.SelectFromOptions(tp,
				{b1,60,1},
				{b2,61,0})
		end
	-- 若未受效果影响，则进行一次投掷硬币
	else res=Duel.TossCoin(tp,1) end
	if res==1 then
		-- 判断是否有足够的召唤位置
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的10星「秘仪之力」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽无视召唤条件特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	elseif res==0 then
		-- 提示选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的具有投掷硬币效果的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方看到加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 判断「光之结界」是否在场地区域存在
function s.condition(e)
	-- 判断「光之结界」是否在场地区域存在
	return Duel.IsEnvironment(73206827,PLAYER_ALL,LOCATION_FZONE)
end
-- 限制对方发动场上怪兽效果的函数，判断是否为场上怪兽效果
function s.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc&LOCATION_ONFIELD~=0 and re:IsActiveType(TYPE_MONSTER)
end
