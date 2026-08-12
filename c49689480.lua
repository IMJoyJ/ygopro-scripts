--クイーンマドルチェ・ティアラフレース
-- 效果：
-- 5星「魔偶甜点」怪兽×3
-- 「魔偶甜点后·后冠草莓提拉米苏」1回合1次也能在自己场上的「魔偶甜点后·后冠提拉米苏」上面重叠来超量召唤。
-- ①：对方回合1次，把这张卡1个超量素材取除，以自己墓地最多2张「魔偶甜点」卡为对象才能发动。那些卡回到卡组，让最多有回去数量的对方场上的卡回到卡组。
-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到额外卡组。
local s,id,o=GetID()
-- 初始化效果函数，注册超量召唤手续和两个效果
function s.initial_effect(c)
	-- 记录该卡与「魔偶甜点后·后冠提拉米苏」的关联
	aux.AddCodeList(c,37164373)
	aux.AddXyzProcedure(c,s.mfilter,5,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"是否在自己场上的「魔偶甜点后·后冠提拉米苏」上面重叠？"
	c:EnableReviveLimit()
	-- 注册效果①，对方回合可发动，将墓地「魔偶甜点」卡送回卡组并让对方场上等量卡送回卡组
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.tdcon)
	e1:SetCost(s.tdcost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- 注册效果②，被对方破坏送去墓地时发动，回到额外卡组
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"回到额外卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.retcon)
	e2:SetTarget(s.rettg)
	e2:SetOperation(s.retop)
	c:RegisterEffect(e2)
end
-- 过滤函数，判断是否为「魔偶甜点」卡
function s.mfilter(c)
	return c:IsSetCard(0x71)
end
-- 过滤函数，判断是否为「魔偶甜点后·后冠提拉米苏」且表侧表示
function s.ovfilter(c)
	return c:IsFaceup() and c:IsCode(37164373)
end
-- 超量召唤操作函数，检查是否已使用过效果①
function s.xyzop(e,tp,chk)
	-- 检查是否已使用过效果①
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 注册标识效果，防止效果①一回合使用多次
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 效果①的发动条件，判断是否为对方回合
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 效果①的费用支付函数，消耗1个超量素材
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，判断是否为「魔偶甜点」卡且可送回卡组
function s.filter(c)
	return c:IsSetCard(0x71) and c:IsAbleToDeck()
end
-- 效果①的目标选择函数，选择墓地「魔偶甜点」卡和对方场上可送回卡组的卡
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	-- 检查是否有满足条件的墓地「魔偶甜点」卡
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上是否有可送回卡组的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择目标卡组中的「魔偶甜点」卡
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,2,nil)
	-- 设置操作信息，记录将要送回卡组的卡数
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果①的处理函数，将选中的卡送回卡组并再选对方场上卡送回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标卡组，并筛选与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡组中的卡送回卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA)
	-- 获取对方场上的可送回卡组的卡组
	local dg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	if ct>0 and dg:GetCount()>0 then
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local rg=dg:Select(tp,1,ct,nil)
		-- 显示选中卡组作为对象的动画效果
		Duel.HintSelection(rg)
		-- 将选中的对方场上卡送回卡组
		Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果②的发动条件，判断是否被对方破坏送去墓地且为己方控制者
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 效果②的目标设定函数，设置将自身送回卡组
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，记录将要送回卡组的卡数
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果②的处理函数，将自身送回额外卡组
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身送回额外卡组
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
