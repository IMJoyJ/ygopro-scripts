--EMユニ
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段才能发动1次。从手卡把1只3星以下的「娱乐伙伴」怪兽攻击表示特殊召唤。
-- ②：对方回合，从自己墓地把这张卡和1只「娱乐伙伴 小独」以外的「娱乐伙伴」怪兽除外才能发动。这个回合自己受到的战斗伤害只有1次变成0。
function c7714344.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段才能发动1次。从手卡把1只3星以下的「娱乐伙伴」怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7714344,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c7714344.spcon)
	e1:SetTarget(c7714344.sptg)
	e1:SetOperation(c7714344.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，从自己墓地把这张卡和1只「娱乐伙伴 小独」以外的「娱乐伙伴」怪兽除外才能发动。这个回合自己受到的战斗伤害只有1次变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7714344,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c7714344.damcon)
	e2:SetCost(c7714344.damcost)
	e2:SetOperation(c7714344.damop)
	c:RegisterEffect(e2)
	if not c7714344.global_check then
		c7714344.global_check=true
		-- ①：这张卡召唤·特殊召唤成功的回合的自己主要阶段才能发动1次。从手卡把1只3星以下的「娱乐伙伴」怪兽攻击表示特殊召唤。②：对方回合，从自己墓地把这张卡和1只「娱乐伙伴 小独」以外的「娱乐伙伴」怪兽除外才能发动。这个回合自己受到的战斗伤害只有1次变成0。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(7714344)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置全局效果的操作为：在召唤成功时给该卡注册召唤成功的回合标记
		ge1:SetOperation(aux.sumreg)
		-- 在全局环境注册该通常召唤检测效果
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(7714344)
		-- 在全局环境注册该特殊召唤检测效果
		Duel.RegisterEffect(ge2,0)
	end
end
-- 效果①的发动条件：自身在本回合内进行过召唤或特殊召唤
function c7714344.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(7714344)>0
end
-- 过滤条件：手卡中等级3以下且可以表侧攻击表示特殊召唤的「娱乐伙伴」怪兽
function c7714344.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x9f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果①的发动准备：检查怪兽区域空位以及手卡中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c7714344.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c7714344.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理：从手卡选择1只满足条件的「娱乐伙伴」怪兽以表侧攻击表示特殊召唤
function c7714344.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的「娱乐伙伴」怪兽
	local g=Duel.SelectMatchingCard(tp,c7714344.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 过滤条件：墓地中除「娱乐伙伴 小独」以外的「娱乐伙伴」怪兽，且可以作为cost除外
function c7714344.cfilter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and not c:IsCode(7714344)
end
-- 效果②的发动条件：对方回合，且处于可以进行战斗相关操作的时点或阶段
function c7714344.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合，且是否处于可以进行战斗相关操作的时点或阶段
	return Duel.GetTurnPlayer()~=tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果②的发动代价：将墓地的这张卡和1只除自身以外的「娱乐伙伴」怪兽除外
function c7714344.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己墓地中是否存在至少1只除自身以外的「娱乐伙伴」怪兽
		and Duel.IsExistingMatchingCard(c7714344.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地选择1只除自身以外的「娱乐伙伴」怪兽
	local g=Duel.SelectMatchingCard(tp,c7714344.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的怪兽和墓地的这张卡作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的效果处理：注册一个全局效果，使本回合自己受到的战斗伤害只有1次变成0
function c7714344.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合自己受到的战斗伤害只有1次变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL+PHASE_END)
	-- 给玩家注册该战斗伤害免疫效果
	Duel.RegisterEffect(e1,tp)
end
