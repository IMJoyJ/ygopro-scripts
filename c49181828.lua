--スレット・アームド・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，以自己场上1只龙族怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
-- ②：丢弃1张手卡，以场上1只攻击力2400以下的怪兽为对象才能发动。那只怪兽破坏。把自己场上的怪兽破坏的场合，可以再把原本等级比那只怪兽高2星的1只龙族怪兽从手卡·卡组特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应卡片效果①和②
function s.initial_effect(c)
	-- 效果①：这张卡在墓地存在的场合，以自己场上1只龙族怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 效果②：丢弃1张手卡，以场上1只攻击力2400以下的怪兽为对象才能发动。那只怪兽破坏。把自己场上的怪兽破坏的场合，可以再把原本等级比那只怪兽高2星的1只龙族怪兽从手卡·卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断目标怪兽是否为正面表示、有可用怪兽区且为龙族
function s.desfilter(c,tp)
	-- 判断目标怪兽是否为正面表示且有可用怪兽区
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
		and c:IsRace(RACE_DRAGON)
end
-- 效果①的发动时点处理函数，检查是否满足发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.desfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否存在满足条件的龙族怪兽作为对象
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上满足条件的1只怪兽作为对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：将要破坏的卡加入操作列表
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：将要特殊召唤的卡加入操作列表
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理函数，执行破坏和特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在连锁中且为怪兽卡，并进行破坏
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 判断自身是否仍在连锁中且未受王家长眠之谷影响
		if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
			-- 将自身特殊召唤到场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果②的费用支付函数，丢弃1张手卡
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：判断目标怪兽是否为正面表示且攻击力不超过2400
function s.desfilter2(c)
	return c:IsFaceup() and c:IsAttackBelow(2400)
end
-- 效果②的发动时点处理函数，检查是否满足发动条件
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE)
		and s.desfilter2(chkc) end
	-- 检查场上是否存在满足条件的攻击力2400以下的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上满足条件的1只怪兽作为对象
	local g=Duel.SelectTarget(tp,s.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将要破坏的卡加入操作列表
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数：判断目标卡是否为龙族且等级比目标怪兽高2星
function s.spfilter(c,e,tp,tc)
	return c:IsRace(RACE_DRAGON) and c:GetOriginalLevel()==tc:GetOriginalLevel()+2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的处理函数，执行破坏和特殊召唤操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain()
		and tc:IsType(TYPE_MONSTER)
		-- 判断目标怪兽是否被成功破坏
		and Duel.Destroy(tc,REASON_EFFECT)~=0
		and tc:IsPreviousControler(tp)
		and tc:GetOriginalLevel()>0
		-- 检查玩家手牌或卡组是否存在满足条件的龙族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,tc)
		-- 检查玩家场上是否有可用怪兽区
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否要特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的龙族怪兽作为特殊召唤对象
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,tc)
		if g:GetCount()>0 then
			-- 将选中的龙族怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
