--デストーイ・ハーケン・クラーケン
-- 效果：
-- 「锋利小鬼」怪兽＋「毛绒动物」怪兽
-- ①：1回合1次，以对方场上1只怪兽为对象才能发动。那只怪兽送去墓地。这个效果发动的回合，这张卡不能直接攻击。
-- ②：这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：这张卡进行战斗的战斗阶段结束时才能发动。这张卡变成守备表示。
function c40636712.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：融合素材要求为「锋利小鬼」怪兽（SetCard 0xc3）与「毛绒动物」怪兽（SetCard 0xa9）各1只，满足条件方可融合召唤。
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
-- ①的发动代价：检查此卡本回合尚未直接攻击过（若已直接攻击则不能发动），并给自己附加“不能直接攻击”的誓约效果（持续到回合结束，不可被无效）。
function c40636712.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsDirectAttacked() end
	-- 这个效果发动的回合，这张卡不能直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果①的发动目标：选择对方场上1只怪兽为对象（取对象），并设置将其送去墓地的操作信息。
function c40636712.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 确认对方场上有1只以上可作为对象的怪兽；若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 向当前玩家显示“请选择要送去墓地的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让当前玩家从对方场上选择1只怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明本效果将把1张对象卡送去墓地（供其他效果或卡片的发动判定参考）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果处理时，取得对象卡；若该对象仍与本效果保持关联，则将其送去墓地。
function c40636712.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果处理的对象卡（由于只选择1张，故为第一张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以「效果」为原因将对象怪兽送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 效果③的发动条件：这张卡在战斗阶段结束时为攻击表示，且本回合进行过战斗（攻击过或成为过攻击对象）。
function c40636712.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsAttackPos() and c:GetBattledGroupCount()>0
end
-- 效果③的处理：若这张卡仍为攻击表示，则将其变成表侧守备表示。
function c40636712.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡的表示形式变更为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
