--クラスター・コンジェスター
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上没有连接怪兽存在，这张卡召唤·特殊召唤成功的场合才能发动。在自己场上把1只「拥塞器衍生物」（电子界族·暗·1星·攻/守0）特殊召唤。
-- ②：自己的连接怪兽被攻击的战斗步骤1次，把那只连接怪兽和墓地的这张卡除外才能发动。把最多有对方场上的连接怪兽数量的「拥塞器衍生物」在自己场上特殊召唤。
function c94703021.initial_effect(c)
	-- ①：自己场上没有连接怪兽存在，这张卡召唤·特殊召唤成功的场合才能发动。在自己场上把1只「拥塞器衍生物」（电子界族·暗·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,94703021)
	e1:SetCondition(c94703021.tkcon1)
	e1:SetTarget(c94703021.tktg1)
	e1:SetOperation(c94703021.tkop1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己的连接怪兽被攻击的战斗步骤1次，把那只连接怪兽和墓地的这张卡除外才能发动。把最多有对方场上的连接怪兽数量的「拥塞器衍生物」在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_BATTLE_PHASE)
	e3:SetCondition(c94703021.tkcon2)
	e3:SetCost(c94703021.tkcost2)
	e3:SetTarget(c94703021.tktg2)
	e3:SetOperation(c94703021.tkop2)
	c:RegisterEffect(e3)
end
-- ①号效果的发动条件判断函数
function c94703021.tkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在连接怪兽，若没有则返回true
	return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_LINK)==0
end
-- ①号效果的发动准备（Target）函数
function c94703021.tktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查玩家是否可以特殊召唤「拥塞器衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,94703022,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) end
	-- 设置特殊召唤的操作信息，预计特招1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	-- 设置衍生物产生的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- ①号效果的效果处理（Operation）函数
function c94703021.tkop1(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，再次检查是否有可用怪兽区域以及是否能特招该衍生物
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,94703022,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then
		-- 创建「拥塞器衍生物」的卡片数据
		local tk=Duel.CreateToken(tp,94703022)
		-- 将创建的衍生物在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果的发动条件判断函数
function c94703021.tkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击的怪兽
	local at=Duel.GetAttackTarget()
	-- 获取自己场上的所有连接怪兽
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_LINK)
	return at and g:IsContains(at)
end
-- ②号效果的发动代价（Cost）函数
function c94703021.tkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查墓地的这张卡是否能除外
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		-- 并检查被攻击的怪兽是否能除外，且该怪兽离开后自己场上是否有可用怪兽区域
		and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,Duel.GetAttackTarget())>0 end
	-- 将墓地的这张卡和被攻击的怪兽组合成一个卡组
	local g=Group.FromCards(e:GetHandler(),Duel.GetAttackTarget())
	-- 将这两张卡表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②号效果的发动准备（Target）函数
function c94703021.tktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查对方场上是否存在连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE,1,nil,TYPE_LINK)
		-- 并检查玩家是否可以特殊召唤「拥塞器衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,94703022,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	-- 设置衍生物产生的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
-- ②号效果的效果处理（Operation）函数
function c94703021.tkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，若不能特招该衍生物则直接结束
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,94703022,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_DARK) then return end
	-- 计算本次特招的最大数量（对方场上连接怪兽数量与自己可用怪兽区域数量的较小值）
	local ct=math.min(Duel.GetMatchingGroupCount(Card.IsType,tp,0,LOCATION_MZONE,nil,TYPE_LINK),(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	if ct<1 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	repeat
		-- 创建「拥塞器衍生物」的卡片数据
		local token=Duel.CreateToken(tp,94703022)
		-- 将衍生物放入特殊召唤的准备队列中（表侧表示）
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		ct=ct-1
	-- 循环特招，直到达到最大数量或玩家选择不再继续特招
	until ct<=0 or not Duel.SelectYesNo(tp,aux.Stringid(94703021,0))  --"是否继续特殊召唤？"
	-- 完成所有准备队列中怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
end
