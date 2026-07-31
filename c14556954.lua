--豪回遊鯨 VIPホエール
-- 效果：
-- 这张卡表侧表示上级召唤的场合，可以额外解放任意数量怪兽。
-- 这张卡上级召唤的场合：可以给这张卡放置为这张卡的上级召唤而解放的怪兽数量的贵宾指示物。
-- 对方把效果发动时（诱发即时效果）：可以把这张卡1个贵宾指示物取除；进行1次投掷硬币，对里表作猜测。猜中的场合，那个效果无效。猜错的场合，这张卡的原本攻击力直到回合结束时变成一半。
local s,id,o=GetID()
-- 初始化卡的所有效果对象，包括召唤规则、素材检查、指示物放置和硬币反击效果的创建与注册。
function s.initial_effect(c)
	c:EnableCounterPermit(0x75)
	-- 这张卡表侧表示上级召唤的场合，可以额外解放任意数量怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"解放任意数量怪兽召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.sumcon)
	e1:SetOperation(s.sumop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 定义效果对象 e2，用于检查上级召唤时解放的素材数量并存储到标签中。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	c:RegisterEffect(e2)
	-- 定义效果对象 e3，在通常召唤成功时为怪兽添加对应数量的计数器指示物（放置指示物）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"放置指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.addcon)
	e3:SetTarget(s.addtg)
	e3:SetOperation(s.addc)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 定义效果对象 e4，对方发动连锁时作为诱发即时效果的触发器进行硬币投掷和效果无效或攻击力减半处理。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"投掷硬币"
	e4:SetCategory(CATEGORY_COIN+CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.discon)
	e4:SetCost(s.discost)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
s.mentioned_counter={
	[0x75]=true,
}
-- 定义 s.sumcon 函数，用于检查怪兽等级是否大于等于 5 且场上存在足够数量的祭品以支持召唤规则。
function s.sumcon(e,c,minc)
	if c==nil then return true end
	local min=1
	if minc>=1 then min=minc end
	local tp=c:GetControler()
	-- 在 s.sumcon 条件检查中获取场上所有怪兽组，用于后续判断祭品数量。
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 返回布尔值，表示怪兽等级是否满足要求且场上存在足够祭品。
	return c:IsLevelAbove(5) and Duel.CheckTribute(c,min,12,mg)
end
-- 定义 s.sumop 函数，用于在召唤规则处理时选择并解放指定数量的怪兽作为素材。
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc)
	local min=1
	if minc>=1 then min=minc end
	-- 在 s.sumop 操作处理中再次确认候选范围（通常召唤素材）。
	local mg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家从候选怪兽中选择 min-max 个祭品，并设置到素材中。
	local sg=Duel.SelectTribute(tp,c,min,12,mg)
	c:SetMaterial(sg)
	-- 以召唤或素材原因解放选定的怪兽组。
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 定义 s.valcheck 函数，获取素材并设置标签值为素材数量（用于后续添加计数器）。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	e:SetLabel(g:GetCount())
end
-- 定义 s.addcon 函数，检查是否通过上级召唤成功以决定是否发动放置指示物效果。
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 定义 s.addtg 函数（目标选择），并设置操作信息以添加计数器指示物。
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():GetLabel()>0 end
	-- 设置操作信息，指定后续将向怪兽区添加一个计数器指示物。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,0,tp,1)
end
-- 定义 s.addc 函数，在满足条件时给怪兽添加对应数量的计数器指示物（放置指示物）。
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToChain() and e:GetHandler():IsFaceup() then
		e:GetHandler():AddCounter(0x75,e:GetLabelObject():GetLabel())
	end
end
-- 定义 s.discon 函数，检查是否为对方连锁且效果可被无效以决定是否发动硬币反击。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回布尔值表示是否满足发动条件（对手连锁且可被无效）。
	return ep~=tp and Duel.IsChainDisablable(ev)
end
-- 定义 s.discost 函数，检查并消耗一个计数器指示物作为代价。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x75,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x75,1,REASON_COST)
end
-- 定义 s.distg 函数（目标选择），并设置操作信息以进行硬币投掷。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定后续将进行一次硬币投掷。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,ep,1)
end
-- 定义 s.disop 函数，执行效果处理：进行硬币投掷并根据结果决定是否无效效果或减半攻击力。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家显示提示消息，询问选择硬币的正反面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言选择的硬币面（正面或反面）。
	local coin=Duel.AnnounceCoin(tp)
	-- 执行一次实际的硬币投掷，返回投掷结果。
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 如果猜中则使发动的效果无效。
		Duel.NegateEffect(ev)
	elseif c:IsRelateToChain() and c:IsFaceupEx() then
		local batk=c:GetBaseAttack()
		-- 定义临时效果对象 e1（在 s.disop 内部），用于设置怪兽的原本攻击力为原来的一半直到回合结束。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(math.ceil(batk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
