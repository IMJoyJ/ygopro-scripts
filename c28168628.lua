--闘神の虚像
-- 效果：
-- 「征服斗魂」怪兽1只
-- 这张卡不能作为连接素材。这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己场上有「征服斗魂」怪兽存在，对方只能选择自己场上的攻击力最高的怪兽作为攻击对象。
-- ②：自己·对方的主要阶段，可以从以下效果选择1个发动。
-- ●从手卡把1只「征服斗魂」怪兽特殊召唤。
-- ●从自己墓地选1只「征服斗魂」怪兽加入手卡。
function c28168628.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用1只满足过滤条件的「征服斗魂」怪兽作为连接素材
	aux.AddLinkProcedure(c,c28168628.matfilter,1,1)
	-- 这张卡不能作为连接素材
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- 只要自己场上有「征服斗魂」怪兽存在，对方只能选择自己场上的攻击力最高的怪兽作为攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c28168628.atkcon)
	e1:SetValue(c28168628.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 自己·对方的主要阶段，可以从以下效果选择1个发动。●从手卡把1只「征服斗魂」怪兽特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28168628,0))  --"从手卡把1只「征服斗魂」怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,28168628)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCondition(c28168628.condition)
	e3:SetTarget(c28168628.sptg)
	e3:SetOperation(c28168628.spop)
	c:RegisterEffect(e3)
	-- 自己·对方的主要阶段，可以从以下效果选择1个发动。●从自己墓地选1只「征服斗魂」怪兽加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(28168628,1))  --"从自己墓地选1只「征服斗魂」怪兽加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,28168628)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e4:SetCondition(c28168628.condition)
	e4:SetTarget(c28168628.thtg)
	e4:SetOperation(c28168628.thop)
	c:RegisterEffect(e4)
end
-- 连接素材必须是「征服斗魂」属性的怪兽
function c28168628.matfilter(c,lc,sumtype,tp)
	return c:IsLinkSetCard(0x195)
end
-- 用于判断场上是否存在「征服斗魂」属性的表侧表示怪兽
function c28168628.atkfilter(c)
	return c:IsSetCard(0x195) and c:IsFaceup()
end
-- 判断场上是否存在「征服斗魂」属性的表侧表示怪兽
function c28168628.atkcon(e)
	-- 判断场上是否存在「征服斗魂」属性的表侧表示怪兽
	return Duel.IsExistingMatchingCard(c28168628.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 设定攻击时目标选择的规则，只有攻击力最高的怪兽能被选为攻击对象
function c28168628.atkval(e,c)
	-- 获取场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	return not tg:IsContains(c) or c:IsFacedown()
end
-- 判断当前是否处于主要阶段1或主要阶段2
function c28168628.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤手卡中可以特殊召唤的「征服斗魂」怪兽
function c28168628.spfilter(c,e,tp)
	return c:IsSetCard(0x195) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件
function c28168628.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡中是否存在满足条件的「征服斗魂」怪兽
		and Duel.IsExistingMatchingCard(c28168628.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作
function c28168628.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c28168628.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤墓地中可以加入手牌的「征服斗魂」怪兽
function c28168628.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x195) and c:IsAbleToHand()
end
-- 判断是否满足加入手牌的条件
function c28168628.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断墓地中是否存在满足条件的「征服斗魂」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28168628.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向对方提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要将1只怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 执行加入手牌的操作
function c28168628.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28168628.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
