--天羽々斬之巳剣
-- 效果：
-- 「巳剑降临」降临
-- 这个卡名的①的效果在决斗中只能使用1次，③的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1只「巳剑」怪兽特殊召唤。那之后，自己场上1只怪兽解放。
-- ②：对方场上的怪兽的攻击力下降800。
-- ③：这张卡被解放的场合才能发动。从卡组把「天羽羽斩之巳剑」以外的1张「巳剑」卡加入手卡。那之后，可以把这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1只「巳剑」怪兽特殊召唤。那之后，自己场上1只怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方场上的怪兽的攻击力下降800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-800)
	c:RegisterEffect(e2)
	-- ③：这张卡被解放的场合才能发动。从卡组把「天羽羽斩之巳剑」以外的1张「巳剑」卡加入手卡。那之后，可以把这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- ①效果的费用处理函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- ①效果的特殊召唤过滤函数
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1c3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- ①效果的发动目标函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果发动条件：场上存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否满足①效果发动条件：卡组存在「巳剑」怪兽且自己能解放怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.IsPlayerCanRelease(tp) end
	-- 设置①效果发动时的操作信息：特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的发动处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组选择1只「巳剑」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若成功特殊召唤，则继续处理解放怪兽
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取玩家可解放的怪兽组
		local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT)
		-- 提示玩家选择要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sg=rg:Select(tp,1,1,nil)
		if sg and sg:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 解放选定的怪兽
			Duel.Release(sg,REASON_EFFECT)
		end
	end
end
-- ③效果的检索过滤函数
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c3) and c:IsAbleToHand()
end
-- ③效果的发动目标函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足③效果发动条件：卡组存在「巳剑」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	end
	-- 设置③效果发动时的操作信息：加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果的发动处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组选择1张「巳剑」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查是否满足③效果后续特殊召唤条件：场上存在空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsRelateToChain()
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查是否满足③效果后续特殊召唤条件：不受王家长眠之谷影响
			and aux.NecroValleyFilter()(c)
			-- 询问玩家是否要特殊召唤此卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将此卡特殊召唤到场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
