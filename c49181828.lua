--スレット・アームド・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，以自己场上1只龙族怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
-- ②：丢弃1张手卡，以场上1只攻击力2400以下的怪兽为对象才能发动。那只怪兽破坏。把自己场上的怪兽破坏的场合，可以再把原本等级比那只怪兽高2星的1只龙族怪兽从手卡·卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（墓地起动破坏己方1只龙族怪兽并苏生自身）与②效果（丢1手卡破坏场上攻击力2400以下怪兽，破坏己方怪兽时可选特召高2星龙族）
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。 ①：这张卡在墓地存在的场合，以自己场上1只龙族怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
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
	-- ②：丢弃1张手卡，以场上1只攻击力2400以下的怪兽为对象才能发动。那只怪兽破坏。把自己场上的怪兽破坏的场合，可以再把原本等级比那只怪兽高2星的1只龙族怪兽从手卡·卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 筛选条件：检查卡片是否为表侧龙族怪兽，且该怪兽破坏离场后己方怪兽区有空位
function s.desfilter(c,tp)
	-- 确认怪兽为表侧表示，且该怪兽离场后己方主要怪兽区存在可用空位
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
		and c:IsRace(RACE_DRAGON)
end
-- ①效果的发动检测：确认墓地的这张卡可被特殊召唤，且己方场上存在可成为破坏对象的龙族怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.desfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认己方怪兽区存在满足条件的龙族怪兽可作为连锁对象
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向己方提示选择要破坏的对象龙族怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让己方从己方怪兽区选择1只满足条件的龙族怪兽作为对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 登记连锁的破坏操作信息，预计破坏所选己方龙族怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 登记连锁的特殊召唤操作信息，预计将墓地的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理流程：先以效果破坏对象龙族怪兽，若破坏成功且墓地的这张卡仍与连锁有联系且不受王家长眠之谷限制，则特殊召唤这张卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁所指定的对象龙族怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍在连锁中且为怪兽后将其以效果破坏，并判断是否破坏成功
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 确认墓地的这张卡仍与连锁有联系且不受到王家长眠之谷效果阻碍
		if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
			-- 将这张卡以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的发动代价检查与支付：确认己方手卡有可丢弃的卡并丢弃1张
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认己方手卡中存在至少1张可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 作为发动代价让己方选择并丢弃1张手卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选条件：检查场上怪兽是否为表侧表示且攻击力在2400以下
function s.desfilter2(c)
	return c:IsFaceup() and c:IsAttackBelow(2400)
end
-- ②效果的取对象合法性校验：检查已选对象是否位于怪兽区且攻击力在2400以下
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE)
		and s.desfilter2(chkc) end
	-- 发动条件检查：确认双方怪兽区存在至少1只表侧表示且攻击力2400以下的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向己方提示选择要破坏的对象怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让己方从双方怪兽区选择1只攻击力2400以下的表侧怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,s.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记连锁的破坏操作信息，预计破坏所选攻击力2400以下的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 筛选条件：检查卡片是否为龙族、原本等级等于被破坏怪兽原本等级加2且可特殊召唤
function s.spfilter(c,e,tp,tc)
	return c:IsRace(RACE_DRAGON) and c:GetOriginalLevel()==tc:GetOriginalLevel()+2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的处理流程：破坏对象怪兽；若破坏的是己方控制且原本等级大于0的怪兽，则在有空位时可选从手卡·卡组特召1只原本等级高2星的龙族怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁所指定的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain()
		and tc:IsType(TYPE_MONSTER)
		-- 以效果破坏对象怪兽并判断是否破坏成功
		and Duel.Destroy(tc,REASON_EFFECT)~=0
		and tc:IsPreviousControler(tp)
		and tc:GetOriginalLevel()>0
		-- 检查己方手卡或卡组是否存在原本等级比被破坏怪兽高2星的可特召龙族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,tc)
		-- 检查己方主要怪兽区是否存在可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问己方是否从手卡·卡组特殊召唤龙族怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 中断效果处理，使后续特殊召唤与前面的破坏视为不同时处理
		Duel.BreakEffect()
		-- 向己方提示选择要特殊召唤的龙族怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让己方从己方手卡·卡组选择1只符合条件的龙族怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,tc)
		if g:GetCount()>0 then
			-- 将所选龙族怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
