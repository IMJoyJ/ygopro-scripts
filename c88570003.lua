--王のしもべ－ブラック・マジシャン
-- 效果：
-- 这个卡名的②③的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡的卡名只要在场上·墓地存在当作「黑魔术师」使用。
-- ②：这张卡在手卡存在的场合，把手卡1张魔法卡给对方观看才能发动。这张卡特殊召唤。那之后，可以从卡组把有「黑魔术师」的卡名记述的1张魔法·陷阱卡在自己场上盖放。
-- ③：自己·对方回合，从手卡丢弃1张魔法卡才能发动。对方场上的魔法·陷阱卡全部破坏。
local s,id,o=GetID()
-- 注册卡片效果：包含①卡名在场上·墓地当作「黑魔术师」使用的永续效果；②在手牌存在时通过向对方展示1张魔法卡将此卡特殊召唤，并可从卡组盖放1张记述有「黑魔术师」卡名的魔陷的起动效果；③在场上存在时通过丢弃1张魔法卡，将对方场上所有魔陷破坏的诱发即时效果。
function s.initial_effect(c)
	-- 注册卡名变更效果：此卡在场上·墓地存在时，卡名当作「黑魔术师」使用。
	aux.EnableChangeCode(c,46986414,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡在手卡存在的场合，把手卡1张魔法卡给对方观看才能发动。这张卡特殊召唤。那之后，可以从卡组把有「黑魔术师」的卡名记述 of 1张魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ③：自己·对方回合，从手卡丢弃1张魔法卡才能发动。对方场上的魔法·陷阱卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手牌中未处于公开状态的魔法卡（用于展示代价）。
function s.cfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- 效果②发动的代价：把手卡1张魔法卡给对方观看。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果②发动前，检查自己手牌中是否存在至少1张未公开的可提供展示的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择向对方展示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手牌中选择1张未公开的魔法卡作为展示目标。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方玩家展示选中的魔法卡进行确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示完毕后将自己手牌重新洗牌。
	Duel.ShuffleHand(tp)
end
-- 效果②的发动检测与效果分类注册，确认是否能够特殊召唤此卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果②发动前，检查自己场上是否有可用于特殊召唤怪兽的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息：包含特殊召唤此怪兽的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤条件：卡组中记述有「黑魔术师」卡名，且能盖放到自己场上的魔法·陷阱卡。
function s.setfilter(c)
	-- 检查该卡是否在效果文本中记载了「黑魔术师」的卡号，且属于魔法·陷阱卡，并且能够被盖放。
	return aux.IsCodeListed(c,46986414) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的效果处理：将此卡特殊召唤，随后玩家可以选择将卡组中记述有「黑魔术师」的1张魔法·陷阱卡在自己场上盖放。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与连锁相关，且成功将此卡在自己场上特殊召唤。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 且检查卡组中是否存在满足盖放条件的魔陷，并询问玩家是否进行盖放操作。
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否盖放？"
		-- 提示玩家选择从卡组中进行盖放的魔陷卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 中断当前效果处理，使得之后的盖放魔陷操作与特殊召唤的处理不同时发生。
		Duel.BreakEffect()
		-- 从卡组中选择1张满足条件的记述有「黑魔术师」的魔法·陷阱卡。
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的魔法·陷阱卡盖放到自己场上。
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 过滤条件：手牌中可以作为代价被丢弃的魔法卡。
function s.costfilter(c,tp)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果③发动的代价：从手卡丢弃1张魔法卡。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果③发动前，检查自己手牌中是否存在至少1张魔法卡可用于丢弃代价。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 获取自己手牌中所有可被丢弃的魔法卡。
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND,0,nil,tp)
	-- 提示玩家选择要作为代价丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选中的魔法卡以丢弃的形式送去墓地，作为效果发动的代价。
	Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：对方场上的魔法·陷阱卡。
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果③的发动检测与效果分类注册，表明包含破坏对方场上所有魔陷的效果。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果③发动前，检查对方场上是否存在至少1张魔法·陷阱卡可作为破坏对象。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有的魔法·陷阱卡片组。
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁信息：包含破坏对方场上所有魔陷的效果分类及数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果③的效果处理：将对方场上的魔法·陷阱卡全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的魔法·陷阱卡片组。
	local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 将获取的对方场上所有的魔法·陷阱卡破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end
