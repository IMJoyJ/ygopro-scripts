--R.B.ラムダブレード
-- 效果：
-- 这张卡召唤·特殊召唤的场合：可以从卡组把「奏悦机组 λ羔羊刃」以外的1张「奏悦机组」卡送去墓地。
-- 对方主要阶段，这张卡在「奏悦机组」连接怪兽所连接区存在的场合（诱发即时效果）：可以支付1400基本分，以对方场上1只怪兽为对象；这张卡破坏，得到作为对象的怪兽的控制权。这个效果得到控制权的怪兽在结束阶段破坏。
-- 「奏悦机组 λ羔羊刃」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化效果函数，创建并注册三个效果：召唤时送去墓地效果、特殊召唤时送去墓地效果、对方主要阶段时改变控制权效果
function s.initial_effect(c)
	-- 召唤·特殊召唤成功时发动的效果，从卡组将「奏悦机组」以外的1张卡送去墓地
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
	-- 对方主要阶段，这张卡在「奏悦机组」连接怪兽所连接区存在时发动的效果，支付1400基本分改变对方场上怪兽控制权并使其在结束阶段破坏
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
-- 过滤函数，用于检索满足条件的「奏悦机组」卡（非同名卡且可送去墓地）
function s.tgfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1cf) and c:IsAbleToGrave()
end
-- 效果处理前的检查函数，判断是否满足发动条件（卡组是否存在符合条件的卡）
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件（卡组是否存在符合条件的卡）
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，提示将要从卡组送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，选择并把符合条件的卡送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡组卡片
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于检索场上满足条件的「奏悦机组」连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- 诱发即时效果的发动条件判断函数，判断是否在对方主要阶段且自身处于连接怪兽所连接区
function s.clcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否在对方主要阶段且不是当前回合玩家
	if not Duel.IsMainPhase() or Duel.GetTurnPlayer()==tp then return false end
	-- 获取场上所有满足条件的「奏悦机组」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历所有连接怪兽并合并其链接区域
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	-- 判断自身是否在连接怪兽的链接区域内且为对方回合
	return lg2 and lg2:IsContains(e:GetHandler()) and Duel.GetTurnPlayer()==1-tp
end
-- 支付LP的费用处理函数，检查并支付1400基本分
function s.clcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能支付1400基本分
	if chk==0 then return Duel.CheckLPCost(tp,1400) end
	-- 支付1400基本分
	Duel.PayLPCost(tp,1400)
end
-- 选择目标怪兽的处理函数，设置目标为对方场上可改变控制权的怪兽
function s.cltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and chkc:IsControlerCanBeChanged() end
	-- 判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil,true)
		-- 判断是否有足够的怪兽区域来获得控制权
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil,true)
	-- 设置操作信息，提示将要破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置操作信息，提示将要改变目标怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理函数，破坏自身并获得目标怪兽控制权，并注册结束阶段破坏效果
function s.clop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断自身是否在连锁中且成功破坏
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)~=0
		-- 判断目标怪兽是否在连锁中且为怪兽类型并成功获得控制权
		and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.GetControl(tc,tp)~=0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 创建并注册结束阶段破坏效果，用于在结束阶段破坏获得控制权的怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.descon)
		-- 设置效果操作为通用的结束阶段破坏函数
		e1:SetOperation(aux.EPDestroyOperation)
		-- 将效果注册到玩家环境中
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否需要触发结束阶段破坏效果的条件函数
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
