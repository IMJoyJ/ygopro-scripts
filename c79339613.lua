--ソウルエナジーMAX！！
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有原本属性是神属性的「欧贝利斯克之巨神兵」存在的场合，把自己场上2只其他的表侧表示怪兽解放才能发动。对方场上的怪兽全部破坏，给与对方4000伤害。
-- ②：自己·对方的主要阶段以及战斗阶段，把墓地的这张卡除外才能发动。从自己的卡组·墓地选1只「欧贝利斯克之巨神兵」加入手卡。那之后，可以把1只「欧贝利斯克之巨神兵」召唤。
function c79339613.initial_effect(c)
	-- 注册卡片密码，表示这张卡的效果记有「欧贝利斯克之巨神兵」的卡名
	aux.AddCodeList(c,10000000)
	-- ①：自己场上有原本属性是神属性的「欧贝利斯克之巨神兵」存在的场合，把自己场上2只其他的表侧表示怪兽解放才能发动。对方场上的怪兽全部破坏，给与对方4000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,79339613)
	e1:SetCondition(c79339613.condition)
	e1:SetCost(c79339613.cost)
	e1:SetTarget(c79339613.target)
	e1:SetOperation(c79339613.activate)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段以及战斗阶段，把墓地的这张卡除外才能发动。从自己的卡组·墓地选1只「欧贝利斯克之巨神兵」加入手卡。那之后，可以把1只「欧贝利斯克之巨神兵」召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1,79339614)
	e2:SetCondition(c79339613.thcon)
	-- 设置效果2的发动代价为把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c79339613.thtg)
	e2:SetOperation(c79339613.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示、原本属性为神属性的「欧贝利斯克之巨神兵」
function c79339613.filter(c)
	return c:IsCode(10000000) and c:GetOriginalAttribute()==ATTRIBUTE_DIVINE and c:IsFaceup()
end
-- 效果1的发动条件：自己场上存在原本属性是神属性的「欧贝利斯克之巨神兵」
function c79339613.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件（原本属性为神属性的「欧贝利斯克之巨神兵」）的怪兽
	return Duel.IsExistingMatchingCard(c79339613.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果1的发动代价：解放自己场上2只其他的表侧表示怪兽
function c79339613.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有满足过滤条件（原本属性为神属性的「欧贝利斯克之巨神兵」）的怪兽组，用于在解放时排除它们
	local g=Duel.GetMatchingGroup(c79339613.filter,tp,LOCATION_MZONE,0,nil)
	-- 步骤1：检查自己场上是否存在至少2只除上述「欧贝利斯克之巨神兵」以外的表侧表示怪兽可用于解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsFaceup,2,g) end
	-- 步骤2：让玩家选择2只除上述「欧贝利斯克之巨神兵」以外的表侧表示怪兽
	local rg=Duel.SelectReleaseGroup(tp,Card.IsFaceup,2,2,g)
	-- 步骤3：将选中的怪兽解放作为发动代价
	Duel.Release(rg,REASON_COST)
end
-- 效果1的靶向/发动准备：检查对方场上是否有怪兽，并注册破坏与伤害的操作信息
function c79339613.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤1：检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 注册破坏操作信息，包含对方场上的所有怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 注册伤害操作信息，给与对方4000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,4000)
	-- 设置效果处理的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的目标参数为4000（伤害数值）
	Duel.SetTargetParam(4000)
end
-- 效果1的处理：破坏对方场上所有怪兽，并给与对方4000伤害
function c79339613.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 破坏对方场上的所有怪兽，若成功破坏了至少1只，则继续执行后续处理
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取之前设置的目标玩家（对方）和目标参数（4000伤害）
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 给与目标玩家对应的伤害
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
-- 效果2的发动条件：自己或对方的主要阶段
function c79339613.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()>=PHASE_MAIN1 and Duel.GetCurrentPhase()<=PHASE_MAIN2
end
-- 过滤条件：卡名为「欧贝利斯克之巨神兵」且能加入手卡
function c79339613.thfilter(c)
	return c:IsCode(10000000) and c:IsAbleToHand()
end
-- 效果2的靶向/发动准备：检查卡组或墓地是否有「欧贝利斯克之巨神兵」，并注册检索操作信息
function c79339613.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤1：检查自己的卡组或墓地是否存在至少1张「欧贝利斯克之巨神兵」
	if chk==0 then return Duel.IsExistingMatchingCard(c79339613.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 步骤2：注册将卡组或墓地的1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 过滤条件：可以进行通常召唤（包括上级召唤）的「欧贝利斯克之巨神兵」
function c79339613.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsCode(10000000)
end
-- 效果2的处理：从卡组或墓地将1只「欧贝利斯克之巨神兵」加入手卡，之后可以将其召唤
function c79339613.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张「欧贝利斯克之巨神兵」（适用王家长眠之谷的过滤）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c79339613.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡加入手卡，若成功加入手卡则继续处理
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查手卡或场上是否存在可以召唤的「欧贝利斯克之巨神兵」
		if Duel.IsExistingMatchingCard(c79339613.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
			-- 询问玩家是否进行召唤
			and Duel.SelectYesNo(tp,aux.Stringid(79339613,0)) then  --"是否召唤？"
			-- 中断当前效果处理，使后续的召唤处理不与加入手牌同时进行
			Duel.BreakEffect()
			-- 洗切手牌（防止通过手牌位置指示其他卡片信息）
			Duel.ShuffleHand(tp)
			-- 提示玩家选择要召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 从手卡或场上选择1只可以召唤的「欧贝利斯克之巨神兵」
			local sg=Duel.SelectMatchingCard(tp,c79339613.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
			if sg:GetCount()>0 then
				-- 忽略每回合的通常召唤次数限制，将选中的「欧贝利斯克之巨神兵」进行通常召唤
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
end
