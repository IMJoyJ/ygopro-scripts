--コカローチ・ナイト
-- 效果：
-- 这张卡送去墓地时，这张卡回到卡组最上面。
function c33413638.initial_effect(c)
	-- 这张卡送去墓地时，这张卡回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33413638,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c33413638.tdtg)
	e1:SetOperation(c33413638.tdop)
	c:RegisterEffect(e1)
end
-- 设置效果处理时的操作信息，指定将自身送入卡组
function c33413638.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁处理中将要把目标卡片送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 效果处理函数，检查卡片是否与效果相关联并执行送回卡组操作
function c33413638.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以效果原因送入卡组顶端
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
