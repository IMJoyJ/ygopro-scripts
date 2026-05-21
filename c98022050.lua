--珠玉獣－アルゴザウルス
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。「珠玉兽-运算主龙」以外的自己的手卡·场上（表侧表示）1只恐龙族怪兽破坏。那之后，原本等级和那只破坏的怪兽相同的1只爬虫类族·海龙族·鸟兽族怪兽或者1张「进化药」魔法卡从卡组加入手卡。
function c98022050.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。「珠玉兽-运算主龙」以外的自己的手卡·场上（表侧表示）1只恐龙族怪兽破坏。那之后，原本等级和那只破坏的怪兽相同的1只爬虫类族·海龙族·鸟兽族怪兽或者1张「进化药」魔法卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(98022050,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,98022050)
	e1:SetTarget(c98022050.destg)
	e1:SetOperation(c98022050.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤满足破坏条件的卡：自身以外的、手卡或场上表侧表示的恐龙族怪兽，且卡组中存在可检索的对应卡
function c98022050.desfilter(c,tp,solve)
	return c:IsRace(RACE_DINOSAUR) and not c:IsCode(98022050) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
		-- 检查卡组中是否存在与该怪兽原本等级相同的可检索卡（若在效果处理中则跳过此检查）
		and (solve or Duel.IsExistingMatchingCard(c98022050.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetOriginalLevel()))
end
-- 过滤满足检索条件的卡：与被破坏怪兽原本等级相同的爬虫类/海龙/鸟兽族怪兽，或者「进化药」魔法卡
function c98022050.thfilter(c,lv)
	return ((c:GetOriginalLevel()==lv and c:IsRace(RACE_REPTILE+RACE_SEASERPENT+RACE_WINDBEAST))
		or (c:IsSetCard(0x10e) and c:IsType(TYPE_SPELL))) and c:IsAbleToHand()
end
-- 效果发动的目标过滤与操作信息设置
function c98022050.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可破坏且能完成后续检索的恐龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98022050.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	-- 获取手卡及场上所有满足破坏条件的怪兽组
	local g=Duel.GetMatchingGroup(c98022050.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,tp)
	-- 设置破坏的操作信息，包含可能被破坏的卡片组
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置检索卡组卡片加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行函数：选择并破坏1只恐龙族怪兽，然后从卡组检索对应的怪兽或「进化药」魔法卡
function c98022050.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1张满足破坏且能完成后续检索条件的卡
	local g=Duel.SelectMatchingCard(tp,c98022050.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	if g:GetCount()==0 then
		-- 提示玩家选择要破坏的卡（备用选择提示）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 若前一步未选到卡，则允许无视后续检索条件直接选择可破坏的卡（处理solve为true的情况）
		g=Duel.SelectMatchingCard(tp,c98022050.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp,true)
	end
	local tc=g:GetFirst()
	-- 成功破坏选中的怪兽
	if tc and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local lv=tc:GetOriginalLevel()
		-- 检查卡组中是否存在与被破坏怪兽原本等级相同的可检索卡
		if Duel.IsExistingMatchingCard(c98022050.thfilter,tp,LOCATION_DECK,0,1,nil,lv) then
			-- 中断当前效果，使后续的检索处理与破坏处理不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从卡组选择1张满足检索条件的卡
			local tg=Duel.SelectMatchingCard(tp,c98022050.thfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
			-- 将选择的卡加入手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,tg)
		end
	end
end
