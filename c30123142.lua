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
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c30123142.target)
	e1:SetOperation(c30123142.activate)
	c:RegisterEffect(e1)
end
-- 筛选条件：表侧表示、同调召唤、有同调素材
function c30123142.filter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterialCount()~=0
end
-- 选择目标：表侧表示的同调召唤怪兽
function c30123142.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c30123142.filter(chkc) end
	-- 判断是否有符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c30123142.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c30123142.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 将效果对象的攻击力上升其同调素材数量×500
function c30123142.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c30123142.filter(tc) then
		-- 将对象怪兽的攻击力上升其同调素材数量×500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetMaterialCount()*500)
		tc:RegisterEffect(e1)
	end
end
