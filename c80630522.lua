--花札衛－桐－
-- 效果：
-- ①：自己场上有11星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
-- ②：这张卡被选择作为攻击对象时才能发动。那次攻击无效，战斗阶段结束。那之后，自己从卡组抽1张。
function c80630522.initial_effect(c)
	-- ①：自己场上有11星以下的「花札卫」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c80630522.spcon)
	e1:SetTarget(c80630522.sptg)
	e1:SetOperation(c80630522.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被选择作为攻击对象时才能发动。那次攻击无效，战斗阶段结束。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetTarget(c80630522.target)
	e2:SetOperation(c80630522.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的11星以下的「花札卫」怪兽
function c80630522.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe6) and c:IsLevelBelow(11)
end
-- 特殊召唤效果的发动条件：检查自己场上是否存在满足过滤条件的怪兽
function c80630522.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的11星以下的「花札卫」怪兽
	return Duel.IsExistingMatchingCard(c80630522.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的靶向/发动准备：检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c80630522.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，准备将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：将自身特殊召唤，并注册直到回合结束时自己不能召唤·特殊召唤「花札卫」以外怪兽的限制效果
function c80630522.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是「花札卫」怪兽不能召唤·特殊召唤。/②：这张卡被选择作为攻击对象时才能发动。那次攻击无效，战斗阶段结束。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c80630522.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能特殊召唤「花札卫」以外怪兽的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 给玩家注册不能通常召唤「花札卫」以外怪兽的效果
	Duel.RegisterEffect(e2,tp)
end
-- 召唤/特殊召唤限制：过滤非「花札卫」怪兽
function c80630522.splimit(e,c)
	return not c:IsSetCard(0xe6)
end
-- 攻击无效效果的发动准备：检查自己是否能抽卡，并设置抽卡的操作信息
function c80630522.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己当前是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡的操作信息，准备从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 攻击无效效果的处理：无效攻击，结束战斗阶段，然后自己抽1张卡
function c80630522.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效当前的攻击，若成功则继续处理后续效果
	if Duel.NegateAttack() then
		-- 跳过对方的战斗阶段，使其直接进入战斗结束步骤（即结束战斗阶段）
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		-- 中断当前效果处理，使后续的抽卡处理与前面的无效攻击、结束战斗阶段不视为同时处理
		Duel.BreakEffect()
		-- 玩家因效果从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
