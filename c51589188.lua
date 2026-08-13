--フォトン・トライデント
-- 效果：
-- 选择自己场上1只名字带有「光子」的怪兽才能发动。直到结束阶段时，选择的怪兽的攻击力上升700，向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。此外，选择的怪兽给与对方基本分战斗伤害时，可以选择场上1张魔法·陷阱卡破坏。
function c51589188.initial_effect(c)
	-- 选择自己场上1只名字带有「光子」的怪兽才能发动。直到结束阶段时，选择的怪兽的攻击力上升700，向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。此外，选择的怪兽给与对方基本分战斗伤害时，可以选择场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件：不能在进行伤害计算后的伤害步骤中发动，只能在非伤害步骤或伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c51589188.target)
	e1:SetOperation(c51589188.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：对象必须是表侧表示且卡名含有「光子」字段的怪兽。
function c51589188.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x55)
end
-- 发动时的合法检查和对象选择：确认对象需为自己场上的表侧表示「光子」怪兽，并让玩家选择1只符合条件的怪兽作为效果对象。
function c51589188.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c51589188.filter(chkc) end
	-- 发动合法性检查：chk==0时，若自己场上不存在符合条件的「光子」怪兽，则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c51589188.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示选择表侧表示怪兽的提示信息，用于选择卡片的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上表侧表示的「光子」怪兽中选择1只，并将其登记为这张卡的效果对象。
	local g=Duel.SelectTarget(tp,c51589188.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理时，若对象怪兽仍与此效果关联、表侧表示且不免疫此效果，则赋予其攻击力上升700及贯穿伤害，并注册一个当该怪兽造成战斗伤害时可破坏场上1张魔法·陷阱卡的诱发效果，这些效果持续到结束阶段。
function c51589188.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 直到结束阶段时，选择的怪兽的攻击力上升700。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(700)
		tc:RegisterEffect(e1)
		-- 向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 此外，选择的怪兽给与对方基本分战斗伤害时，可以选择场上1张魔法·陷阱卡破坏。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetDescription(aux.Stringid(51589188,0))  --"破坏"
		e3:SetCategory(CATEGORY_DESTROY)
		e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e3:SetCode(EVENT_BATTLE_DAMAGE)
		e3:SetLabelObject(tc)
		e3:SetCondition(c51589188.descon)
		e3:SetTarget(c51589188.destg)
		e3:SetOperation(c51589188.desop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将“造成战斗伤害时破坏魔法·陷阱卡”的诱发效果注册到当前玩家，使其满足条件时可以被触发，并持续到结束阶段重置。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 该破坏效果的发动条件：对方受到战斗伤害，且造成伤害的怪兽正是这张卡最初选择的对象怪兽。
function c51589188.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst()==e:GetLabelObject()
end
-- 定义破坏对象筛选条件：任意魔法·陷阱卡。
function c51589188.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的目标处理：检测场上是否存在可选的魔法·陷阱卡，提示并选择1张作为破坏对象，同时登记破坏的操作信息。
function c51589188.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c51589188.desfilter(chkc) end
	-- 检查场上是否存在至少1张可作为对象的魔法·陷阱卡，若不存在则不能发动破坏效果。
	if chk==0 then return Duel.IsExistingTarget(c51589188.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示选择要破坏的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张魔法·陷阱卡作为破坏对象，并登记为效果对象。
	local g=Duel.SelectTarget(tp,c51589188.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记连锁处理信息：本次为破坏1张卡（对象为g），使其他效果能正确对应这次破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：若选择的对象卡仍与此效果关联，则将其以效果原因破坏。
function c51589188.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要破坏的对象卡（魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将选择的对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
