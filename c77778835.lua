--ヒステリック・パーティー
-- 效果：
-- ①：丢弃1张手卡才能把这张卡发动。从自己墓地把「鹰身女郎」尽可能特殊召唤。这张卡从场上离开时这个效果特殊召唤的怪兽全部破坏。
function c77778835.initial_effect(c)
	-- ①：丢弃1张手卡才能把这张卡发动。从自己墓地把「鹰身女郎」尽可能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c77778835.cost)
	e1:SetTarget(c77778835.target)
	e1:SetOperation(c77778835.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时这个效果特殊召唤的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c77778835.checkop)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时这个效果特殊召唤的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c77778835.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 检查手卡并丢弃1张手卡作为发动的代价
function c77778835.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己手卡中是否存在至少1张可以丢弃的卡（排除这张卡自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤墓地中卡名为「鹰身女郎」（卡号76812113）且可以特殊召唤的怪兽
function c77778835.filter(c,e,tp)
	return c:IsCode(76812113) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查自己场上是否有空怪兽区域以及墓地中是否有可以特殊召唤的「鹰身女郎」，并设置特殊召唤的操作信息
function c77778835.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己墓地是否存在至少1只可以特殊召唤的「鹰身女郎」
		and Duel.IsExistingMatchingCard(c77778835.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁中的操作信息，表明此效果包含从墓地特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行效果处理：从自己墓地选择尽可能多的「鹰身女郎」特殊召唤，并让这张卡成为这些怪兽的关联对象
function c77778835.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己墓地中所有可以特殊召唤的「鹰身女郎」怪兽组
	local tg=Duel.GetMatchingGroup(c77778835.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家发送选择特殊召唤怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=tg:Select(tp,ft,ft,nil)
	local tc=g:GetFirst()
	while tc do
		-- 将选中的怪兽以表侧表示逐步特殊召唤到场上，并与这张卡建立对象关联
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		c:SetCardTarget(tc)
		tc=g:GetNext()
	end
	-- 完成所有怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
end
-- 过滤出当前场上被这张卡作为效果对象（关联）的怪兽
function c77778835.desfilter(c,rc)
	return rc:IsHasCardTarget(c)
end
-- 在卡片即将离场时，检查其是否处于效果被无效的状态，并将结果记录在Label中
function c77778835.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 在卡片离场后，若此前未被无效，则获取并破坏所有由该效果特殊召唤的怪兽
function c77778835.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	-- 获取双方场上所有被这张卡作为效果对象（关联）的怪兽
	local g=Duel.GetMatchingGroup(c77778835.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	-- 因效果将这些怪兽全部破坏
	Duel.Destroy(g,REASON_EFFECT)
end
