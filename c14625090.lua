--ドラゴンメイドのお出迎え
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽的攻击力·守备力上升自己场上的「半龙女仆」怪兽数量×100。
-- ②：自己场上有「半龙女仆」怪兽2只以上存在的场合，以「半龙女仆的迎接」以外的自己墓地1张「半龙女仆」卡为对象才能发动。那张卡加入手卡。
-- ③：这张卡被送去墓地的场合发动。这个回合中，对方不能把自己场上的「半龙女仆」怪兽作为效果的对象。
function c14625090.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的怪兽的攻击力·守备力上升自己场上的「半龙女仆」怪兽数量×100。（攻击力部分）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(c14625090.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上有「半龙女仆」怪兽2只以上存在的场合，以「半龙女仆的迎接」以外的自己墓地1张「半龙女仆」卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(14625090,0))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,14625090)
	e4:SetCondition(c14625090.thcon)
	e4:SetTarget(c14625090.thtg)
	e4:SetOperation(c14625090.thop)
	c:RegisterEffect(e4)
	-- ③：这张卡被送去墓地的场合发动。这个回合中，对方不能把自己场上的「半龙女仆」怪兽作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(14625090,1))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetOperation(c14625090.tgop)
	c:RegisterEffect(e5)
end
-- 判断一张卡是否为表侧表示且属于「半龙女仆」系列（0x133），用于筛选场上存在的「半龙女仆」怪兽。
function c14625090.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x133)
end
-- 计算自己场上表侧表示的「半龙女仆」怪兽数量，每个提供100点攻击力上升值。
function c14625090.atkval(e,c)
	-- 统计自己场上表侧表示且满足c14625090.filter的「半龙女仆」怪兽数量，并乘以100作为攻击力上升数值。
	return Duel.GetMatchingGroupCount(c14625090.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*100
end
-- ②效果的发动条件：自己场上有至少2只表侧表示的「半龙女仆」怪兽时才能发动。
function c14625090.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只表侧表示的「半龙女仆」怪兽，用于判定②效果是否满足发动条件。
	return Duel.IsExistingMatchingCard(c14625090.filter,tp,LOCATION_MZONE,0,2,nil)
end
-- 筛选自己墓地中满足“是「半龙女仆」系列、不是「半龙女仆的迎接」自身、可以被加入手卡”的卡，作为②效果的对象候选。
function c14625090.thfilter(c)
	return c:IsSetCard(0x133) and not c:IsCode(14625090) and c:IsAbleToHand()
end
-- ②效果发动时的目标选择流程：确认墓地存在符合条件的对象，提示玩家选择，选取1张「半龙女仆」卡（不含本卡）作为对象，并设置加入手卡的操作信息。
function c14625090.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14625090.thfilter(chkc) end
	-- 效果发动时在无预选对象的情况下，检查自己墓地是否存在至少1张符合条件的「半龙女仆」卡，以决定能否发动。
	if chk==0 then return Duel.IsExistingTarget(c14625090.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的界面提示，用于选择卡片时的说明。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地符合条件的「半龙女仆」卡中选择1张作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c14625090.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次效果处理会把对象卡加入手卡的操作信息，供其他效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理阶段：取出对象卡，若其仍与效果关联，则将其加入持有者的手卡。
function c14625090.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中②效果选择的对象卡（此处为唯一的对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡，处理原因为效果。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ③效果处理：为本回合我方场上的「半龙女仆」怪兽附加“不会成为对方效果对象”的防护效果，持续到结束阶段。
function c14625090.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，对方不能把自己场上的「半龙女仆」怪兽作为效果的对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 指定防护效果适用的对象：持有「半龙女仆」系列字段的怪兽（即我方场上的「半龙女仆」怪兽）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x133))
	-- 设置防护效果的判定逻辑，使“对方不能将其作为效果对象”的规则生效。
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将生成的防护效果以我方玩家的身份注册到场上，使其在本回合内持续适用。
	Duel.RegisterEffect(e1,tp)
end
