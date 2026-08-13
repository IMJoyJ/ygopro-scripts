--Sin トゥルース・ドラゴン
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
-- ①：「罪 真实龙」以外的自己场上的表侧表示的「罪」怪兽被战斗·效果破坏的场合，把基本分支付一半才能发动。这张卡从手卡·墓地特殊召唤。
-- ②：「罪」怪兽在场上只能有1只表侧表示存在。
-- ③：没有场地魔法卡表侧表示存在的场合这张卡破坏。
-- ④：这张卡战斗破坏对方怪兽的场合发动。对方场上的表侧表示怪兽全部破坏。
function c37115575.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,1,c37115575.uqfilter,LOCATION_MZONE)
	-- ①："罪 真实龙"以外的自己场上的表侧表示的"罪"怪兽被战斗·效果破坏的场合，把基本分支付一半才能发动。这张卡从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37115575,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c37115575.spcon)
	e1:SetCost(c37115575.spcost)
	e1:SetTarget(c37115575.sptg)
	e1:SetOperation(c37115575.spop)
	c:RegisterEffect(e1)
	-- ③：没有场地魔法卡表侧表示存在的场合这张卡破坏。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_SELF_DESTROY)
	e7:SetCondition(c37115575.descon)
	c:RegisterEffect(e7)
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e8:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件效果的判定值设为false，使这张卡不能通过其他效果或通常召唤方式特殊召唤；自己的①效果进行特殊召唤时通过nocheck/nolimit跳过该条件，从而只允许用自身效果特殊召唤。
	e8:SetValue(aux.FALSE)
	c:RegisterEffect(e8)
	-- ④：这张卡战斗破坏对方怪兽的场合发动。对方场上的表侧表示怪兽全部破坏。
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(37115575,1))  --"对方表侧表示的怪兽全部破坏"
	e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e9:SetCategory(CATEGORY_DESTROY)
	e9:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置④效果的发动条件：这张卡与对方怪兽战斗并将其战斗破坏时才能发动（aux.bdocon会检测当前卡片与本次战斗的关联）。
	e9:SetCondition(aux.bdocon)
	e9:SetTarget(c37115575.detg)
	e9:SetOperation(c37115575.deop)
	c:RegisterEffect(e9)
end
-- 唯一性过滤函数：用于判定场上同名/字段卡的唯一限制范围。若控制者适用"罪 领域"的效果，则只限制"罪 真实龙"这1个种类只能有1只；若不适用，则限制所有"罪"字段怪兽合计只能有1只表侧表示存在。
function c37115575.uqfilter(c)
	-- 检查这张卡的控制者是否受到卡号75223115（罪 领域）的效果影响，以决定②效果的唯一性限制方式。
	if Duel.IsPlayerAffectedByEffect(c:GetControler(),75223115) then
		return c:IsCode(37115575)
	else
		return c:IsSetCard(0x23)
	end
end
-- 判断被破坏的怪兽是否为满足①条件的卡：破坏前由自己控制、在怪兽区域表侧表示、属于"罪"字段，且不是"罪 真实龙"本身，并且不是规则破坏（如因没有场地自毁等）。
function c37115575.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousSetCard(0x23) and c:GetPreviousCodeOnField()~=37115575 and not c:IsReason(REASON_RULE)
end
-- ①效果的发动条件：在本次被破坏的卡组中，存在至少1张符合cfilter条件的"罪"怪兽（自己场上被战斗/效果破坏、非本卡、非规则破坏的表侧表示"罪"怪兽）。
function c37115575.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c37115575.cfilter,1,nil,tp)
end
-- ①效果的发动代价：支付基本分的一半；chk==0时仅检查代价是否可支付，实际支付在效果发动时执行。
function c37115575.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 执行代价支付：将当前LP的一半作为cost支付（向下取整）。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- ①效果发动时的目标/可行性判定：确认自己主要怪兽区域有空位，且这张卡可以从手卡/墓地特殊召唤；满足才可发动。
function c37115575.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查自己场上是否至少存在1个可用主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 向连锁登记操作信息：声明本效果将把这张卡进行特殊召唤，数量为1，用于连锁判定和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若这张卡仍与效果关联，则忽略召唤条件和苏生限制，将其正面表示特殊召唤到自己的主要怪兽区域；特召成功后执行CompleteProcedure完成特殊召唤手续。
function c37115575.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤，nocheck=true、nolimit=true表示不检查召唤条件与苏生限制；返回非0表示至少有1只怪特殊召唤成功。
	if Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- ③自毁效果的条件：场上不存在任何表侧表示的场地魔法卡时，这张卡被破坏。
function c37115575.descon(e)
	-- 检查双方场地区域（LOCATION_FZONE）合计是否存在至少1张表侧表示场地魔法卡；不存在时返回true，触发自毁。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- ④效果的目标/发动确认：因为是必发效果，chk==0直接返回true；然后获取对方场上的全部表侧表示怪兽，并登记为将被破坏的卡。
function c37115575.detg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上当前全部表侧表示怪兽，作为即将被破坏的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 登记破坏操作信息：破坏对象为对方场上所有表侧表示怪兽，数量为其张数，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ④效果处理：重新获取对方场上的全部表侧表示怪兽，并以效果将其全部破坏。
function c37115575.deop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上当前全部表侧表示怪兽，作为效果破坏的对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因（REASON_EFFECT）将这些怪兽破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
