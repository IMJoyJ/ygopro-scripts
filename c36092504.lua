--ベイオネット・パニッシャー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的场上·墓地的「枪管」怪兽种类的以下效果适用。自己场上有攻击力3000以上的怪兽存在的场合，对方不能对应这张卡的发动把效果发动。
-- ●融合：选对方场上1只怪兽除外。
-- ●同调：从对方的额外卡组把里侧表示的卡随机3张除外。
-- ●超量：选对方场上1张魔法·陷阱卡除外。
-- ●连接：从对方墓地选最多3张卡除外。
function c36092504.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的场上·墓地的「枪管」怪兽种类的以下效果适用。自己场上有攻击力3000以上的怪兽存在的场合，对方不能对应这张卡的发动把效果发动。●融合：选对方场上1只怪兽除外。●同调：从对方的额外卡组把里侧表示的卡随机3张除外。●超量：选对方场上1张魔法·陷阱卡除外。●连接：从对方墓地选最多3张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,36092504+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c36092504.target)
	e1:SetOperation(c36092504.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：自己场上表侧表示或墓地存在且属于「枪管」系列的卡。
function c36092504.cfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x10f)
end
-- 筛选条件：里侧表示且在额外卡组的卡（用于同调分支随机除外）。
function c36092504.rmfilter1(c)
	return c:IsFacedown() and c:IsLocation(LOCATION_EXTRA)
end
-- 筛选条件：场上表侧表示的魔法·陷阱卡（用于超量分支除外）。
function c36092504.rmfilter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsOnField()
end
-- 筛选条件：自己场上表侧表示且攻击力3000以上的怪兽（用于触发“对方不能对应发动”的限制）。
function c36092504.lmfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(3000)
end
-- 发动时点检查合法性：根据自己场上·墓地的「枪管」怪兽种类，判断是否存在对应的可选除外对象（融合→对方场上怪兽、同调→对方额外里侧卡至少3张、超量→对方场上魔陷、连接→对方墓地有卡），满足任一即可发动。
function c36092504.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上·墓地的「枪管」怪兽集合。
	local g1=Duel.GetMatchingGroup(c36092504.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 获取对方场上、额外、墓地中可以被除外的卡集合（用于判断可选对象）。
	local g2=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,nil)
	if chk==0 then return (g1:IsExists(Card.IsType,1,nil,TYPE_FUSION) and g2:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE))
		or (g1:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) and g2:IsExists(c36092504.rmfilter1,3,nil))
		or (g1:IsExists(Card.IsType,1,nil,TYPE_XYZ) and g2:IsExists(c36092504.rmfilter2,1,nil))
		or (g1:IsExists(Card.IsType,1,nil,TYPE_LINK) and g2:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)) end
	-- 若自己场上有攻击力3000以上的表侧表示怪兽，且当前是魔法卡发动，则设置连锁限制。
	if Duel.IsExistingMatchingCard(c36092504.lmfilter,tp,LOCATION_MZONE,0,1,nil) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制函数，使对方不能连锁这张卡的发动。
		Duel.SetChainLimit(c36092504.chainlm)
	end
end
-- 连锁限制的具体判断：仅当尝试连锁的玩家是这张卡的发动者时才允许连锁（即对方不能连锁）。
function c36092504.chainlm(e,rp,tp)
	return tp==rp
end
-- 效果处理时，根据自己场上·墓地的「枪管」怪兽种类依次处理：融合→选对方场上1只怪兽除外；同调→随机选对方额外卡组里侧表示3张除外；超量→选对方场上1张魔法·陷阱卡除外；连接→选对方墓地最多3张卡除外；每处理完一个分支，若之前已除外过卡则中断效果，使各分支不同时处理。
function c36092504.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上·墓地的「枪管」怪兽集合（效果处理中再次确认）。
	local g1=Duel.GetMatchingGroup(c36092504.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 获取对方场上、额外、墓地中可以被除外且不受王家长眠之谷影响的卡集合（用于效果处理时选择对象）。
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,nil)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	local res=0
	if g1:IsExists(Card.IsType,1,nil,TYPE_FUSION) and g2:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
		-- 显示选择提示，提示文字为“请选择要除外的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=g2:FilterSelect(tp,Card.IsLocation,1,1,nil,LOCATION_MZONE)
		-- 为被选中的卡播放对象选中动画，并记录为对象。
		Duel.HintSelection(rg)
		-- 将选中的卡表侧表示除外，res记录实际除外的数量，用于判断是否需要错时点。
		res=Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
	-- 获取自己场上·墓地的「枪管」怪兽集合（效果处理中再次确认）。
	g1=Duel.GetMatchingGroup(c36092504.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 获取对方场上、额外、墓地中可以被除外且不受王家长眠之谷影响的卡集合（用于效果处理时选择对象）。
	g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,nil)
	if g1:IsExists(Card.IsType,1,nil,TYPE_SYNCHRO) and g2:IsExists(c36092504.rmfilter1,3,nil) then
		-- 如果此前已有卡被除外，则中断当前效果，使后续分支的处理视为不同时，避免错过时点。
		if res~=0 then Duel.BreakEffect() end
		-- 洗切对方的额外卡组（随机除外前先洗牌，确保随机性）。
		Duel.ShuffleExtra(1-tp)
		local rg=g2:Filter(c36092504.rmfilter1,nil):RandomSelect(tp,3)
		-- 将随机选中的3张里侧额外卡组卡表侧表示除外，res记录除外的数量。
		res=Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
	-- 获取自己场上·墓地的「枪管」怪兽集合（效果处理中再次确认）。
	g1=Duel.GetMatchingGroup(c36092504.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 获取对方场上、额外、墓地中可以被除外且不受王家长眠之谷影响的卡集合（用于效果处理时选择对象）。
	g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,nil)
	if g1:IsExists(Card.IsType,1,nil,TYPE_XYZ) and g2:IsExists(c36092504.rmfilter2,1,nil) then
		-- 如果此前已有卡被除外，则中断当前效果，使后续分支的处理视为不同时，避免错过时点。
		if res~=0 then Duel.BreakEffect() end
		-- 显示选择提示，提示文字为“请选择要除外的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=g2:FilterSelect(tp,c36092504.rmfilter2,1,1,nil)
		-- 为被选中的卡播放对象选中动画，并记录为对象。
		Duel.HintSelection(rg)
		-- 将选中的对方场上1张魔法·陷阱卡表侧表示除外，res记录除外的数量。
		res=Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
	-- 获取自己场上·墓地的「枪管」怪兽集合（效果处理中再次确认）。
	g1=Duel.GetMatchingGroup(c36092504.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 获取对方场上、额外、墓地中可以被除外且不受王家长眠之谷影响的卡集合（用于效果处理时选择对象）。
	g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_ONFIELD+LOCATION_EXTRA+LOCATION_GRAVE,nil)
	if g1:IsExists(Card.IsType,1,nil,TYPE_LINK) and g2:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 如果此前已有卡被除外，则中断当前效果，使后续分支的处理视为不同时，避免错过时点。
		if res~=0 then Duel.BreakEffect() end
		-- 显示选择提示，提示文字为“请选择要除外的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=g2:FilterSelect(tp,Card.IsLocation,1,3,nil,LOCATION_GRAVE)
		-- 为被选中的卡播放对象选中动画，并记录为对象。
		Duel.HintSelection(rg)
		-- 将选中的对方墓地最多3张卡表侧表示除外（此分支为最后处理，无需再记录res）。
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
