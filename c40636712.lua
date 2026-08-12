--デストーイ・ハーケン・クラーケン
-- 效果：
-- 「锋利小鬼」怪兽＋「毛绒动物」怪兽
-- ①：1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。这个效果发动的回合，这张卡不能直接攻击。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：这张卡进行战斗的战斗阶段结束时才能发动。这张卡变成守备表示。
function c40636712.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用一张「锋利小鬼」怪兽和一张「毛绒动物」怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xc3),aux.FilterBoolFunction(Card.IsFusionSetCard,0xa9),true)
	-- ①：1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。这个效果发动的回合，这张卡不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40636712,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c40636712.cost)
	e1:SetTarget(c40636712.target)
	e1:SetOperation(c40636712.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：这张卡进行战斗的战斗阶段结束时才能发动。这张卡变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40636712,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c40636712.poscon)
	e3:SetOperation(c40636712.posop)
	c:RegisterEffect(e3)
end
-- 效果处理时检查是否已经直接攻击过，若未攻击则设置此卡不能直接攻击直到结束阶段
function c40636712.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsDirectAttacked() end
	-- 设置此卡在本回合不能直接攻击的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 选择对方场上的1只怪兽作为效果对象
function c40636712.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 判断是否满足选择对象的条件，即对方场上存在怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，确定将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 执行效果处理，将选择的怪兽送去墓地
function c40636712.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 判断此卡是否在攻击表示且已参与过战斗
function c40636712.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsAttackPos() and c:GetBattledGroupCount()>0
end
-- 将此卡在战斗阶段结束时变为守备表示
function c40636712.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将此卡变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
