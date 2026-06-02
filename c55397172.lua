--布都御魂之巳剣
-- 效果：
-- 「巳剑降临」降临
-- 这个卡名的①的效果在同一连锁上只能发动1次，②的效果1回合只能使用1次。
-- ①：对方把怪兽特殊召唤的场合，以「布都御魂之巳剑」以外的自己墓地1只爬虫类族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡被解放的场合才能发动。从卡组把「布都御魂之巳剑」以外的1张「巳剑」卡加入手卡。那之后，可以把这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：添加记载的卡片，设定仪式召唤限制，注册怪兽特召时诱发的特殊召唤效果e1与解放时诱发的检索及特召效果e2
function s.initial_effect(c)
	-- 记录该卡记载了「巳剑降临」的卡名
	aux.AddCodeList(c,81560239)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果在同一连锁上只能发动1次。①：对方把怪兽特殊召唤的场合，以「布都御魂之巳剑」以外的自己墓地1只爬虫类族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被解放的场合才能发动。从卡组把「布都御魂之巳剑」以外的1张「巳剑」卡加入手卡。那之后，可以把这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 特殊召唤效果的Condition函数：检测特殊召唤的怪兽中是否有由对方特殊召唤的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
-- 特殊召唤怪兽的过滤函数：检测是否为「布都御魂之巳剑」以外的爬虫类族怪兽，且可以特殊召唤
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的Target函数：检测己方主要怪兽区域是否有空位，且墓地是否存在满足过滤条件的爬虫类族怪兽，并在发动时选择墓地中1只爬虫类族怪兽作为对象，设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 在检测阶段，检查己方主要怪兽区域是否还有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的墓地是否存在至少1张满足特殊召唤条件的「布都御魂之巳剑」以外的爬虫类族怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择作为特殊召唤效果对象的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择1只「布都御魂之巳剑」以外的爬虫类族怪兽作为连锁的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为将作为对象的墓地爬虫类族怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的Operation函数：将墓地中作为对象的爬虫类族怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为连锁对象的墓地爬虫类族怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果作为对象的怪兽与效果有关，且不受墓地针对卡的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将作为对象的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索卡片的过滤函数：检测是否为「布都御魂之巳剑」以外的「巳剑」卡片且可以加入手卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c3) and c:IsAbleToHand()
end
-- 检索及特召效果的Target函数：检测卡组中是否存在满足检索条件的卡片，并设置操作分类与操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在检测阶段，检查卡组中是否存在可以检索的「布都御魂之巳剑」以外的「巳剑」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	end
end
-- 检索及特召效果的Operation函数：从卡组检索1张「布都御魂之巳剑」以外的「巳剑」卡加入手卡，之后如果满足条件，可以选择将这张卡特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「布都御魂之巳剑」以外的「巳剑」卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 检查己方场上是否有可用于特殊召唤的空怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsRelateToEffect(e)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 并且检查该卡是否不受王谷影响
			and aux.NecroValleyFilter()(c)
			-- 并让玩家选择是否特殊召唤这张卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断效果处理，使得“特殊召唤”与前面的“检索”处理不同时
			Duel.BreakEffect()
			-- 将这张卡以表侧表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
