--ダブル・フッキング
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃1张手卡，以自己墓地最多2只怪兽为对象才能把这张卡发动。那些怪兽特殊召唤。作为对象的怪兽从场上离开时这张卡破坏。这张卡从场上离开时作为对象的怪兽破坏。
local s,id,o=GetID()
-- 初始化函数，注册卡片的发动效果、自身离场时破坏对象的效果、以及对象离场时破坏自身的效果。
function s.initial_effect(c)
	-- ①：丢弃1张手卡，以自己墓地最多2只怪兽为对象才能把这张卡发动。那些怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时作为对象的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(s.checkop)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时作为对象的怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 作为对象的怪兽从场上离开时这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.descon2)
	e4:SetOperation(s.desop2)
	c:RegisterEffect(e4)
end
-- 定义发动的代价（Cost），要求丢弃1张手卡。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的、可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡作为发动的代价。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，筛选墓地中可以特殊召唤的怪兽。
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义发动的目标（Target），处理取对象及特殊召唤的合法性检测。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 获取当前玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查怪兽区域是否有空位，且自己墓地是否存在至少1只可以特殊召唤的怪兽。
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	ft=math.min(ft,2)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地最多2只（且不超过可用怪兽区域数）可以特殊召唤的怪兽作为对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置当前连锁的操作信息，声明此效果包含特殊召唤选定卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
-- 定义效果处理（Operation），执行将作为对象的怪兽特殊召唤并建立对象连接关系。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次获取当前玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取在连锁处理时仍然与该效果存在对象关联的卡片集合。
	local sg=Duel.GetTargetsRelateToChain()
	if #sg==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if #sg>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if #sg>ft then
		-- 向玩家发送提示信息，提示选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	local c=e:GetHandler()
	-- 遍历所有符合条件的、要特殊召唤的目标怪兽。
	for tc in aux.Next(sg) do
		-- 尝试将目标怪兽以表侧表示特殊召唤（分步特殊召唤处理）。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			c:SetCardTarget(tc)
		end
	end
	-- 完成所有分步特殊召唤的怪兽的特殊召唤处理。
	Duel.SpecialSummonComplete()
end
-- 在自身离场前，检查自身是否处于效果被无效的状态，并用Label记录。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 自身离场时，若未被无效，则将作为对象的怪兽全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tg=e:GetHandler():GetCardTarget()
	-- 遍历所有作为对象的卡，并检查它们是否仍在怪兽区域。
	for tc in aux.Next(tg) do if tc:IsLocation(LOCATION_MZONE) then
		-- 因效果将作为对象的怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end end
end
-- 检查离场的卡片中是否包含作为该卡对象的怪兽，作为自身破坏效果的触发条件。
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()
	-- 检查离场的卡片集合中，是否至少有一张是该卡的对象。
	return eg:FilterCount(aux.TRUE,g)~=#eg
end
-- 作为对象的怪兽离场时，执行破坏这张卡的操作。
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将这张卡自身破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
