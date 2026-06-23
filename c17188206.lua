--R.B. Lambda Blade
-- 效果：
-- 这张卡召唤·特殊召唤的场合：可以从卡组把「奏悦机组 λ羔羊刃」以外的1张「奏悦机组」卡送去墓地。
-- 对方主要阶段，这张卡在「奏悦机组」连接怪兽所连接区存在的场合（诱发即时效果）：可以支付1400基本分，以对方场上1只怪兽为对象；这张卡破坏，得到作为对象的怪兽的控制权。这个效果得到控制权的怪兽在结束阶段破坏。
-- 「奏悦机组 λ羔羊刃」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 创建并注册两个触发效果，分别对应通常召唤和特殊召唤时的效果
function s.initial_effect(c)
	-- 这张卡召唤·特殊召唤的场合：可以从卡组把「奏悦机组 λ羔羊刃」以外的1张「奏悦机组」卡送去墓地。
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
	-- 对方主要阶段，这张卡在「奏悦机组」连接怪兽所连接区存在的场合（诱发即时效果）：可以支付1400基本分，以对方场上1只怪兽为对象；这张卡破坏，得到作为对象的怪兽的控制权。这个效果得到控制权的怪兽在结束阶段破坏。
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
-- 设置效果处理时的提示信息，表示将要从卡组送去墓地1张卡
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：卡组中是否存在至少1张符合条件的「奏悦机组」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要处理的卡为1张卡，位置为卡组
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的执行函数，提示玩家选择并送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤函数，用于检索满足条件的「奏悦机组」连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- 判断效果发动条件：当前为对方主要阶段且该卡在连接怪兽所连接区
function s.clcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方主要阶段且当前回合玩家为发动者
	if not Duel.IsMainPhase() or Duel.GetTurnPlayer()==tp then return false end
	-- 获取场上所有满足条件的「奏悦机组」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历所有连接怪兽，获取其连接区的卡
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	-- 判断该卡是否在连接怪兽的连接区中
	return lg2 and lg2:IsContains(e:GetHandler()) and Duel.GetTurnPlayer()==1-tp
end
-- 支付1400基本分的处理函数
function s.clcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1400基本分
	if chk==0 then return Duel.CheckLPCost(tp,1400) end
	-- 支付1400基本分
	Duel.PayLPCost(tp,1400)
end
-- 设置效果目标选择函数，用于选择对方场上的怪兽
function s.cltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and chkc:IsControlerCanBeChanged() end
	-- 检查是否满足条件：对方场上是否存在至少1只可改变控制权的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil,true)
		-- 检查是否满足条件：己方怪兽区是否至少有1个空位
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0 end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只可改变控制权的怪兽
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil,true)
	-- 设置连锁操作信息，表示将要破坏该卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置连锁操作信息，表示将要改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 处理效果的执行函数，破坏自身并获得目标怪兽控制权
function s.clop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断自身是否在连锁中且能被破坏
	if c:IsRelateToChain() and Duel.Destroy(c,REASON_EFFECT)~=0
		-- 判断目标怪兽是否在连锁中且为怪兽类型且能获得控制权
		and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.GetControl(tc,tp)~=0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 创建一个在结束阶段破坏目标怪兽的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.descon)
		-- 设置效果的执行函数为辅助销毁操作函数
		e1:SetOperation(aux.EPDestroyOperation)
		-- 将该效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断是否在结束阶段需要破坏目标怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end
