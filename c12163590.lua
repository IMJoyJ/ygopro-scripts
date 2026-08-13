--ドラゴンメイド・シュテルン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。「半龙女仆·星夜龙女」以外的自己的墓地·除外状态的1只「半龙女仆」怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己场上的龙族融合怪兽不会被对方的效果破坏。
-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只4星以下的「半龙女仆」怪兽特殊召唤。
local s,id,o=GetID()
-- 注册该卡的全部效果：①从手卡丢弃自身，特殊召唤自己墓地/除外区1只「半龙女仆」怪兽；②保护自己场上的龙族融合怪兽不被对方效果破坏；③战斗阶段结束时自身回手牌，再从手牌特殊召唤1只4星以下的「半龙女仆」怪兽，并设置各自发动条件与次数限制。
function s.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。「半龙女仆·星夜龙女」以外的自己的墓地·除外状态的1只「半龙女仆」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的龙族融合怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	-- 设定该效果的Value为aux.indoval，即只有对方玩家发动的效果（rp为对方）才会被免疫，从而实现“自己场上的龙族融合怪兽不会被对方的效果破坏”。
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ③：自己·对方的战斗阶段结束时才能发动。这张卡回到手卡，从手卡把1只4星以下的「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- ①效果的代价函数：chk==0时检查该卡是否可丢弃；可丢弃时将该卡以代价+丢弃原因送去墓地。
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 实际执行代价：将发动效果的那张卡（e:GetHandler()）以“代价丢弃”的原因从手卡送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义①可特殊召唤的怪兽条件：表侧表示、不是「半龙女仆·星夜龙女」、字段为「半龙女仆」、能够特殊召唤（满足苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x133) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：自己怪兽区存在空格，并且自己墓地·除外区存在至少1只符合条件的「半龙女仆」怪兽。
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方怪兽区是否有空位，作为发动①效果的前提之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地·除外区是否有至少1只满足s.spfilter的「半龙女仆」怪兽存在，若没有则不能发动。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 登记操作为特殊召唤：处理时将特殊召唤1只来自自己墓地/除外区的怪兽（具体对象处理时选择），供连锁和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ①效果处理：若怪兽区无空位则直接结束；否则提示选择，从自己墓地/除外区选取1张满足条件且不受王家长眠之谷影响的目标，将其表侧表示特殊召唤。
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认己方怪兽区有可用空位，否则不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示，将选择消息存入缓存供Duel.SelectMatchingCard使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地·除外区中选择1张满足spfilter且不受王家长眠之谷影响的「半龙女仆」怪兽（同时排除自身e:GetHandler()），作为特殊召唤目标。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler(),e,tp)
	if g:GetCount()>0 then
		-- 将选择的目标怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果的保护目标：场上的龙族·融合怪兽（同时满足种族龙族和类型融合）获得该抗性。
function s.indtg(e,c)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION)
end
-- 定义③可特殊召唤的怪兽条件：属于「半龙女仆」字段、等级4以下、能够特殊召唤，且是从手牌出场。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动条件判定：自身可以返回手牌，自身离开后怪兽区仍有空位，并且手牌中存在至少1只符合条件的「半龙女仆」怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身是否能返回手牌，以及用Duel.GetMZoneCount(tp,c)判断在自身离开后己方怪兽区是否有空位。
	if chk==0 then return c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0
		-- 检查手牌中是否存在至少1只满足s.spfilter2的「半龙女仆」怪兽，作为③特召部分的前提。
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作为回手牌：将自身（c）返回手牌，用于连锁和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 登记操作为特殊召唤：处理时将从手牌特殊召唤1只「半龙女仆」怪兽（对象处理时选择），供连锁和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果处理：若自身仍与效果关联，则将其返回手牌；返回成功且自身确实在手牌、怪兽区有空位时，从手牌选择1只符合条件的「半龙女仆」怪兽表侧表示特殊召唤。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关（未被无效或离场），并执行将自身返回手牌的操作；返回手牌成功（返回数量非0）则继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 确认自身返回后位于手牌，且己方怪兽区存在可用空位，满足这两个条件才执行后续的特召操作。
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出“请选择要特殊召唤的卡”的选择提示，将选择消息存入缓存供Duel.SelectMatchingCard使用。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己手牌中选择1只满足s.spfilter2的「半龙女仆」怪兽作为特殊召唤目标。
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的目标怪兽以表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
