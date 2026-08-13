--炎王獣 ハヌマーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的「炎王」怪兽被效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在怪兽区域存在，魔法·陷阱卡的效果发动时才能发动。那个发动无效，这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏。
local s,id,o=GetID()
-- 注册这张卡的两个效果：①从手卡特殊召唤，②无效魔法·陷阱卡并破坏炎属性怪兽；此卡名的①②效果1回合各能使用1次。
function s.initial_effect(c)
	-- ①：自己场上的表侧表示的「炎王」怪兽被效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在，魔法·陷阱卡的效果发动时才能发动。那个发动无效，这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 过滤被破坏的怪兽：必须是我方场上表侧表示、之前由我方控制、被效果破坏、且属于「炎王」系列的怪兽。
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:IsSetCard(0x81)
end
-- ①效果的发动条件：此次被破坏的怪兽集合中存在满足上述过滤条件的「炎王」怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①效果发动时确认：自己主要怪兽区有空位，且这张卡可从手卡特殊召唤（满足召唤条件）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本连锁的处理信息为特殊召唤1只怪兽（这张卡），供其他卡的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其从手卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以表侧表示将这张卡特殊召唤到我方怪兽区。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件：当前连锁的效果是魔法·陷阱卡的效果发动，这张卡自身未被战斗破坏，且该连锁发动可以被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 具体条件为：发动效果的原卡是魔法/陷阱卡、这张卡没有处于战斗破坏确定状态、且该连锁可以被无效。
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 选择要破坏的炎属性怪兽的筛选条件：是怪兽、炎属性，且在手卡或场上表侧表示。
function s.desfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceupEx()
end
-- ②效果发动时：确认存在除自身以外满足条件的炎属性怪兽，并登记【无效发动】与【破坏怪兽】两项处理信息。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上·手卡是否存在至少1只除这张卡以外的满足条件的炎属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,e:GetHandler()) end
	-- 登记本效果将无效当前连锁的魔法·陷阱卡发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 登记本效果将在处理时破坏1只炎属性怪兽，范围为自己场上·手卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
-- ②效果处理：若成功无效该魔法·陷阱卡发动，则从自己场上·手卡选择1只除自身外的炎属性怪兽破坏。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效对应的魔法·陷阱卡发动，仅在无效成功时才进行后续破坏。
	if Duel.NegateActivation(ev) then
		-- 显示选择提示，要求玩家选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从我方场上·手卡选择1张满足条件的炎属性怪兽（排除这张卡自身）。
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,aux.ExceptThisCard(e))
		if g:GetCount()>0 then
			-- 将选择的怪兽以效果原因破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
