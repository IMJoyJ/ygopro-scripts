--月女神の鏃
-- 效果：
-- 对方不能对应这张卡的发动把怪兽的效果发动。
-- ①：从额外卡组把1只怪兽送去墓地，以和那只怪兽相同种类（融合·同调·超量·灵摆·连接）的对方场上1只怪兽为对象才能发动。那只怪兽回到卡组。
local s,id,o=GetID()
-- 定义“月女神之镞”的初始化效果函数：创建发动效果 e1，将其类别设为回卡组、类型设为魔法卡发动、发动时点设为自由时点、属性设为取对象，并指定代价、发动条件与处理函数后注册到卡片上。
function s.initial_effect(c)
	-- 对方不能对应这张卡的发动把怪兽的效果发动。①：从额外卡组把1只怪兽送去墓地，以和那只怪兽相同种类（融合·同调·超量·灵摆·连接）的对方场上1只怪兽为对象才能发动。那只怪兽回到卡组。
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
-- 代价检查函数：先将效果标签设为100，作为“已允许发动”的标记；若为发动合法性检查阶段（chk==0）则直接返回true，表示满足发动条件；实际送墓额外怪兽的代价在target处理中完成。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 额外卡组选卡过滤：该额外怪兽必须能作为代价送入墓地，且对方场上有与该怪兽种类相同、满足tdfilter条件的表侧怪兽可作为效果对象。
function s.tgfilter(c,tp)
	-- 判断条件：该额外怪兽可作为代价送去墓地，并且对方场上存在1只符合种类条件的表侧表示怪兽可作为对象。
	return c:IsAbleToGraveAsCost() and Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_MZONE,1,nil,c:GetType())
end
-- 对象怪兽过滤：对方场上的怪兽必须是表侧表示、可以返回卡组，且其种类（融合·同调·超量·灵摆·连接）与从额外卡组送去墓地的怪兽种类存在交集。
function s.tdfilter(c,type)
	return c:IsFaceup() and c:IsAbleToDeck() and c:GetType()&type&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_PENDULUM|TYPE_LINK)>0
end
-- target处理：若检查已选对象则验证其合法性；发动合法性检查时确认已通过cost标记且额外卡组存在可送墓并能选择对象的怪兽；实际发动时先从额外卡组选择1只怪兽送墓作为代价，记录其类型，再选择对方场上同类型的表侧怪兽为对象，设置回卡组操作信息，并设置“对方不能对应这张卡的发动把怪兽效果发动”的连锁限制。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.tdfilter(chkc,e:GetLabel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 发动合法性检查：确认额外卡组存在1张满足tgfilter的怪兽，即存在可送墓且能对应选择对方场上对象的额外怪兽。
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil,tp)
	end
	-- 显示选择提示，要求玩家选择要送去墓地的额外卡组怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从额外卡组选择1只满足tgfilter条件的怪兽，作为发动代价送去墓地。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	-- 将选择的额外卡组怪兽以代价形式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	local type=g:GetFirst():GetType()
	e:SetLabel(type)
	-- 显示选择提示，要求玩家选择要返回卡组的对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从对方场上选择1只与送墓额外怪兽种类相同、表侧表示且可返回卡组的怪兽作为效果对象。
	local tg=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_MZONE,1,1,nil,type)
	-- 设置操作信息，声明本次连锁处理将把对象怪兽返回卡组（CATEGORY_TODECK），供相关卡效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制条件，使对方不能随意连锁发动效果；具体限制规则由s.chainlm定义。
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 连锁限制函数：仅当发起连锁的玩家是这张卡的发动者（tp==rp），或连锁的效果不是怪兽效果时，才允许连锁；即对方不能对应这张卡的发动把怪兽的效果发动。
function s.chainlm(re,rp,tp)
	return tp==rp or not re:GetHandler():IsType(TYPE_MONSTER)
end
-- 效果处理函数：若对象怪兽仍与发动效果相关联，则将其返回持有者卡组并洗牌。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因返回持有者卡组，并采用需要洗牌的方式处理（弹回卡组后洗牌）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
