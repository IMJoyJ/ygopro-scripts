--死角からの一撃
-- 效果：
-- 选择对方场上表侧守备表示存在的1只怪兽和自己场上表侧攻击表示存在的1只怪兽发动。选择的自己怪兽的攻击力直到结束阶段时上升选择的对方怪兽的守备力数值。
function c49267971.initial_effect(c)
	-- 选择对方场上表侧守备表示存在的1只怪兽和自己场上表侧攻击表示存在的1只怪兽发动。选择的自己怪兽的攻击力直到结束阶段时上升选择的对方怪兽的守备力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件为伤害步骤且尚未进行伤害计算的时点，使此卡只能在伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c49267971.target)
	e1:SetOperation(c49267971.activate)
	c:RegisterEffect(e1)
end
-- 目标选择函数：首先处理连锁时的对象合法性判断（chkc时返回false），随后在发动判定阶段（chk==0）检查场上是否存在两类必要的对象怪兽。
function c49267971.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1只表侧守备表示怪兽，作为效果发动的必要条件之一。
	if chk==0 then return Duel.IsExistingTarget(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_DEFENSE)
		-- 同时检查自己场上是否存在至少1只表侧攻击表示怪兽，与上一条件共同决定效果能否发动。
		and Duel.IsExistingTarget(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_ATTACK) end
	-- 向玩家显示选择提示，要求选择对方场上的怪兽（提示文字为“请选择对方的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 让玩家从对方场上选择1只表侧守备表示怪兽，并登记为这张卡发动时的对象。
	local g1=Duel.SelectTarget(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,1,nil,POS_FACEUP_DEFENSE)
	-- 向玩家显示选择提示，要求选择自己场上的怪兽（提示文字为“请选择自己的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 让玩家从自己场上选择1只表侧攻击表示怪兽，并登记为这张卡发动时的对象。
	local g2=Duel.SelectTarget(tp,Card.IsPosition,tp,LOCATION_MZONE,0,1,1,nil,POS_FACEUP_ATTACK)
	e:SetLabelObject(g1:GetFirst())
end
-- 效果处理函数：取出之前保存的对方怪兽，从连锁对象中确定自己怪兽；确认二者仍与效果相关且表侧表示后，给自己怪兽附加攻击力上升效果，数值为对方怪兽当前守备力，直到结束阶段。
function c49267971.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	-- 从连锁信息中取得本效果发动时登记的全部对象卡组，用于在处理时定位自己选择的那只怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc1==tc2 then tc2=g:GetNext() end
	if tc1:IsRelateToEffect(e) and tc1:IsFaceup() and tc2:IsRelateToEffect(e) and tc2:IsFaceup() then
		-- 选择的自己怪兽的攻击力直到结束阶段时上升选择的对方怪兽的守备力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc1:GetDefense())
		tc2:RegisterEffect(e1)
	end
end
