--堕天使テスカトリポカ
-- 效果：
-- 自己对「堕天使 特斯卡特利波卡」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：自己场上的「堕天使」怪兽被战斗·效果破坏的场合，可以作为代替把手卡的这张卡丢弃。
-- ②：支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡的效果适用。那之后，墓地的那张卡回到卡组。这个效果在对方回合也能发动。
function c88234365.initial_effect(c)
	c:SetSPSummonOnce(88234365)
	-- ①：自己场上的「堕天使」怪兽被战斗·效果破坏的场合，可以作为代替把手卡的这张卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c88234365.reptg)
	e1:SetValue(c88234365.repval)
	e1:SetOperation(c88234365.repop)
	c:RegisterEffect(e1)
	-- ②：支付1000基本分，以自己墓地1张「堕天使」魔法·陷阱卡为对象才能发动。那张魔法·陷阱卡的效果适用。那之后，墓地的那张卡回到卡组。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88234365,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,88234365)
	e2:SetCost(c88234365.cpcost)
	e2:SetTarget(c88234365.cptg)
	e2:SetOperation(c88234365.cpop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上因战斗或效果而被破坏的表侧表示「堕天使」怪兽
function c88234365.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xef) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标检查，确认手牌中的这张卡可以丢弃，且场上有符合条件的「堕天使」怪兽正要被破坏
function c88234365.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c88234365.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏效果所适用的对象怪兽
function c88234365.repval(e,c)
	return c88234365.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的实际处理，将手牌中的这张卡丢弃
function c88234365.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将手牌中的这张卡作为效果丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD)
end
-- 复制效果的Cost处理，检查并支付1000点基本分
function c88234365.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1000点基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000点基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤自己墓地中可以回到卡组且可以适用发动效果的「堕天使」魔法·陷阱卡
function c88234365.cpfilter(c)
	return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck() and c:CheckActivateEffect(false,true,false)~=nil
end
-- 复制效果的发动准备，选择墓地的目标魔陷，并复制其发动效果（Target）和操作信息
function c88234365.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检查自己墓地是否存在符合条件的「堕天使」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c88234365.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地的一张「堕天使」魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c88234365.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除当前连锁的对象，因为复制效果本身不直接将该卡作为对象处理
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，防止被其他卡片响应
	Duel.ClearOperationInfo(0)
	-- 设置当前连锁的操作信息为“将目标卡片回到卡组”
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 复制效果的实际处理，适用目标魔陷的效果，然后将该魔陷回到卡组
function c88234365.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	if not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	-- 中断当前效果处理，使后续的“回到卡组”与之前的“效果适用”不视为同时处理
	Duel.BreakEffect()
	-- 将作为对象的那张墓地的魔法·陷阱卡回到持有者卡组并洗牌
	Duel.SendtoDeck(te:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
