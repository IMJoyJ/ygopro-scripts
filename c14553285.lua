--アーカナイト・マジシャン／バスター
-- 效果：
-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。这张卡特殊召唤成功时，给这张卡放置2个魔力指示物。这张卡放置的魔力指示物每有1个，这张卡的攻击力上升1000。可以把这张卡放置的2个魔力指示物取除，对方场上存在的卡全部破坏。此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「奥金魔导师」特殊召唤。
function c14553285.initial_effect(c)
	-- 记录当前卡片与另一张卡（通常为基础形态或关联组）的代码关系，用于后续效果判定。
	aux.AddCodeList(c,80280737)
	c:EnableReviveLimit()
	c:EnableCounterPermit(0x1)
	-- "这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。"
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定函数，用于检查是否为「爆裂模式」效果或卡片本身。
	e1:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e1)
	-- "这张卡特殊召唤成功时，给这张卡放置2个魔力指示物。"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14553285,0))  --"放置魔力指示物"
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c14553285.addct)
	e2:SetOperation(c14553285.addc)
	c:RegisterEffect(e2)
	-- "这张卡的攻击力上升1000"（实际为每有1个指示物攻击上升1000）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c14553285.attackup)
	c:RegisterEffect(e3)
	-- "可以把这张卡放置的2个魔力指示物取除，对方场上存在的卡全部破坏。"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(14553285,1))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c14553285.descost)
	e4:SetTarget(c14553285.destg)
	e4:SetOperation(c14553285.desop)
	c:RegisterEffect(e4)
	-- "此外，场上存在的这张卡被破坏时，可以把自己墓地存在的1只「奥金魔导师」特殊召唤。"
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(14553285,2))  --"特殊召唤"
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c14553285.spcon)
	e5:SetTarget(c14553285.sptg)
	e5:SetOperation(c14553285.spop)
	c:RegisterEffect(e5)
end
c14553285.assault_name=31924889
c14553285.mentioned_counter={
	[0x1]=true,
}
-- 定义效果处理的目标函数（Target），用于确定操作信息中的目标数量等参数。
function c14553285.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定类别为指示物（CATEGORY_COUNTER），数量为2个。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,2,0,0x1)
end
-- 执行操作，将魔力指示物添加到特殊召唤成功的卡片上。
function c14553285.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 计算攻击力上升值，返回当前魔力指示物数量乘以1000的结果。
function c14553285.attackup(e,c)
	return c:GetCounter(0x1)*1000
end
-- 检查并执行发动效果所需的代价，移除指定数量的魔力指示物。
function c14553285.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,2,REASON_COST)
end
-- 定义效果处理的目标函数（Target），用于确定破坏效果的潜在目标范围及操作信息参数。
function c14553285.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少一张卡片，作为破坏效果的目标判定条件。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有存在的卡片组，存储到变量g中以便后续使用。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息，指定类别为破坏（CATEGORY_DESTROY），目标数量为场上存在的卡片总数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义效果的执行函数（Operation），用于实际处理效果逻辑。
function c14553285.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次获取对方场上所有存在的卡片组，确保在执行阶段有正确的对象引用。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 以效果原因实际销毁之前确定的对方场上的所有卡片。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 检查触发条件，确认卡片之前位于场上（而非直接来自墓地或额外怪兽区等）。
function c14553285.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，检查墓地中的卡片是否为「奥金魔导师」且能被当前效果特殊召唤。
function c14553285.spfilter(c,e,tp)
	return c:IsCode(31924889) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的发动目标函数（Target），用于确定特殊召唤的目标及可用区域条件。
function c14553285.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14553285.spfilter(chkc,e,tp) end
	-- 检查当前玩家场上是否至少有一个主要怪兽区可用以放置特殊召唤的卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在至少一张满足过滤条件的卡片作为潜在的特殊召唤对象。
		and Duel.IsExistingTarget(c14553285.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示消息，指示需要选择一张卡片进行特殊召唤（HINT_SELECTMSG）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地中选择一张符合条件的「奥金魔导师」作为特殊召唤的目标卡。
	local g=Duel.SelectTarget(tp,c14553285.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，指定类别为特殊召唤（CATEGORY_SPECIAL_SUMMON），目标数量为选定的卡片数。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义效果的执行函数（Operation），用于实际处理效果逻辑。
function c14553285.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家之前选择的第一张目标卡片，用于后续特殊召唤调用。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以通常方式（sumtype=0）将目标卡片特殊召唤到玩家场上，表侧攻击表示。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
