--サイバネット・ユニバース
-- 效果：
-- ①：自己场上的连接怪兽的攻击力上升300。
-- ②：1回合1次，以自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽回到持有者卡组。
-- ③：场上的这张卡被效果破坏的场合发动。额外怪兽区域的怪兽全部送去墓地。
function c61583217.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的连接怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置永续效果的影响对象为连接怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_LINK))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己或者对方的墓地1只怪兽为对象才能发动。那只怪兽回到持有者卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61583217,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c61583217.tdtg)
	e3:SetOperation(c61583217.tdop)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡被效果破坏的场合发动。额外怪兽区域的怪兽全部送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(61583217,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c61583217.tgcon)
	e4:SetTarget(c61583217.tgtg)
	e4:SetOperation(c61583217.tgop)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己或对方墓地的怪兽卡，且能回到卡组
function c61583217.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果②的发动准备（检查合法性、选择对象并设置操作信息）
function c61583217.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c61583217.tdfilter(chkc) end
	-- 检查双方墓地是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c61583217.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 给玩家发送提示信息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择双方墓地中1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c61583217.tdfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②的处理：将选中的墓地怪兽送回持有者卡组并洗牌
function c61583217.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将对象怪兽送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果③的发动条件：场上的这张卡因效果被破坏
function c61583217.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：位于额外怪兽区域（序号为5或6）的怪兽
function c61583217.tgfilter(c)
	return c:GetSequence()>=5
end
-- 效果③的发动准备（必发效果，直接返回true并设置送去墓地的操作信息）
function c61583217.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上额外怪兽区域的所有怪兽
	local g=Duel.GetMatchingGroup(c61583217.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息为：将这些额外怪兽区域的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果③的处理：将额外怪兽区域的怪兽全部送去墓地
function c61583217.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取当前场上额外怪兽区域的所有怪兽
	local g=Duel.GetMatchingGroup(c61583217.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 因效果将获取到的怪兽全部送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
