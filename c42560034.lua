--夜の逃飛行
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽回到持有者手卡。这个回合，双方不能把这个效果加入手卡的卡以及那些同名卡的效果发动。
function c42560034.initial_effect(c)
	-- 创建并注册魔陷卡效果，设置为自由连锁、取对象、发动时处理回手牌效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42560034,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c42560034.target)
	e1:SetOperation(c42560034.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断目标怪兽是否为表侧表示且能送入手牌
function c42560034.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果处理目标选择函数：选择自己场上1只表侧表示怪兽作为对象
function c42560034.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42560034.filter(chkc) end
	-- 判断是否满足发动条件：自己场上是否存在1只可送入手牌的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c42560034.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c42560034.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果操作信息：将选中的怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动处理函数：将对象怪兽送入手牌并设置后续限制效果
function c42560034.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup()
		-- 判断对象怪兽是否有效且已送入手牌
		and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 创建并注册双方不能发动同名卡效果的限制效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,1)
		e1:SetValue(c42560034.actlimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将限制效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果的判断函数：判断是否为同名卡的效果
function c42560034.actlimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
