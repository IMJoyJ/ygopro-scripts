--オルフェゴール・カノーネ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：把墓地的这张卡除外才能发动。从手卡把「自奏圣乐·卡农曲大炮」以外的1只「自奏圣乐」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
function c94046012.initial_effect(c)
	-- ①：把墓地的这张卡除外才能发动。从手卡把「自奏圣乐·卡农曲大炮」以外的1只「自奏圣乐」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94046012,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,94046012)
	-- 将墓地的这张卡除外作为效果发动的代价
	e1:SetCost(aux.bfgcost)
	e1:SetCondition(c94046012.spcon1)
	e1:SetTarget(c94046012.sptg)
	e1:SetOperation(c94046012.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c94046012.spcon2)
	c:RegisterEffect(e2)
end
-- 起动效果的发动条件函数（当场上不存在「自奏圣乐的通天塔」时适用）
function c94046012.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否不满足将效果转变为即时效果的条件（即场上没有「自奏圣乐的通天塔」）
	return not aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 即时效果的发动条件函数（当场上存在「自奏圣乐的通天塔」时适用）
function c94046012.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否满足将效果转变为即时效果的条件（即场上存在「自奏圣乐的通天塔」）
	return aux.IsCanBeQuickEffect(e:GetHandler(),tp,90351981)
end
-- 过滤手牌中除「自奏圣乐·卡农曲大炮」以外的「自奏圣乐」怪兽且可以特殊召唤的卡片过滤函数
function c94046012.spfilter(c,e,tp)
	return c:IsSetCard(0x11b) and not c:IsCode(94046012) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测函数
function c94046012.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌中是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c94046012.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数
function c94046012.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家发送提示信息，要求选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手牌中选择1张满足过滤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c94046012.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c94046012.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤非暗属性怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能特殊召唤非暗属性怪兽的过滤函数
function c94046012.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
