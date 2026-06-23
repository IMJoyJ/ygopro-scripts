--ディスクライダー
-- 效果：
-- 把自己墓地存在的1张通常陷阱卡从游戏中除外，这张卡的攻击力直到对方回合的结束阶段时上升500。这个效果1回合只能使用1次。
function c41113025.initial_effect(c)
	-- 创建一个起动效果，效果描述为“攻击上升”，分类为除外和改变攻击力，效果类型为起动效果，取对象，生效位置为主怪区，每回合只能发动一次，目标函数为c41113025.target，处理函数为c41113025.operation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41113025,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c41113025.target)
	e1:SetOperation(c41113025.operation)
	c:RegisterEffect(e1)
end
-- 过滤器函数，用于判断卡片是否为通常陷阱卡且可以被除外
function c41113025.cfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsAbleToRemove()
end
-- 效果处理的目标函数，判断是否能选择满足条件的卡片作为目标
function c41113025.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41113025.cfilter(chkc) end
	-- 检查阶段判断是否满足发动条件，即自己墓地存在1张通常陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c41113025.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张墓地陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c41113025.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示将要除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数，处理将目标陷阱卡除外并使自身攻击力上升500
function c41113025.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡片是否仍然在场上且满足除外条件，同时确认自身是否正面表示
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 使自身攻击力上升500，持续到对方回合结束阶段
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
