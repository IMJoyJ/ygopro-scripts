--アビスコーン
-- 效果：
-- 选择自己场上1只名字带有「水精鳞」的怪兽才能发动。选择的怪兽的攻击力直到结束阶段时上升1000。此外，盖放的这张卡被送去墓地时，选择对方场上1只怪兽送去墓地。
function c79206750.initial_effect(c)
	-- 选择自己场上1只名字带有「水精鳞」的怪兽才能发动。选择的怪兽的攻击力直到结束阶段时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤中伤害计算前（或非伤害步骤）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c79206750.target)
	e1:SetOperation(c79206750.activate)
	c:RegisterEffect(e1)
	-- 此外，盖放的这张卡被送去墓地时，选择对方场上1只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79206750,0))  --"怪兽送墓"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c79206750.tgcon)
	e2:SetTarget(c79206750.tgtg)
	e2:SetOperation(c79206750.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的名字带有「水精鳞」的怪兽
function c79206750.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x74)
end
-- 效果1（攻击力上升）的发动准备与目标选择
function c79206750.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c79206750.filter(chkc) end
	-- 判定自己场上是否存在符合条件的名字带有「水精鳞」的怪兽
	if chk==0 then return Duel.IsExistingTarget(c79206750.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的名字带有「水精鳞」的怪兽作为效果对象
	Duel.SelectTarget(tp,c79206750.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果1（攻击力上升）的效果处理
function c79206750.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的第一个对象（即目标怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的攻击力直到结束阶段时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end
-- 判定这张卡在送去墓地前是否在场上处于盖放状态
function c79206750.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 效果2（送去墓地）的发动准备与目标选择
function c79206750.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为将选中的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果2（送去墓地）的效果处理
function c79206750.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的第一个对象（即对方场上的目标怪兽）
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
