--スレット・アームド・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的场合，以自己场上1只龙族怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
-- ②：丢弃1张手卡，以场上1只攻击力2400以下的怪兽为对象才能发动。那只怪兽破坏。把自己场上的怪兽破坏的场合，可以再把原本等级比那只怪兽高2星的1只龙族怪兽从手卡·卡组特殊召唤。
local s,id,o=GetID()
-- 注册①和②两个起动效果：①在墓地可自跳并破坏自己1只龙族怪兽；②丢1手卡破坏攻击力2400以下怪兽，若破坏自己怪兽可再特召高2星龙族。均设1回合1次限制。
function s.initial_effect(c)
	-- ①：这张卡在墓地存在的场合，以自己场上1只龙族怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
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
-- 定义①效果选择对象的过滤条件：对象必须是表侧表示，且该对象从自己场上被破坏后自己场上仍有可用怪兽区来特殊召唤这张卡，且必须是龙族怪兽。
function s.desfilter(c,tp)
	-- 检查对象是否表侧表示，并判断把该对象从场上移走后自己是否能空出怪兽区用于特殊召唤此卡。
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
		and c:IsRace(RACE_DRAGON)
end
-- ①效果的发动条件和选择对象部分的处理：获取效果持有者；当为连锁对象检查时验证对象是否在主要怪兽区、控制者为自己且满足破坏空位条件；在发动时检查此卡能否被特殊召唤以及场上是否存在合法对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.desfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在至少1只满足条件（表侧、龙族、破坏后有空位）的怪兽可作为对象。
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向发动玩家发送“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1只满足条件的龙族怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：本次效果将破坏1张对象卡（分类为破坏）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次效果将特殊召唤这张卡（分类为特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：取得对象卡，若对象仍与连锁相关且为怪兽则将其破坏；若破坏成功且此卡仍与连锁相关并适用王家长眠之谷判定，则将此卡表侧攻击表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡与当前连锁仍有联系且是怪兽，然后将其以效果原因破坏，并确认破坏成功（返回破坏数量不为0）。
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查此卡（墓地中的威胁武装龙）仍与当前连锁有关联，且不受王家长眠之谷的效果影响。
		if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
			-- 将这张卡以正面表示特殊召唤到其控制者的场上。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果发动代价的处理：检查手牌中有无可丢弃的卡，若有则选择1张手牌丢弃作为发动代价。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价的合法性检查：手牌中是否存在至少1张可以被丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌选择1张卡丢弃，作为②效果发动的COST（代价+丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义②效果选择破坏对象的过滤条件：对象必须是表侧表示且攻击力在2400以下。
function s.desfilter2(c)
	return c:IsFaceup() and c:IsAttackBelow(2400)
end
-- ②效果的对象合法性检查：若为连锁对象检查，对象须位于怪兽区且为表侧表示、攻击力2400以下。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE)
		and s.desfilter2(chkc) end
	-- 检查场上是否存在至少1只表侧且攻击力2400以下的怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动玩家发送“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1只满足条件的表侧攻击力2400以下的怪兽作为效果对象，并登记为当前连锁对象。
	local g=Duel.SelectTarget(tp,s.desfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果将破坏1张对象卡（分类为破坏）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义追加特殊召唤的过滤条件：龙族怪兽，原本等级等于被破坏怪兽的原本等级+2，并且能被当前效果特殊召唤。
function s.spfilter(c,e,tp,tc)
	return c:IsRace(RACE_DRAGON) and c:GetOriginalLevel()==tc:GetOriginalLevel()+2 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果处理：取得对象怪兽；若对象仍与连锁相关且为怪兽，则将其以效果破坏；若破坏成功且被破坏怪兽上一控制者是发动玩家、原等级大于0，并且手卡·卡组存在符合条件的龙族且自己怪兽区有空位，则询问玩家是否追加特殊召唤；选择是则中断当前效果后从手卡·卡组选1只符合条件的龙族怪兽特殊召唤。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain()
		and tc:IsType(TYPE_MONSTER)
		-- 以效果原因破坏该对象怪兽，并确认破坏成功。
		and Duel.Destroy(tc,REASON_EFFECT)~=0
		and tc:IsPreviousControler(tp)
		and tc:GetOriginalLevel()>0
		-- 检查手卡·卡组中是否存在满足特殊召唤条件的龙族怪兽（原等级比被破坏怪兽高2星）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,tc)
		-- 检查自己场上是否有可用的怪兽区域用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否要发动追加特殊召唤（选择是/否）。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使之后的特殊召唤视为不同时处理，造成错时点。
		Duel.BreakEffect()
		-- 发送“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组中选择1只符合条件的龙族怪兽（原等级为被破坏怪兽原等级+2）。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,tc)
		if g:GetCount()>0 then
			-- 将选择的龙族怪兽以表侧攻击表示特殊召唤到自己的场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
