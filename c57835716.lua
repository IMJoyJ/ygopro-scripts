--オルフェゴール・ディヴェル
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把墓地的这张卡除外才能发动。从卡组把「自奏圣乐·嬉游曲恶魔」以外的1只「自奏圣乐」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
function c57835716.initial_effect(c)
	-- ①：把墓地的这张卡除外才能发动。从卡组把「自奏圣乐·嬉游曲恶魔」以外的1只「自奏圣乐」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57835716,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,57835716)
	-- 将墓地的这张卡除外作为发动的代价（Cost）
	e1:SetCost(aux.bfgcost)
	e1:SetCondition(c57835716.spcon1)
	e1:SetTarget(c57835716.sptg)
	e1:SetOperation(c57835716.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c57835716.spcon2)
	c:RegisterEffect(e2)
end
-- 起动效果的发动条件，当场上不存在能让此卡效果变为即时效果的卡（如「自奏圣乐的通天塔」）时适用
function c57835716.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检测当前是否不满足将效果转变为诱发即时效果的条件（即场上没有「自奏圣乐的通天塔」）
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 诱发即时效果的发动条件，当场上存在能让此卡效果变为即时效果的卡（如「自奏圣乐的通天塔」）时适用
function c57835716.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检测当前是否满足将效果转变为诱发即时效果的条件（即场上存在「自奏圣乐的通天塔」）
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 过滤卡组中除「自奏圣乐·嬉游曲恶魔」以外的、可以特殊召唤的「自奏圣乐」怪兽
function c57835716.spfilter(c,e,tp)
	return c:IsSetCard(0x11b) and not c:IsCode(57835716) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标与可行性检测，确认自身怪兽区域有空位且卡组中存在可特殊召唤的合法怪兽
function c57835716.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检测自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段检测卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c57835716.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，声明该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理，从卡组特殊召唤1只「自奏圣乐」怪兽，并适用“直到回合结束时自己不是暗属性怪兽不能特殊召唤”的限制
function c57835716.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，再次检测自己场上是否有可用于特殊召唤的怪兽区域空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给玩家发送提示信息，提示其选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择1只满足过滤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c57835716.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c57835716.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤暗属性以外怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤条件，使玩家不能特殊召唤非暗属性的怪兽
function c57835716.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
