--フォトン・エンペラー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡从场上以外送去墓地的场合，若这张卡以外的「光子」怪兽或「银河」怪兽在自己的场上或墓地存在则能发动。这张卡守备表示特殊召唤。
-- ②：这张卡召唤·特殊召唤时适用。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只光属性怪兽召唤。
function c73478096.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡从场上以外送去墓地的场合，若这张卡以外的「光子」怪兽或「银河」怪兽在自己的场上或墓地存在则能发动。这张卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73478096,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e1:SetCountLimit(1,73478096)
	e1:SetCondition(c73478096.spcon)
	e1:SetTarget(c73478096.sptg)
	e1:SetOperation(c73478096.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤时适用。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只光属性怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c73478096.sumop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上或墓地的「光子」或「银河」怪兽
function c73478096.cfilter(c)
	return c:IsSetCard(0x55,0x7b) and c:IsType(TYPE_MONSTER) and c:IsFaceupEx()
end
-- 效果①的发动条件：这张卡从场上以外送去墓地，且自己场上或墓地存在除自身以外的「光子」或「银河」怪兽
function c73478096.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LOCATION_ONFIELD)
		-- 检查自己场上或墓地是否存在至少1只除这张卡以外的「光子」或「银河」怪兽
		and Duel.IsExistingMatchingCard(c73478096.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c)
end
-- 效果①的发动准备：检查怪兽区域是否有空位，以及这张卡是否可以特殊召唤
function c73478096.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁中的操作信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理：若这张卡仍在墓地，则将其守备表示特殊召唤
function c73478096.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的处理：若本回合未适用过此效果，则为玩家注册一个在主要阶段可以额外召唤1只光属性怪兽的效果
function c73478096.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家本回合是否已经适用过「光子皇帝」的额外召唤效果，若已适用则直接返回
	if Duel.GetFlagEffect(tp,73478096)~=0 then return end
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只光属性怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(73478096,1))  --"使用「光子皇帝」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 设置额外召唤的限制条件为光属性怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))
	-- 给玩家注册该额外召唤效果
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个持续到回合结束的标记，用于确保该额外召唤效果每回合只能适用1次
	Duel.RegisterFlagEffect(tp,73478096,RESET_PHASE+PHASE_END,0,1)
end
