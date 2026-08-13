--究極変異態・インセクト女王
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：场上有其他的昆虫族怪兽存在的场合，自己场上的昆虫族怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
-- ②：这张卡攻击的伤害步骤结束时，把自己场上1只怪兽解放才能发动。这张卡向对方怪兽可以继续攻击。
-- ③：自己·对方的结束阶段才能发动。在自己场上把1只「昆虫怪兽衍生物」（昆虫族·地·1星·攻/守100）特殊召唤。
function c41456841.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c41456841.splimit)
	c:RegisterEffect(e1)
	-- ①：场上有其他的昆虫族怪兽存在的场合，自己场上的昆虫族怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c41456841.indcon)
	-- 设置该效果的保护对象为我方场上的昆虫族怪兽（获得破坏抗性）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT))
	-- 设置‘不会被对方的效果破坏’的判定条件：仅对方发动的效果无法破坏这些昆虫族怪兽。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ①：场上有其他的昆虫族怪兽存在的场合，自己场上的昆虫族怪兽不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c41456841.indcon)
	-- 指定此效果适用的目标为我方场上的昆虫族怪兽（不能被选为对象）。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT))
	-- 设置‘不会成为对方的效果的对象’的判定条件：仅对方发动的效果不能选择这些昆虫族怪兽为对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：这张卡攻击的伤害步骤结束时，把自己场上1只怪兽解放才能发动。这张卡向对方怪兽可以继续攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41456841,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(c41456841.atcon)
	e4:SetCost(c41456841.atcost)
	e4:SetOperation(c41456841.atop)
	c:RegisterEffect(e4)
	-- ③：自己·对方的结束阶段才能发动。在自己场上把1只「昆虫怪兽衍生物」（昆虫族·地·1星·攻/守100）特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(41456841,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCountLimit(1)
	e5:SetTarget(c41456841.sptg)
	e5:SetOperation(c41456841.spop)
	c:RegisterEffect(e5)
end
-- 特殊召唤条件判定：仅当特殊召唤来自卡的效果（EFFECT_TYPE_ACTIONS）时才允许，实现‘不能通常召唤，用卡的效果才能特殊召唤’。
function c41456841.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 过滤条件：表侧表示且种族为昆虫族的怪兽。
function c41456841.indfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 条件判定：检查场上（双方怪兽区）是否存在这张卡以外的表侧表示昆虫族怪兽。
function c41456841.indcon(e)
	-- 检测场上是否存在至少1张满足条件的其他表侧表示昆虫族怪兽（排除这张卡自身）。
	return Duel.IsExistingMatchingCard(c41456841.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- ②的发动条件：这张卡是本次伤害步骤结束时的攻击怪兽，且满足可继续攻击的条件。
function c41456841.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断本次攻击者是否为这张卡且这张卡能够发动追加攻击。
	return Duel.GetAttacker()==c and c:IsChainAttackable(0,true)
end
-- 代价处理：解放自己场上1只怪兽作为发动代价（选择时排除这张卡自身）。
function c41456841.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：检查是否存在至少1只除这张卡以外的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,e:GetHandler()) end
	-- 选择1只除这张卡以外的自己场上的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,e:GetHandler())
	-- 将选择的怪兽解放，作为发动的代价。
	Duel.Release(g,REASON_COST)
end
-- 效果处理：若这张卡仍存在于场上且与此次战斗相关，则进行追加攻击，并附加不能直接攻击的限制，保证只能攻击对方怪兽。
function c41456841.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() then return end
	-- 使这张卡获得再进行一次攻击的机会。
	Duel.ChainAttack()
	-- 这张卡向对方怪兽可以继续攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+PHASE_DAMAGE_CAL)
	c:RegisterEffect(e1)
end
-- ③的发动条件：自己场上存在可用主要怪兽区，且能够特殊召唤「昆虫怪兽衍生物」。
function c41456841.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤「昆虫怪兽衍生物」（昆虫族·地·1星·攻/守100）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,91512836,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 设置本次效果将产生衍生物的操作信息（用于连锁/时点检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本次效果将进行特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ③的效果处理：在自己场上特殊召唤1只「昆虫怪兽衍生物」。
function c41456841.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上仍有可用的主要怪兽区，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 效果处理时再次确认玩家能够特殊召唤衍生物，否则不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,91512836,0,TYPES_TOKEN_MONSTER,100,100,1,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	-- 创建1只「昆虫怪兽衍生物」（卡号41456842）。
	local token=Duel.CreateToken(tp,41456842)
	-- 将衍生物以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
