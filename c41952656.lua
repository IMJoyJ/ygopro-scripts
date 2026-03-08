--イマイルカ
-- 效果：
-- 场上的这张卡被对方破坏送去墓地时，自己卡组最上面的卡送去墓地。送去墓地的卡是水属性怪兽的场合，从自己卡组抽1张卡。
function c41952656.initial_effect(c)
	-- 效果原文内容：场上的这张卡被对方破坏送去墓地时，自己卡组最上面的卡送去墓地。送去墓地的卡是水属性怪兽的场合，从自己卡组抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41952656,0))  --"卡组送墓"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c41952656.drcon)
	e1:SetTarget(c41952656.drtg)
	e1:SetOperation(c41952656.drop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查触发效果的卡是否因对方破坏而送去墓地，且不是因规则送去墓地，且上一个控制者是自己
function c41952656.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and not c:IsReason(REASON_RULE) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 规则层面作用：设置连锁操作信息，表明将要从自己卡组最上面送去墓地1张卡
function c41952656.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：设置当前处理的连锁的操作信息，指定将要处理的卡为卡组最上面的1张卡，位置为墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 规则层面作用：执行效果处理，将自己卡组最上面的1张卡送去墓地，若送去墓地的卡是水属性怪兽则抽1张卡
function c41952656.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：将自己卡组最上面的1张卡送去墓地，并判断是否成功
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)==1 then
		-- 规则层面作用：获取刚刚执行的卡片操作中实际被处理的卡片组
		local g=Duel.GetOperatedGroup()
		if g:GetFirst():IsAttribute(ATTRIBUTE_WATER) then
			-- 规则层面作用：从自己卡组抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
