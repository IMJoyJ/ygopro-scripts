--暗黒界の洗脳
-- 效果：
-- ①：自己手卡有3张以上存在，对方把怪兽的效果发动时，以场上1只「暗黑界」怪兽为对象才能把这个效果发动。作为对象的怪兽回到持有者手卡，那个对方的效果变成「对方手卡随机选1张丢弃」。
function c10131855.initial_effect(c)
	-- 才能把这个效果发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 作为对象的怪兽回到持有者手卡，那个对方的效果变成「对方手卡随机选1张丢弃」。
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
-- 定义替换效果的处理函数，用于实现对方效果变为随机丢弃手卡。
function c10131855.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方玩家手卡的所有卡片组。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(1-tp,1)
		-- 将随机选择的一张对方手卡以丢弃原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 定义发动条件的检查函数。
function c10131855.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方玩家发动了怪兽效果，且自己手卡数量在3张以上。
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=3
end
-- 定义过滤函数，选择场上表侧表示且为暗黑界怪兽并可回手的卡片。
function c10131855.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6) and c:IsAbleToHand()
end
-- 定义效果的目标选择和处理函数。
function c10131855.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10131855.thfilter(chkc) end
	-- 检查场上是否存在符合条件的暗黑界怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c10131855.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	-- 玩家选择场上的一只暗黑界怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c10131855.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时回手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义效果处理函数。
function c10131855.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 如果目标怪兽与效果相关，则将其送回持有者手牌。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		local g=Group.CreateGroup()
		-- 将对方效果的对象更改为空组，移除原对象。
		Duel.ChangeTargetCard(ev,g)
		-- 将对方效果的处理函数替换为随机丢弃手卡的效果。
		Duel.ChangeChainOperation(ev,c10131855.repop)
	end
end
