--ネジマキシキガミ
-- 效果：
-- 这张卡不能通常召唤。自己墓地的怪兽只有机械族怪兽的场合可以特殊召唤。
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。
function c45458027.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。自己墓地的怪兽只有机械族怪兽的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c45458027.spcon)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45458027,0))  --"攻击力变成0"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c45458027.target)
	e2:SetOperation(c45458027.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片种族是否不是机械族，若返回true表示该怪兽不是机械族，用于检测墓地中是否存在非机械族怪兽。
function c45458027.cfilter(c)
	return c:GetRace()~=RACE_MACHINE
end
-- 特殊召唤规则条件：当c为nil时代表系统询问能否特殊召唤，返回true；否则获取该卡的控制者，检查其主怪兽区是否有空位，并检查自己墓地存在怪兽且所有怪兽均为机械族（不存在非机械族怪兽）。
function c45458027.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查控制者场上主要怪兽区是否有空位，若无空位则无法进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	-- 获取控制者墓地的所有怪兽卡组成候选组，用于后续判断是否全部为机械族。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_MONSTER)
	return g:GetCount()>0 and not g:IsExists(c45458027.cfilter,1,nil)
end
-- ①效果的发动条件与对象选择：以对方场上表侧表示且攻击力大于0的怪兽为对象，选择1只作为效果对象。
function c45458027.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsLocation(LOCATION_MZONE) end
	-- 发动时检查：确认对方场上是否存在至少1只表侧表示且攻击力大于0的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的提示消息，用于选择对象时的文字提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只表侧表示且攻击力大于0的怪兽，并将其设为当前连锁的效果对象。
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：获取对象怪兽，若其仍为表侧表示且与效果关联，则对其赋予攻击力变为0的效果，该效果持续到回合结束阶段。
function c45458027.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的第一张对象卡，即先前选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
	end
end
