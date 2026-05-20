--捕食植物ドラゴスタペリア
-- 效果：
-- 融合怪兽＋暗属性怪兽
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。这个效果在对方回合也能发动。
-- ②：只要这张卡在怪兽区域存在，对方发动的有捕食指示物放置的怪兽的效果无效化。
function c69946549.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为融合怪兽和暗属性怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_DARK),true)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69946549,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c69946549.cttg)
	e1:SetOperation(c69946549.ctop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方发动的有捕食指示物放置的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c69946549.discon)
	e2:SetOperation(c69946549.disop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动准备，确认并选择对方场上1只可以放置捕食指示物的表侧表示怪兽作为对象
function c69946549.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanAddCounter(0x1041,1) end
	-- 在发动时，检查对方场上是否存在可以放置捕食指示物的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1041,1) end
	-- 向发动玩家提示选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只可以放置捕食指示物的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1041,1)
end
-- ①号效果的处理，给对象怪兽放置捕食指示物，并对其适用等级变为1星的效果
function c69946549.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:AddCounter(0x1041,1) and tc:IsLevelAbove(2) then
		-- 有捕食指示物放置的2星以上的怪兽的等级变成1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c69946549.lvcon)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 等级改变效果的适用条件：该怪兽身上放置有捕食指示物
function c69946549.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- ②号效果的适用条件：此卡未被战斗破坏，且对方发动的怪兽效果的发动怪兽身上有捕食指示物
function c69946549.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetCounter(0x1041)>0
end
-- ②号效果的处理，将该对方发动的怪兽效果无效化
function c69946549.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end
