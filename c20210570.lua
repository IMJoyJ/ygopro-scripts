--レグルス
-- 效果：
-- 选择自己墓地存在的1张场地魔法卡发动。选择的卡回到卡组。这个效果1回合只能使用1次。
function c20210570.initial_effect(c)
	-- 创建效果，设置效果描述为“返回卡组”，设置效果分类为回卡组，设置效果属性为取对象，设置效果类型为起动效果，设置效果适用区域为主怪兽区，设置效果每回合只能发动1次，设置效果目标函数为c20210570.target，设置效果处理函数为c20210570.operation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20210570,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c20210570.target)
	e1:SetOperation(c20210570.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断卡片是否为场地魔法卡且可以送去卡组
function c20210570.filter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToDeck()
end
-- 效果目标函数，用于选择满足条件的场地魔法卡作为目标
function c20210570.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20210570.filter(chkc) end
	-- 检查阶段判断是否满足发动条件，即自己墓地是否存在1张场地魔法卡
	if chk==0 then return Duel.IsExistingTarget(c20210570.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的1张场地魔法卡作为目标
	local g=Duel.SelectTarget(tp,c20210570.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息，指定要处理的卡为选择的场地魔法卡
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理函数，将目标卡送回卡组
function c20210570.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
