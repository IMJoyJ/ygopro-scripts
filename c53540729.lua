--ゼンマイウォリアー
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「发条」的怪兽才能发动。直到结束阶段时选择的1只怪兽的等级上升1星，攻击力上升600。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c53540729.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「发条」的怪兽才能发动。直到结束阶段时选择的1只怪兽的等级上升1星，攻击力上升600。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53540729,0))  --"等级攻击上升"
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET+EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c53540729.target)
	e1:SetOperation(c53540729.operation)
	c:RegisterEffect(e1)
end
-- 定义可选择目标的条件：怪兽必须表侧表示、属于「发条」系列（0x58）且等级不低于1星，用于限制只能选择自己场上符合条件的「发条」怪兽。
function c53540729.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x58) and c:IsLevelAbove(1)
end
-- 目标选择处理：若已指定对象则检查其是否位于己方怪兽区、控制者为自己且满足过滤条件；若无对象则在发动时确认存在至少1只可选对象；然后给出选择提示，并让玩家从己方场上符合条件的「发条」怪兽中选择1只作为效果对象。
function c53540729.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53540729.filter(chkc) end
	-- 效果发动判定：在发动条件检查阶段，确认自己场上存在至少1只满足条件的表侧表示「发条」怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c53540729.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示选择提示，提示内容为“请选择表侧表示的卡”，用于引导选择目标怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上表侧表示且符合过滤条件的「发条」怪兽中选择1只，并将其设置为当前连锁的效果对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c53540729.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得效果对象后，确认对象仍在场上表侧表示且与本效果存在关联，然后给对象注册攻击力上升600和等级上升1星的两个持续效果，这两个效果不可被无效，持续到结束阶段，并随着常规离场、回手等重置条件被重置。
function c53540729.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽（本效果只选择1只对象，因此取第一张对象卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 攻击力上升600。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(600)
		tc:RegisterEffect(e1)
		-- 等级上升1星。
		local e2=Effect.CreateEffect(c)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
	end
end
