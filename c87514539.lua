--傀儡虫
-- 效果：
-- ①：把这张卡从手卡丢弃去墓地，以对方场上1只恶魔族·不死族怪兽为对象才能发动。那只恶魔族·不死族怪兽的控制权直到结束阶段得到。
function c87514539.initial_effect(c)
	-- ①：把这张卡从手卡丢弃去墓地，以对方场上1只恶魔族·不死族怪兽为对象才能发动。那只恶魔族·不死族怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87514539,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c87514539.cost)
	e1:SetTarget(c87514539.target)
	e1:SetOperation(c87514539.operation)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理：检查并把自身从手卡丢弃去墓地
function c87514539.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 作为发动代价，将这张卡丢弃去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤条件：对方场上表侧表示、种族为恶魔族或不死族且可以改变控制权的怪兽
function c87514539.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE+RACE_FIEND) and c:IsControlerCanBeChanged()
end
-- 发动准备（Target）处理：检查并选择对方场上1只表侧表示的恶魔族或不死族怪兽作为对象
function c87514539.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c87514539.filter(chkc) end
	-- 在发动效果时，检查对方场上是否存在至少1只满足条件的恶魔族或不死族怪兽
	if chk==0 then return Duel.IsExistingTarget(c87514539.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c87514539.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果包含改变控制权的操作，操作对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理（Operation）阶段：获取对象怪兽，若其仍满足条件，则直到结束阶段得到其控制权
function c87514539.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRace(RACE_ZOMBIE+RACE_FIEND) then
		-- 让发动效果的玩家直到结束阶段得到该怪兽的控制权
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
