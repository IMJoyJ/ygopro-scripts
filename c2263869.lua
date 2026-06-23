--月女神の鏃
-- 效果：
-- 对方不能对应这张卡的发动把怪兽的效果发动。
-- ①：从额外卡组把1只怪兽送去墓地，以和那只怪兽相同种类（融合·同调·超量·灵摆·连接）的对方场上1只怪兽为对象才能发动。那只怪兽回到卡组。
local s,id,o=GetID()
-- 注册卡的效果，设置为发动时点、自由连锁、取对象效果，包含费用、目标、效果处理
function s.initial_effect(c)
	-- local e1=Effect.CreateEffect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 设置费用标签为100，表示费用已准备
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 过滤函数，检查额外卡组是否有能作为费用送去墓地且能对应目标怪兽种类的怪兽
function s.tgfilter(c,tp)
	-- 检查额外卡组中是否有能送去墓地的怪兽，并且对方场上存在满足种类条件的怪兽
	return c:IsAbleToGraveAsCost() and Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_MZONE,1,nil,c:GetType())
end
-- 过滤函数，检查对方场上是否有满足类型条件且能返回卡组的怪兽
function s.tdfilter(c,type)
	return c:IsFaceup() and c:IsAbleToDeck() and c:GetType()&type&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_PENDULUM|TYPE_LINK)>0
end
-- 设置效果目标，选择额外卡组中满足条件的怪兽送去墓地，并选择对方场上满足类型条件的怪兽返回卡组
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tdfilter(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查额外卡组中是否存在满足条件的怪兽
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组选择满足条件的1张怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	-- 将选中的怪兽送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
	local type=g:GetFirst():GetType()
	e:SetLabel(type)
	-- 提示玩家选择要返回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方场上满足类型条件的1只怪兽作为目标
	local tg=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_MZONE,1,1,nil,type)
	-- 设置操作信息，表示将目标怪兽返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制，防止对方在发动怪兽效果时连锁此卡
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 连锁限制函数，限制对方不能连锁怪兽效果
function s.chainlm(re,rp,tp)
	return tp==rp or not re:GetHandler():IsType(TYPE_MONSTER)
end
-- 效果处理函数，将目标怪兽返回卡组
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽返回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
