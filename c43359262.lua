--エレクトロ軍曹
-- 效果：
-- ①：1回合1次，以对方的魔法与陷阱区域盖放的1张卡为对象才能发动。这张卡得到以下效果。
-- ●只要这张卡在怪兽区域存在，作为对象的盖放的卡不能发动。
function c43359262.initial_effect(c)
	-- 效果原文内容：①：1回合1次，以对方的魔法与陷阱区域盖放的1张卡为对象才能发动。这张卡得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43359262,0))  --"发动限制"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c43359262.target)
	e1:SetOperation(c43359262.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的魔法与陷阱区域的里侧表示卡片
function c43359262.filter(c,rc)
	return c:IsFacedown() and c:GetSequence()~=5 and not rc:IsHasCardTarget(c)
end
-- 效果作用：选择对方魔法与陷阱区域的里侧表示卡片作为对象
function c43359262.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c43359262.filter(chkc,e:GetHandler()) end
	-- 效果作用：判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c43359262.filter,tp,0,LOCATION_SZONE,1,nil,e:GetHandler()) end
	-- 效果作用：提示玩家选择里侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 效果作用：选择对方魔法与陷阱区域的里侧表示卡片作为对象
	Duel.SelectTarget(tp,c43359262.filter,tp,0,LOCATION_SZONE,1,1,nil,e:GetHandler())
end
-- 效果作用：设置电力军曹获得对象卡片的限制效果
function c43359262.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：获取当前连锁中选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		-- 效果原文内容：●只要这张卡在怪兽区域存在，作为对象的盖放的卡不能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
		e1:SetTarget(c43359262.distg)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 效果作用：判断目标卡片是否为电力军曹的对象卡片且处于里侧表示
function c43359262.distg(e,c)
	return c:IsFacedown() and e:GetHandler():IsHasCardTarget(c)
end
