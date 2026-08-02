--スターゲート
-- 效果：
-- 对方怪兽进行战斗的场合，那个伤害步骤结束时给这张卡放置1个门指示物。自己回合的主要阶段时可以把这张卡送去墓地，这张卡放置的门指示物数量以下的等级的1只怪兽从手卡特殊召唤。
function c97151365.initial_effect(c)
	c:EnableCounterPermit(0x1e)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对方怪兽进行战斗的场合，那个伤害步骤结束时给这张卡放置1个门指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c97151365.ctop)
	c:RegisterEffect(e2)
	-- 自己回合的主要阶段时可以把这张卡送去墓地，这张卡放置的门指示物数量以下的等级的1只怪兽从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(97151365,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c97151365.spcon)
	e3:SetCost(c97151365.spcost)
	e3:SetTarget(c97151365.sptg)
	e3:SetOperation(c97151365.spop)
	c:RegisterEffect(e3)
end
c97151365.mentioned_counter={
	[0x1e]=true,
}
-- 伤害步骤结束时处理的操作：判断是否放置门指示物。
function c97151365.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前战斗是否是对方怪兽进行战斗。
	if Duel.GetTurnPlayer()~=tp or Duel.GetAttackTarget()~=nil then
		e:GetHandler():AddCounter(0x1e,1)
	end
end
-- 特殊召唤效果的发动条件判断。
function c97151365.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是否是自己回合的主要阶段1或主要阶段2。
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 特殊召唤效果的发动代价处理。
function c97151365.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabel(e:GetHandler():GetCounter(0x1e))
	-- 把这张卡送去墓地作为发动的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 用于筛选可以特殊召唤的怪兽的过滤函数，要求等级在门指示物数量以下。
function c97151365.filter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动前检查与操作信息设置。
function c97151365.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查自己场上是否有可用的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动前检查手卡中是否存在等级满足条件且可以特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c97151365.filter,tp,LOCATION_HAND,0,1,nil,e,tp,e:GetHandler():GetCounter(0x1e)) end
	-- 告知系统该效果包含从手卡特殊召唤卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的具体处理。
function c97151365.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己场上是否有可用的主要怪兽区，如果没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡中选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c97151365.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上正面表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
