--天羽々斬之巳剣
-- 效果：
-- 「巳剑降临」降临
-- 这个卡名的①的效果在决斗中只能使用1次，③的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1只「巳剑」怪兽特殊召唤。那之后，自己场上1只怪兽解放。
-- ②：对方场上的怪兽的攻击力下降800。
-- ③：这张卡被解放的场合才能发动。从卡组把「天羽羽斩之巳剑」以外的1张「巳剑」卡加入手卡。那之后，可以把这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果，包括①起动效果（特殊召唤并解放）、②场上的怪兽攻击力下降800、③解放时的检索效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1只「巳剑」怪兽特殊召唤。那之后，自己场上1只怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤并解放"
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
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 效果发动时，确认手卡的这张卡已公开
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤满足条件的「巳剑」怪兽（可特殊召唤）
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1c3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 判断是否满足①效果的发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组是否存在满足条件的「巳剑」怪兽且玩家可以解放怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.IsPlayerCanRelease(tp) end
	-- 设置连锁操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行①效果的处理：从卡组特殊召唤1只「巳剑」怪兽并解放1只己方怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「巳剑」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 执行特殊召唤操作
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取玩家可解放的卡片组
		local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT)
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local sg=rg:Select(tp,1,1,nil)
		if sg and sg:GetCount()>0 then
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 解放选择的怪兽
			Duel.Release(sg,REASON_EFFECT)
		end
	end
end
-- 过滤满足条件的「巳剑」卡（非本卡且可加入手牌）
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c3) and c:IsAbleToHand()
end
-- 判断是否满足③效果的发动条件并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组是否存在满足条件的「巳剑」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	end
	-- 设置连锁操作信息：将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行③效果的处理：从卡组检索1张「巳剑」卡加入手牌，并可选择是否特殊召唤本卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「巳剑」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 判断场上是否有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsRelateToChain()
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断本卡是否受王家长眠之谷影响
			and aux.NecroValleyFilter()(c)
			-- 询问玩家是否特殊召唤本卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将本卡特殊召唤到场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
