--ダイヤモンドダストン
-- 效果：
-- ①：场上的卡被战斗·效果破坏时才能发动。从卡组选那些破坏的卡数量的「尘妖」怪兽在自己·对方场上特殊召唤。
-- ②：这张卡在墓地存在的场合只有1次，把自己墓地1只「尘妖」怪兽除外才能发动。这张卡变成通常怪兽（恶魔族·暗·1星·攻0/守1000）在对方的怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不能解放，也不能作为融合·同调·超量召唤的素材。
function c96857854.initial_effect(c)
	-- ①：场上的卡被战斗·效果破坏时才能发动。从卡组选那些破坏的卡数量的「尘妖」怪兽在自己·对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c96857854.condition)
	e1:SetTarget(c96857854.target)
	e1:SetOperation(c96857854.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合只有1次，把自己墓地1只「尘妖」怪兽除外才能发动。这张卡变成通常怪兽（恶魔族·暗·1星·攻0/守1000）在对方的怪兽区域守备表示特殊召唤（不当作陷阱卡使用）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96857854,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCost(c96857854.spcost)
	e2:SetTarget(c96857854.sptg)
	e2:SetOperation(c96857854.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上的卡因战斗或效果被破坏
function c96857854.cfilter(c)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 发动条件：检查被破坏的卡中是否存在满足过滤条件的卡
function c96857854.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c96857854.cfilter,1,nil)
end
-- 过滤条件：卡组或手牌中可以特殊召唤到自己或对方场上的「尘妖」怪兽
function c96857854.filter(c,e,tp)
	return c:IsSetCard(0x80) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- 效果1的发动准备（Target）：检查场地空格、精灵龙限制，并确认卡组或手牌中存在足够数量的可特召「尘妖」怪兽
function c96857854.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:GetCount()
	-- 计算自己与对方场上可用怪兽区域的总和
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)+Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return (not Duel.IsPlayerAffectedByEffect(tp,59822133) or ct==1) and ft>=ct
		-- 检查卡组或手牌中是否存在至少被破坏卡片数量的满足过滤条件的「尘妖」怪兽
		and Duel.IsExistingMatchingCard(c96857854.filter,tp,LOCATION_DECK+LOCATION_HAND,0,ct,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手牌或卡组特殊召唤对应数量的怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果1的效果处理（Operation）：根据被破坏的卡片数量，选择对应数量的「尘妖」怪兽在自己或对方场上特殊召唤
function c96857854.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:GetCount()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) and ct>1 then return end
	-- 获取自己场上可用的怪兽区域数量
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上可用的怪兽区域数量
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft1<=0 and ft2<=0 then return end
	if ft1+ft2<ct then return end
	-- 获取手牌和卡组中所有满足条件的「尘妖」怪兽
	local g=Duel.GetMatchingGroup(c96857854.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if ct>g:GetCount() then return end
	if ft2>ct then ft2=ct end
	local ct2=ct-ft1
	local tc=nil
	-- 如果对方场上有空位，且必须在对方场上特召（自己场上不够放）或玩家选择在对方场上特召
	if ft2>0 and (ct2>0 or Duel.SelectYesNo(tp,aux.Stringid(96857854,0))) then  --"是否在对方场上特殊召唤？"
		if ct2<=0 then ct2=1 end
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg1=g:FilterSelect(tp,Card.IsCanBeSpecialSummoned,ct2,ft2,nil,e,0,tp,false,false,POS_FACEUP,1-tp)
		tc=sg1:GetFirst()
		g:Sub(sg1)
		ct=ct-sg1:GetCount()
		while tc do
			-- 将选中的怪兽以表侧表示特殊召唤到对方场上（分步处理）
			Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP)
			tc=sg1:GetNext()
		end
	end
	if ct>0 then
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg2=g:Select(tp,ct,ct,nil)
		tc=sg2:GetFirst()
		while tc do
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上（分步处理）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc=sg2:GetNext()
		end
	end
	-- 完成所有分步特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 过滤条件：墓地中可以作为除外成本的「尘妖」怪兽
function c96857854.spfilter(c)
	return c:IsSetCard(0x80) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果2的发动成本（Cost）：将自己墓地1只「尘妖」怪兽除外
function c96857854.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在至少1只可除外的「尘妖」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96857854.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择墓地中1只满足条件的「尘妖」怪兽
	local g=Duel.SelectMatchingCard(tp,c96857854.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动成本
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果2的发动准备（Target）：检查对方场上是否有空位，并确认是否可以特殊召唤该陷阱怪兽
function c96857854.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以将此卡作为恶魔族·暗·1星·攻0/守1000的通常怪兽守备表示特殊召唤到对方场上
		and Duel.IsPlayerCanSpecialSummonMonster(tp,96857854,0,TYPES_NORMAL_TRAP_MONSTER,0,1000,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置特殊召唤的操作信息（特殊召唤墓地的这张卡）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果2的效果处理（Operation）：将这张卡作为通常怪兽在对方场上守备表示特殊召唤，并赋予不能解放、不能作为融合/同调/超量素材的限制
function c96857854.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果对方场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e)
		-- 并且确认玩家依然可以特殊召唤该陷阱怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,96857854,0,TYPES_NORMAL_TRAP_MONSTER,0,1000,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE,1-tp) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将这张卡以守备表示特殊召唤到对方场上（分步处理，无视召唤条件）
		Duel.SpecialSummonStep(c,0,tp,1-tp,true,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的这张卡不能解放
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		c:RegisterEffect(e2,true)
		-- 也不能作为融合·同调·超量召唤的素材。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e3:SetValue(c96857854.fuslimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3,true)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e4:SetValue(1)
		c:RegisterEffect(e4,true)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		c:RegisterEffect(e5,true)
		-- 完成特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
end
-- 限制条件：不能作为融合召唤的素材
function c96857854.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
