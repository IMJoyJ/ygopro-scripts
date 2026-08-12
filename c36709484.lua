--予幻なき日々のまぼろし
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「神艺」、「终刻」、「耀圣」卡的其中任意种存在的场合才能发动。从手卡·卡组把1只「无垢者 米底乌斯」特殊召唤。在那次特殊召唤成功时对方不能把卡的效果发动。
-- ②：把墓地的这张卡除外，以自己墓地1只融合·同调·超量怪兽为对象才能发动。那只怪兽在作为连接怪兽所连接区的自己场上特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：注册①效果（魔陷卡片发动、特召「无垢者 米底乌斯」且让对方不能发动卡的效果）与②效果（墓地起动除外自身，将融合·同调·超量怪兽特召到连接怪兽连接区）。
function s.initial_effect(c)
	-- 登记此卡效果文本中记载了「无垢者 米底乌斯」的卡名。
	aux.AddCodeList(c,97556336)
	-- ①：自己场上有「神艺」、「终刻」、「耀圣」卡的其中任意种存在的场合才能发动。从手卡·卡组把1只「无垢者 米底乌斯」特殊召唤。在那次特殊召唤成功时对方不能把卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只融合·同调·超量怪兽为对象才能发动。那只怪兽在作为连接怪兽所连接区的自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置发动代价：将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「神艺」、「终刻」、「耀圣」卡。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cd,0x1d2,0x1d8)
end
-- ①效果的发动条件：自己场上存在表侧表示的「神艺」、「终刻」或「耀圣」卡。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在符合条件表侧表示的「神艺」、「终刻」、「耀圣」卡片。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：符合特殊召唤条件的「无垢者 米底乌斯」。
function s.spfilter(c,e,tp)
	return c:IsCode(97556336) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标：检查主要怪兽区是否有空位以及手牌或卡组是否存在符合条件的「无垢者 米底乌斯」，并设置特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，确认己方主要怪兽区域有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检测时，检查手牌或卡组中是否存在可以特殊召唤的「无垢者 米底乌斯」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：效果处理时将手牌或卡组的1只怪兽特殊召唤到己方场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ①效果的处理：从手卡·卡组把1只「无垢者 米底乌斯」特殊召唤，且若在连锁1发动，特殊召唤成功时对方玩家不能发动任何卡的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果己方场上怪兽区没有多余空位，则效果不予处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌或卡组选择1张「无垢者 米底乌斯」。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 若当前连锁序号为1，则在连锁终点时注册限制对方效果发动的时点锁效果。
		if Duel.GetCurrentChain()==1 then
			-- ②效果的发动目标与处理：在自己场上有可用连接区的前提下，选择自己墓地的一只融合、同调或超量怪兽，将其在连接怪兽指向的区域特殊召唤；若在连锁1特召成功，使对方不能发动任何效果。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_END)
			e2:SetOperation(s.limitop)
			e2:SetCountLimit(1)
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 将此限制对方发动卡片效果的效果注册到全局环境中。
			Duel.RegisterEffect(e2,tp)
		end
		-- 将选中的「无垢者 米底乌斯」以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制效果的处理：在连锁结束时设置连锁限制，使对方玩家无法响应己方发动的卡片效果。
function s.limitop(e,tp,eg,ep,ev,re,r,rp)
	-- 直到连锁结束前，锁住玩家卡片效果的响应权限。
	Duel.SetChainLimitTillChainEnd(s.efun)
end
-- 限制响应的判定条件：仅允许与发起方玩家相同的一方发起连锁响应。
function s.efun(e,ep,tp)
	return ep==tp
end
-- 过滤条件：自己墓地中可以特殊召唤到指定指向区域的融合、同调或超量怪兽。
function s.spfilter2(c,e,tp,zone)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ②效果的发动目标：获取玩家可用的连接区域，在满足条件时让玩家选择墓地中符合条件的怪兽作为对象，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取以自己来看的所有被指向的可用怪兽区域的标志值。
	local zone=Duel.GetLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp,zone) end
	-- 在发动检测时，确认存在可用被指向区域且怪兽区有空位。
	if chk==0 then return zone~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检测时，检查自己墓地是否存在可以特殊召唤到该指向区域的融合、同调或超量怪兽。
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地中1只符合条件的融合、同调或超量怪兽作为对象。
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
	-- 设置操作信息：效果处理时将该对象怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：将选中的对象怪兽在自己场上被指向的怪兽区域特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取以自己来看的所有被指向区域的标志值。
	local zone=Duel.GetLinkedZone(tp)
	-- 获取当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查可用被指向区域依然存在，且对象怪兽与此连锁相关，并且不受王家长眠之谷效果影响。
	if zone~=0 and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将目标怪兽表侧表示特殊召唤到指定的被指向区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
