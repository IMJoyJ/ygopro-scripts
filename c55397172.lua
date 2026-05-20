--布都御魂之巳剣
-- 效果：
-- 「巳剑降临」降临
-- 这个卡名的①的效果在同一连锁上只能发动1次，②的效果1回合只能使用1次。
-- ①：对方把怪兽特殊召唤的场合，以「布都御魂之巳剑」以外的自己墓地1只爬虫类族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡被解放的场合才能发动。从卡组把「布都御魂之巳剑」以外的1张「巳剑」卡加入手卡。那之后，可以把这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，设置仪式召唤限制，注册①效果（对方特召时特召墓地爬虫类）和②效果（被解放时检索并可选特召自身）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：对方把怪兽特殊召唤的场合，以「布都御魂之巳剑」以外的自己墓地1只爬虫类族怪兽为对象才能发动。那只怪兽特殊召唤。这个卡名的①的效果在同一连锁上只能发动1次。
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
	-- ②：这张卡被解放的场合才能发动。从卡组把「布都御魂之巳剑」以外的1张「巳剑」卡加入手卡。那之后，可以把这张卡特殊召唤。这个卡名的②的效果1回合只能使用1次。
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
-- 检查特殊召唤成功的怪兽中是否存在对方玩家特殊召唤的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
-- 过滤条件：自己墓地中「布都御魂之巳剑」以外的、可以特殊召唤的爬虫类族怪兽
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsRace(RACE_REPTILE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与对象选择：检查是否满足发动条件，并选择墓地中1只符合条件的爬虫类族怪兽作为对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查当前玩家场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的怪兽可以作为效果对象
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：将选中的1张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理：将作为对象的墓地怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与此效果相关，且不受「王家之谷」等墓地干涉效果的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中「布都御魂之巳剑」以外的、可以加入手牌的「巳剑」卡片
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c3) and c:IsAbleToHand()
end
-- ②效果的发动准备：检查卡组中是否存在可检索的卡，并根据发动位置动态调整效果分类
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张满足检索条件的「巳剑」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	end
end
-- ②效果的处理：从卡组检索1张「巳剑」卡，之后可以把这张卡特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的「巳剑」卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片通过效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 检查当前玩家场上是否有可用的怪兽区域空格
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsRelateToEffect(e)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查自身是否不受「王家之谷」等墓地干涉效果的影响
			and aux.NecroValleyFilter()(c)
			-- 询问玩家是否选择发动后续的特殊召唤效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使前后的检索与特殊召唤处理视为不同时进行
			Duel.BreakEffect()
			-- 将这张卡以表侧表示特殊召唤到发动效果的玩家场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
