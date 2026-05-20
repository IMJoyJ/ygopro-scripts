--マドルチェ・シューバリエ
-- 效果：
-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。此外，只要这张卡在场上表侧表示存在，对方不能选择「魔偶甜点·泡芙骑士」以外的名字带有「魔偶甜点」的怪兽作为攻击对象。
function c75363626.initial_effect(c)
	-- 这张卡被对方破坏送去墓地时，这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75363626,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c75363626.retcon)
	e1:SetTarget(c75363626.rettg)
	e1:SetOperation(c75363626.retop)
	c:RegisterEffect(e1)
	-- 此外，只要这张卡在场上表侧表示存在，对方不能选择「魔偶甜点·泡芙骑士」以外的名字带有「魔偶甜点」的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c75363626.atktg)
	c:RegisterEffect(e2)
end
-- 判断此卡是否在己方场上被对方破坏并送去墓地
function c75363626.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- 返回卡组效果的发动准备，设置将自身送回卡组的操作信息
function c75363626.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为将自身送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 返回卡组效果的执行，若此卡仍与效果相关联则将其送回卡组并洗牌
function c75363626.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 因效果将自身送回持有者卡组并洗牌
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 筛选场上表侧表示的「魔偶甜点·泡芙骑士」以外的「魔偶甜点」怪兽
function c75363626.atktg(e,c)
	return c:IsFaceup() and not c:IsCode(75363626) and c:IsSetCard(0x71)
end
