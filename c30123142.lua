--シンクロ・ストライク
-- 效果：
-- 同调召唤的1只怪兽的攻击力直到结束阶段时上升同调素材的怪兽数量×500的数值。
function c30123142.initial_effect(c)
	-- 同调召唤的1只怪兽的攻击力直到结束阶段时上升同调素材的怪兽数量×500的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置效果只能在伤害步骤的伤害计算前发动（伤害计算后不能发动）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c30123142.target)
	e1:SetOperation(c30123142.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：怪兽必须表侧表示、通过同调召唤出场、且其同调素材数量不为0。
function c30123142.filter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterialCount()~=0
end
-- 发动时的目标处理：检查是否存在合法对象；若有，则提示玩家选择1只表侧表示的同调召唤怪兽作为效果对象。
function c30123142.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c30123142.filter(chkc) end
	-- 在发动合法性检查（chk=0）阶段，确认场上存在至少1只可被选择为对象的表侧同调召唤怪兽，作为发动条件。
	if chk==0 then return Duel.IsExistingTarget(c30123142.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送“请选择表侧表示的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方场上选择1只满足筛选条件的表侧表示怪兽，并将其设为效果对象（取对象）。
	Duel.SelectTarget(tp,c30123142.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时，对对象怪兽赋予持续到结束阶段的攻击力上升效果，上升数值为该怪兽的同调素材数量×500。
function c30123142.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁中记录的第一张对象卡（即之前选择的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c30123142.filter(tc) then
		-- 攻击力直到结束阶段时上升同调素材的怪兽数量×500的数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetMaterialCount()*500)
		tc:RegisterEffect(e1)
	end
end
