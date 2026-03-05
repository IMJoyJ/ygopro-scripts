--暗黒界の洗脳
-- 效果：
-- ①：自己手卡有3张以上存在，对方把怪兽的效果发动时，以场上1只「暗黑界」怪兽为对象才能把这个效果发动。作为对象的怪兽回到持有者手卡，那个对方的效果变成「对方手卡随机选1张丢弃」。
function c10131855.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文内容：①：自己手卡有3张以上存在，对方把怪兽的效果发动时，以场上1只「暗黑界」怪兽为对象才能把这个效果发动。作为对象的怪兽回到持有者手卡，那个对方的效果变成「对方手卡随机选1张丢弃」。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10131855,1))  --"改变对方效果"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c10131855.condition)
	e2:SetTarget(c10131855.target)
	e2:SetOperation(c10131855.operation)
	c:RegisterEffect(e2)
end
-- 函数定义：处理效果发动后对方手卡丢弃的函数
function c10131855.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家手卡的卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(1-tp,1)
		-- 将sg中的卡片以效果和丢弃的原因送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 函数定义：判断是否满足发动条件
function c10131855.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：对方发动效果且自己手卡不少于3张
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=3
end
-- 函数定义：筛选符合条件的「暗黑界」怪兽
function c10131855.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6) and c:IsAbleToHand()
end
-- 函数定义：设置效果的目标
function c10131855.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10131855.thfilter(chkc) end
	-- 检查阶段：判断是否存在符合条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c10131855.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择：向玩家提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	-- 选择目标：从场上选择一只符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c10131855.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将要返回手牌的怪兽设置为操作对象
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 函数定义：执行效果处理
function c10131855.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效并将其送入手卡
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		local g=Group.CreateGroup()
		-- 更改连锁的目标卡片为一个空组
		Duel.ChangeTargetCard(ev,g)
		-- 更改连锁的处理函数为repop函数，实现效果变为对方手卡丢弃
		Duel.ChangeChainOperation(ev,c10131855.repop)
	end
end
