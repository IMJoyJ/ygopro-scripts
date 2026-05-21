--オーディンの眼
-- 效果：
-- 1回合1次，双方的准备阶段时选择自己场上表侧表示存在的1只名字带有「极神」的怪兽才能发动。选择的怪兽的效果直到结束阶段时无效，把对方手卡以及对方场上盖放的卡全部确认。对方不能对应这个效果的发动把魔法·陷阱·效果怪兽的效果发动。
function c88069166.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，双方的准备阶段时选择自己场上表侧表示存在的1只名字带有「极神」的怪兽才能发动。选择的怪兽的效果直到结束阶段时无效，把对方手卡以及对方场上盖放的卡全部确认。对方不能对应这个效果的发动把魔法·陷阱·效果怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88069166,0))  --"确认手卡和盖卡"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c88069166.target)
	e2:SetOperation(c88069166.operation)
	c:RegisterEffect(e2)
	-- 直到结束阶段时
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TURN_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(c88069166.ctarget)
	c:RegisterEffect(e3)
	-- 选择的怪兽的效果……无效
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
end
-- 过滤条件：自己场上表侧表示的名字带有「极神」的怪兽
function c88069166.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4b)
end
-- 效果发动的对象选择与连锁限制处理
function c88069166.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c88069166.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「极神」怪兽
	if chk==0 then return Duel.IsExistingTarget(c88069166.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「极神」怪兽作为效果对象
	Duel.SelectTarget(tp,c88069166.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁限制，防止对方对应此效果的发动来发动效果
	Duel.SetChainLimit(c88069166.chlimit)
end
-- 连锁限制条件：仅允许发动该效果的玩家进行连锁（即对方不能对应发动效果）
function c88069166.chlimit(e,ep,tp)
	return tp==ep
end
-- 效果处理：将对象怪兽与本卡建立连接（使其效果无效），并确认对方的手卡和场上盖放的卡
function c88069166.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		-- 获取对方的手卡
		local g1=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		-- 获取对方场上所有里侧表示（盖放）的卡
		local g2=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
		g1:Merge(g2)
		-- 让发动效果的玩家确认对方的手卡及对方场上盖放的卡
		Duel.ConfirmCards(tp,g1)
		-- 重新洗切对方的手卡
		Duel.ShuffleHand(1-tp)
	end
end
-- 在回合结束阶段时，解除本卡对目标怪兽的连接（从而恢复其效果）
function c88069166.ctarget(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc then e:GetHandler():CancelCardTarget(tc) end
end
