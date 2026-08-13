--ミニマリアン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从手卡把1张其他卡除外才能发动。这张卡特殊召唤。
-- ②：把自己场上1只4星以下的表侧表示怪兽除外才能发动。原本等级比除外的怪兽低1星或2星并原本的种族·属性相同的1只怪兽从卡组特殊召唤。
local s,id,o=GetID()
-- 创建并注册①和②两个效果：①为手牌起动效果，除外手牌其他卡特召自身；②为场上起动效果，除外场上1只4星以下表侧表示怪兽后从卡组特召符合条件的怪兽。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，从手卡把1张其他卡除外才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只4星以下的表侧表示怪兽除外才能发动。原本等级比除外的怪兽低1星或2星并原本的种族·属性相同的1只怪兽从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的代价筛选函数：判断手牌中的卡是否可以作为除外代价（调用时通过e:GetHandler()排除自身）。
function s.costfilter(c)
	return c:IsAbleToRemoveAsCost()
end
-- ①效果的代价支付函数：在确认阶段检查手牌是否存在可除外的其他卡；支付时选择1张手牌其他卡表侧表示除外。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：确认手牌中存在除自身以外、可以作为代价除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- ①效果发动时，向玩家显示“请选择要除外的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌选择1张满足costfilter且不是本卡的卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选择的卡表侧表示除外，作为①效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的发动条件（target）函数：确认自己场上有空余怪兽区，且此卡可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁将对此卡进行特殊召唤的操作信息（用于后续效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理函数：若此卡仍与效果关联，则将其特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示形式特殊召唤到自己场上（不检查苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的代价函数：将Label设为100作为已通过合法性预检的标记，实际除外操作在target阶段完成。
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- ②效果选择除外怪兽的筛选函数：怪兽需表侧表示、原本等级为1~4、可作为代价除外，且除外后自己仍有怪兽区空位，同时卡组中存在符合条件的可特召怪兽。
function s.costfilter2(c,e,tp)
	return c:IsFaceup() and c:GetOriginalLevel()>0 and c:IsLevelBelow(4)
		-- 确认除外该怪兽后自己场上仍有可用怪兽区，且该怪兽满足作为除外代价的条件。
		and Duel.GetMZoneCount(tp,c)>0 and c:IsAbleToRemoveAsCost()
		-- 确认卡组中存在以该怪兽为基准、满足等级低1~2星且同种族同属性并可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,c,e,tp)
end
-- 定义从卡组特殊召唤的怪兽条件：原本等级比除外怪兽低1星或2星，原本种族和属性相同，且可被特殊召唤。
function s.spfilter(c,tc,e,tp)
	return (c:GetOriginalLevel()==tc:GetOriginalLevel()-1
		or c:GetOriginalLevel()==tc:GetOriginalLevel()-2)
		and c:GetOriginalRace()==tc:GetOriginalRace()
		and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件（target）函数：在确认阶段检查标记和可除外的怪兽；实际发动时选择并除外1只怪兽、将其设为对象并设置特召操作信息。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 发动条件检查：自己场上是否存在满足costfilter2条件的表侧表示怪兽（除外的候选）。
		return Duel.IsExistingMatchingCard(s.costfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- ②效果发动时，向玩家显示“请选择要除外的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只满足costfilter2条件的怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,s.costfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选择的怪兽表侧表示除外，作为②效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 将除外的怪兽设置为当前连锁的对象，以便效果处理时获取其等级、种族、属性。
	Duel.SetTargetCard(g)
	-- 设置从卡组特殊召唤1只怪兽的操作信息，因特召对象不确定，targets设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理函数：确认场上有空位后，获取之前除外的怪兽，从卡组选择1只符合条件的怪兽特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上仍有可用怪兽区，否则直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取②效果发动时被除外并设为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足spfilter条件（等级低1~2星、同种族同属性、可特召）的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,tc,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
