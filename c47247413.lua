--差し戻し
-- 效果：
-- 对方把墓地的卡加入手卡时才能发动。对方让加入手卡的那1张卡回到卡组。
function c47247413.initial_effect(c)
	-- 效果原文内容：对方把墓地的卡加入手卡时才能发动。对方让加入手卡的那1张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCondition(c47247413.condition)
	e1:SetTarget(c47247413.target)
	e1:SetOperation(c47247413.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组，筛选出之前在墓地、控制者为指定玩家且与当前效果相关的卡片
function c47247413.filter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_GRAVE) and c:IsControler(tp) and (not e or c:IsRelateToEffect(e))
end
-- 判断连锁中是否有至少一张满足filter条件的卡片，用于触发效果的条件检测
function c47247413.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47247413.filter,1,nil,nil,1-tp)
end
-- 设置目标卡片并设定操作信息，准备将目标卡送回卡组
function c47247413.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁中的目标卡片设置为处理对象
	Duel.SetTargetCard(eg)
	-- 设置操作信息，指定本次效果属于CATEGORY_TODECK（回卡组）分类，并确定要处理的卡片数量为1张
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
end
-- 效果发动时执行的操作，筛选符合条件的卡片并选择其中一张送回卡组
function c47247413.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c47247413.filter,nil,e,1-tp)
	if g:GetCount()==0 then return end
	-- 向对方玩家提示“请选择要返回卡组的卡”
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local rg=g:Select(1-tp,1,1,nil)
	-- 确认玩家可以看到被选中的卡片
	Duel.ConfirmCards(tp,rg)
	-- 以效果原因将选中的卡片送回卡组底部并洗牌
	Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
