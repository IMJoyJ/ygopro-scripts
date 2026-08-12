--R.B.ラムダブレード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「反叛曲机器人拉牧达剑」以外的1张「反叛曲机器人」卡送去墓地。
-- ②：对方主要阶段，这张卡是和「反叛曲机器人」连接怪兽连接状态的场合，支付1400基本分，以对方场上1只怪兽为对象才能发动。这张卡破坏，得到那只怪兽的控制权。这个效果得到控制权的怪兽在结束阶段破坏。
local s,id,o=GetID()
-- 注册这张卡的三个效果：①召唤·特殊召唤成功的场合触发，从卡组把「反叛曲机器人」卡送去墓地（1回合1次）；②对方主要阶段可发动的二速诱发即时效果，以对方场上1只怪兽为对象，自身破坏并得到其控制权（1回合1次）
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「反叛曲机器人拉牧达剑」以外的1张「反叛曲机器人」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方主要阶段，这张卡是和「反叛曲机器人」连接怪兽连接状态的场合，支付1400基本分，以对方场上1只怪兽为对象才能发动。这张卡破坏，得到那只怪兽的控制权。这个效果得到控制权的怪兽在结束阶段破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"控制权"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.clcon)
	e3:SetCost(s.clcost)
	e3:SetTarget(s.cltg)
	e3:SetOperation(s.clop)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选自身以外、属于「反叛曲机器人」系列（0x1cf）且可以送去墓地的卡
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1cf) and c:IsAbleToGrave()
end
-- ①效果的对象判定：确认卡组中存在可送去墓地的「反叛曲机器人」卡，并登记送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：检查自己卡组中是否存在至少1张满足条件（「反叛曲机器人」卡且可送去墓地）的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预告将从卡组把1张卡送去墓地（处理时才确定具体卡片，故targets为nil）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：提示玩家选择，从卡组选1张符合条件的「反叛曲机器人」卡，将其以效果送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择提示：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己卡组选择1张满足条件的「反叛曲机器人」卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果原因送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数：筛选表侧表示、属于「反叛曲机器人」系列（0x1cf）的连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- ②效果的发动条件判定：当前须为对方的主要阶段，且这张卡处于与「反叛曲机器人」连接怪兽连接的状态
function s.clcon(e,tp,eg,ep,ev,re,r,rp)
	-- 时点判定：不是主要阶段，或者是自己的回合时，不能发动
	if not Duel.IsMainPhase() or Duel.GetTurnPlayer()==tp then return false end
	-- 取得双方怪兽区域所有表侧表示的「反叛曲机器人」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历每一只「反叛曲机器人」连接怪兽
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	-- 条件成立：这张卡包含在某只「反叛曲机器人」连接怪兽的连接端（即处于连接状态），且当前是对方回合
	return lg2 and lg2:IsContains(e:GetHandler()) and Duel.GetTurnPlayer()==1-tp
end
-- ②效果的发动代价：确认并支付1400基本分
function s.clcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认玩家能否支付1400基本分
	if chk==0 then return Duel.CheckLPCost(tp,1400) end
	-- 让玩家支付1400基本分作为发动代价
	Duel.PayLPCost(tp,1400)
end
-- ②效果的对象判定：对象为对方怪兽区域控制权可以变更的怪兽
function s.cltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and chkc:IsControlerCanBeChanged() end
	-- 发动条件判定：确认对方场上存在至少1只控制权可以变更、能成为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil,true)
		-- 并且这张卡离开后自己场上仍有可用的主要怪兽区域（用于安置得到控制权的怪兽）
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 end
	-- 向玩家发送选择提示：请选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家以对方场上1只控制权可以变更的怪兽为对象
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil,true)
	-- 设置操作信息：预告将破坏这张卡自身（1张）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置操作信息：预告将得到对象怪兽（1张）的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ②效果的处理：这张卡自身以效果破坏，成功后得到对象怪兽的控制权；并给该怪兽登记标记，注册一个在结束阶段将其破坏的延迟效果
function s.clop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若这张卡仍与连锁关联，则以效果破坏这张卡自身
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)~=0
		-- 若对象怪兽仍与连锁关联且为怪兽卡，则让自己得到那只怪兽的控制权
		and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.GetControl(tc,tp)~=0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 这个效果得到控制权的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.descon)
		-- 效果处理：在结束阶段把保存的对象怪兽用效果破坏送去墓地
		e1:SetOperation(aux.EPDestroyOperation)
		-- 把该结束阶段破坏效果注册为玩家的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段破坏的条件判定：若对象怪兽仍带有本卡登记的标记则执行破坏，否则注销这个效果
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
