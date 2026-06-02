--天羽々斬之巳剣
-- 效果：
-- 「巳剑降临」降临
-- 这个卡名的①的效果在决斗中只能使用1次，③的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把1只「巳剑」怪兽特殊召唤。那之后，自己场上1只怪兽解放。
-- ②：对方场上的怪兽的攻击力下降800。
-- ③：这张卡被解放的场合才能发动。从卡组把「天羽羽斩之巳剑」以外的1张「巳剑」卡加入手卡。那之后，可以把这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- 将「巳剑降临」的卡片密码（81560239）加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,81560239)
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
-- 定义效果①的Cost：检查手卡中的这张卡是否未公开给对方
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤条件：属于「巳剑」系列且可以特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1c3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 定义效果①的Target：检查场上是否有怪兽空格，且卡组中是否存在可以特殊召唤的「巳剑」怪兽，以及自己是否可以解放怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「巳剑」怪兽，并确认自己能否解放场上的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.IsPlayerCanRelease(tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果①的Operation：从卡组特殊召唤1只「巳剑」怪兽，之后解放自己场上1只怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 在卡组中选择1只符合特殊召唤条件的「巳剑」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 如果选择成功且特殊召唤成功，则进行后续处理
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取自己场上可以解放的怪兽组
		local rg=Duel.GetReleaseGroup(tp,false,REASON_EFFECT)
		-- 向玩家发送选择解放的卡的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local sg=rg:Select(tp,1,1,nil)
		if sg and sg:GetCount()>0 then
			-- 使特殊召唤与解放的操作不视为同时处理
			Duel.BreakEffect()
			-- 将被选中的怪兽解放
			Duel.Release(sg,REASON_EFFECT)
		end
	end
end
-- 过滤条件：卡名非「天羽羽斩之巳剑」且能加入手牌的「巳剑」卡片
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c3) and c:IsAbleToHand()
end
-- 定义效果③的Target：检查卡组中是否存在可检索的「巳剑」卡片，并设置相应的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「巳剑」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果③的Operation：从卡组检索「天羽羽斩之巳剑」以外的1张「巳剑」卡加入手牌，之后可以把这张卡特殊召唤
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送选择加入手牌的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 在卡组中选择1张符合检索条件的「巳剑」卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示被检索的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 检查自己场上是否有空余的怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsRelateToChain()
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 确认这张卡是否不受王家长眠之谷的影响
			and aux.NecroValleyFilter()(c)
			-- 询问玩家是否决定将这张卡特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
			-- 使检索加入手牌与特殊召唤的操作不视为同时处理
			Duel.BreakEffect()
			-- 将这张卡在自己场上特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
