--暗黒界の洗脳
-- 效果：
-- ①：自己手卡有3张以上存在，对方把怪兽的效果发动时，以场上1只「暗黑界」怪兽为对象才能把这个效果发动。作为对象的怪兽回到持有者手卡，那个对方的效果变成「对方手卡随机选1张丢弃」。
function c10131855.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己手卡有3张以上存在，对方把怪兽的效果发动时，以场上1只「暗黑界」怪兽为对象才能把这个效果发动。作为对象的怪兽回到持有者手卡，那个对方的效果变成「对方手卡随机选1张丢弃」。
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
-- 被替换的对方效果：对方手卡随机选1张丢弃
function c10131855.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡卡片组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		local sg=g:RandomSelect(1-tp,1)
		-- 以效果丢弃的方式将选中的卡片送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 效果发动的条件检查函数
function c10131855.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否是对方发动的怪兽效果且自己手卡有3张以上
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=3
end
-- 过滤场上表侧表示且可回到手卡的「暗黑界」怪兽
function c10131855.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6) and c:IsAbleToHand()
end
-- 效果发动的靶向与可行性检查
function c10131855.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c10131855.thfilter(chkc) end
	-- 在效果发动检查时，检查场上是否存在符合条件的「暗黑界」怪兽
	if chk==0 then return Duel.IsExistingTarget(c10131855.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1只「暗黑界」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c10131855.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置返回手牌操作的信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果实际处理函数
function c10131855.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果目标怪兽与效果有关联，则将其送回持有者手卡
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		local g=Group.CreateGroup()
		-- 清空原连锁的效果对象
		Duel.ChangeTargetCard(ev,g)
		-- 将原连锁的效果处理替换为随机丢弃手卡的效果
		Duel.ChangeChainOperation(ev,c10131855.repop)
	end
end
