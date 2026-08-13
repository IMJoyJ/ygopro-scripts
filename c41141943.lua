--超重武者ヒキャ－Q
-- 效果：
-- 「超重武者 飞脚-Q」的②的效果1回合只能使用1次。
-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
-- ②：自己墓地没有魔法·陷阱卡存在的场合，把这张卡解放才能发动。从手卡把最多2只怪兽在对方场上守备表示特殊召唤。那之后，自己从卡组抽出这个效果特殊召唤的怪兽的数量。
function c41141943.initial_effect(c)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41141943,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c41141943.hspcon)
	e1:SetOperation(c41141943.hspop)
	c:RegisterEffect(e1)
	-- 「超重武者 飞脚-Q」的②的效果1回合只能使用1次。②：自己墓地没有魔法·陷阱卡存在的场合，把这张卡解放才能发动。从手卡把最多2只怪兽在对方场上守备表示特殊召唤。那之后，自己从卡组抽出这个效果特殊召唤的怪兽的数量。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,41141943)
	e2:SetCondition(c41141943.spcon)
	e2:SetCost(c41141943.spcost)
	e2:SetTarget(c41141943.sptg)
	e2:SetOperation(c41141943.spop)
	c:RegisterEffect(e2)
end
-- 定义过滤器：判断卡片是否为魔法·陷阱卡，用于后续检查墓地是否存在魔法·陷阱卡。
function c41141943.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果的规则特殊召唤条件：自己场上有可用主要怪兽区域，且自己墓地不存在魔法·陷阱卡；c为nil时表示询问是否可以规则特殊召唤该卡。
function c41141943.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用主要怪兽区域（特殊召唤所需空位）。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地不存在魔法·陷阱卡（魔法·陷阱卡数量为0）。
		and not Duel.IsExistingMatchingCard(c41141943.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- ①效果特殊召唤成功后的自肃处理：给自己附加“不是「超重武者」怪兽不能特殊召唤”的誓约效果，持续到回合结束。
function c41141943.hspop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个方法特殊召唤成功的回合，自己不是「超重武者」怪兽不能特殊召唤。「超重武者 飞脚-Q」的②的效果1回合只能使用1次。②：自己墓地没有魔法·陷阱卡存在的场合，把这张卡解放才能发动。从手卡把最多2只怪兽在对方场上守备表示特殊召唤。那之后，自己从卡组抽出这个效果特殊召唤的怪兽的数量。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c41141943.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果e1注册给当前玩家tp，使其在该玩家场上持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的过滤函数：只有卡名含有「超重武者」字段的怪兽才能被特殊召唤，其他怪兽不能特殊召唤。
function c41141943.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9a)
end
-- ②效果的发动条件判定：自己墓地没有魔法·陷阱卡。
function c41141943.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地不存在魔法·陷阱卡。
	return not Duel.IsExistingMatchingCard(c41141943.filter,tp,LOCATION_GRAVE,0,1,nil)
end
-- ②效果的发动代价：解放这张卡；chk==0时仅检查该卡是否可解放，实际执行时解放自身。
function c41141943.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放送入墓地，作为发动代价（REASON_COST，不会因其他效果而无效）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 选择条件：手牌中的怪兽可以被效果以表侧守备表示特殊召唤到对方场上（1-tp）。
function c41141943.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- ②效果的发动目标检查：对方场上有可用主要怪兽区域、自己可以抽卡、手牌中存在至少1只满足特殊召唤条件的怪兽；并设置特殊召唤、抽卡的操作信息。
function c41141943.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方（1-tp）场上有可用主要怪兽区域，用于在对方场上特殊召唤怪兽。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查自己能否进行效果抽卡（至少抽1张）。
		and Duel.IsPlayerCanDraw(tp,1)
		-- 检查手牌中是否存在至少1只满足条件（可被特殊召唤到对方场上）的怪兽。
		and Duel.IsExistingMatchingCard(c41141943.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本效果包含特殊召唤，对象位置为手牌，预计数量1，操作玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：本效果包含抽卡，预计抽1张（实际数量由特殊召唤成功的数量决定）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：从手牌选择1～最多2只怪兽在对方场上表侧守备表示特殊召唤，之后按成功特殊召唤的数量抽卡；若【青眼精灵龙】效果适用，则最多只能特殊召唤1只。
function c41141943.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手牌中所有满足特殊召唤条件的怪兽集合g。
	local g=Duel.GetMatchingGroup(c41141943.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 计算本次最多可特殊召唤的数量：取自己场上可用主要怪兽区域数与2的较小值，作为选择上限。
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	if g:GetCount()==0 or ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向tp玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,ft,nil)
	-- 将选中的怪兽由tp玩家特殊召唤到对方（1-tp）场上，表侧守备表示，返回实际特殊召唤成功的数量ct。
	local ct=Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	if ct>0 then
		-- 中断当前效果处理链，使后续的抽卡处理与特殊召唤处理不同时进行，避免错失时点。
		Duel.BreakEffect()
		-- 自己按照实际特殊召唤成功的数量ct从卡组抽卡（效果抽卡，原因为REASON_EFFECT）。
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end
