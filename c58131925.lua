--BF－極夜のダマスカス
-- 效果：
-- ①：把这张卡从手卡丢弃，以自己场上1只「黑羽」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。这个效果在对方回合也能发动。
function c58131925.initial_effect(c)
	-- ①：把这张卡从手卡丢弃，以自己场上1只「黑羽」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58131925,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果的发动条件：在伤害步骤中，只能在伤害计算前发动（利用aux.dscon辅助函数限制）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c58131925.cost)
	e1:SetTarget(c58131925.target)
	e1:SetOperation(c58131925.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动的代价：检查并把手牌中的这张卡丢弃送去墓地。
function c58131925.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤条件：自己场上表侧表示的「黑羽」怪兽（字段为0x33）。
function c58131925.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
-- 定义效果的发动准备（Target）：检查并选择自己场上1只表侧表示的「黑羽」怪兽作为效果的对象。
function c58131925.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c58131925.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在至少1只表侧表示的「黑羽」怪兽可以作为效果的对象。
	if chk==0 then return Duel.IsExistingTarget(c58131925.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，要求选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择自己场上1只表侧表示的「黑羽」怪兽作为效果的对象并进行锁定。
	Duel.SelectTarget(tp,c58131925.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 定义效果的处理（Operation）：使作为对象的怪兽攻击力直到回合结束时上升500。
function c58131925.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
