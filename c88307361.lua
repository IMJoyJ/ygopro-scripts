--超古深海王シーラカンス
-- 效果：
-- ①：1回合1次，丢弃1张手卡才能发动。从卡组把4星以下的鱼族怪兽尽可能特殊召唤。这个效果特殊召唤的怪兽不能攻击宣言，效果无效化。
-- ②：场上的这张卡为对象的魔法·陷阱·怪兽的效果发动时，把这张卡以外的自己场上1只鱼族怪兽解放才能发动。那个效果无效并破坏。
function c88307361.initial_effect(c)
	-- ①：1回合1次，丢弃1张手卡才能发动。从卡组把4星以下的鱼族怪兽尽可能特殊召唤。这个效果特殊召唤的怪兽不能攻击宣言，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88307361,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c88307361.sumcost)
	e1:SetTarget(c88307361.sumtg)
	e1:SetOperation(c88307361.sumop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为对象的魔法·陷阱·怪兽的效果发动时，把这张卡以外的自己场上1只鱼族怪兽解放才能发动。那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88307361,1))  --"效果无效并破坏"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c88307361.discon)
	e2:SetCost(c88307361.discost)
	e2:SetTarget(c88307361.distg)
	e2:SetOperation(c88307361.disop)
	c:RegisterEffect(e2)
end
-- 效果①的Cost（代价）处理函数：丢弃1张手卡
function c88307361.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：筛选卡组中等级4以下、可以特殊召唤的鱼族怪兽
function c88307361.filter(c,e,sp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果①的Target（目标）处理函数
function c88307361.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在至少1只满足过滤条件的鱼族怪兽
		and Duel.IsExistingMatchingCard(c88307361.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息：从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果①的Operation（效果处理）函数
function c88307361.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取卡组中所有满足过滤条件的鱼族怪兽
	local tg=Duel.GetMatchingGroup(c88307361.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=tg:Select(tp,ft,ft,nil)
	local c=e:GetHandler()
	local tc=g:GetFirst()
	while tc do
		-- 将选中的怪兽以表侧表示特殊召唤（单步处理）
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 不能攻击宣言
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		tc=g:GetNext()
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 效果②的Condition（发动条件）函数
function c88307361.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查对象卡片组是否包含这张卡，且该连锁的效果可以被无效
	return tg and tg:IsContains(c) and Duel.IsChainDisablable(ev)
end
-- 效果②的Cost（代价）处理函数
function c88307361.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外的可以解放的鱼族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,e:GetHandler(),RACE_FISH) end
	-- 玩家选择自己场上除这张卡以外的1只鱼族怪兽
	local sg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,e:GetHandler(),RACE_FISH)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(sg,REASON_COST)
end
-- 效果②的Target（目标）处理函数
function c88307361.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息：使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置连锁信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②的Operation（效果处理）函数
function c88307361.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该效果，并检查发动效果的卡是否仍存在于原区域
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动效果的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
