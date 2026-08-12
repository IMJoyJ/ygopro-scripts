--ドリ・ドル・ドラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在决斗中只能使用1次。
-- ①：自己场上的表侧表示卡被效果破坏的场合才能发动（伤害步骤也能发动）。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。这个回合的结束阶段，从自己墓地把1只风属性怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成1000。
local s,id,o=GetID()
-- 注册卡片效果：①效果（手卡特殊召唤）、②效果（召唤·特殊召唤成功时注册回合结束阶段的特殊召唤效果）。
function s.initial_effect(c)
	-- ①：自己场上的表侧表示卡被效果破坏的场合才能发动（伤害步骤也能发动）。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。这个回合的结束阶段，从自己墓地把1只风属性怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上因效果破坏的表侧表示卡。
function s.desfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
end
-- ①效果的发动条件：检查被破坏的卡中是否存在满足过滤条件的卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,nil,tp)
end
-- ①效果的发动准备：检查自身是否可以特殊召唤以及怪兽区域是否有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：将1张自身卡片特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：将手卡的这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的处理：注册一个在回合结束阶段发动的延迟效果。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，从自己墓地把1只风属性怪兽特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成1000。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	-- 将当前回合数记录为效果的标签值，用于后续判断。
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetCondition(s.gspcon)
	e1:SetOperation(s.gspop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该延迟效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：墓地的风属性怪兽且可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 延迟效果的发动条件：怪兽区域有空位且墓地存在满足条件的风属性怪兽。
function s.gspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以特殊召唤的风属性怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
end
-- 延迟效果的处理：从墓地选择1只风属性怪兽特殊召唤，并将其攻击力·守备力变成1000。
function s.gspop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动效果的卡片。
	Duel.Hint(HINT_CARD,0,id)
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只满足条件的风属性怪兽（受王家之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 如果成功选择怪兽，则尝试将其以表侧表示特殊召唤（分步处理）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的攻击力·守备力变成1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的后续处理。
	Duel.SpecialSummonComplete()
end
