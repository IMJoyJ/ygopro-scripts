--ヒステリック・パーティー
-- 效果：
-- ①：丢弃1张手卡才能把这张卡发动。从自己墓地把「鹰身女郎」尽可能特殊召唤。这张卡从场上离开时这个效果特殊召唤的怪兽全部破坏。
function c77778835.initial_effect(c)
	-- 记录这张卡的卡文上记载了「鹰身女郎」的卡名。
	aux.AddCodeList(c,76812113)
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
-- 卡片发动的代价处理函数：检查并从自己手卡选择1张可丢弃的其他手卡丢弃。
function c77778835.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价可行性检测：检查自己手卡是否存在至少1张除这张卡以外可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家从自己手卡中选择1张可丢弃的卡并作为发动代价丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：判断怪兽是否为「鹰身女郎」且能被特殊召唤。
function c77778835.filter(c,e,tp)
	return c:IsCode(76812113) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡片发动的目标处理函数（可行性检测部分）：检查自己怪兽区有空位且墓地存在可特殊召唤的「鹰身女郎」。
function c77778835.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可行性检测：检查自己怪兽区域是否至少有1个可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查自己墓地中是否存在至少1只可特殊召唤的「鹰身女郎」。
		and Duel.IsExistingMatchingCard(c77778835.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：预计从自己墓地特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 卡片发动的效果处理函数：结合自己怪兽区可用空格和「青眼精灵龙」限制，从自己墓地尽可能选择「鹰身女郎」特殊召唤并建立永续对象联系。
function c77778835.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上当前可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己墓地中所有可特殊召唤的「鹰身女郎」卡片组。
	local tg=Duel.GetMatchingGroup(c77778835.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向自己发送选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=tg:Select(tp,ft,ft,nil)
	local tc=g:GetFirst()
	while tc do
		-- 执行单只「鹰身女郎」的分步特殊召唤，以表侧表示出场。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		c:SetCardTarget(tc)
		tc=g:GetNext()
	end
	-- 完成所有分步特殊召唤流程并统一触发召唤相关时点。
	Duel.SpecialSummonComplete()
end
-- 过滤函数：判断场上的怪兽是否与这张卡保持着永续对象联系。
function c77778835.desfilter(c,rc)
	return rc:IsHasCardTarget(c)
end
-- 离场前状态检查函数：在卡片离场前检测自身效果是否处于无效状态，并将结果存入Label。
function c77778835.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 离场破坏处理函数：若这张卡离场前未处于无效状态，则获取所有与之维持永续对象联系的怪兽并破坏。
function c77778835.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	-- 获取双方怪兽区域中所有仍以这张卡为永续对象来源的怪兽卡片组。
	local g=Duel.GetMatchingGroup(c77778835.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	-- 将获取到的所有特召怪兽以效果破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
