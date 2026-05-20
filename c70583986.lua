--氷結界の虎王 ドゥローレン
-- 效果：
-- 调整＋调整以外的水属性怪兽1只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己场上的其他的表侧表示卡任意数量为对象才能发动。那些自己的表侧表示卡回到手卡。这张卡的攻击力直到回合结束时上升这个效果回到手卡的卡数量×500。
function c70583986.initial_effect(c)
	-- 设置同调召唤手续：调整+调整以外的水属性怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WATER),1)
	c:EnableReviveLimit()
	-- ①：以自己场上的其他的表侧表示卡任意数量为对象才能发动。那些自己的表侧表示卡回到手卡。这张卡的攻击力直到回合结束时上升这个效果回到手卡的卡数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70583986,0))  --"返回手牌，攻击上升"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,70583986)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c70583986.target)
	e1:SetOperation(c70583986.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示且能回到手牌的卡
function c70583986.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果①的发动准备与目标选择
function c70583986.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c70583986.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己场上是否存在至少1张除自身以外的、表侧表示且能回到手牌的卡作为对象
	if chk==0 then return Duel.IsExistingTarget(c70583986.filter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上除自身以外的1到12张表侧表示卡片作为对象
	local g=Duel.SelectTarget(tp,c70583986.filter,tp,LOCATION_ONFIELD,0,1,12,e:GetHandler())
	-- 设置效果处理信息：将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 过滤条件：属于自己且在场上表侧表示的卡
function c70583986.thfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp)
end
-- 效果①的效果处理：将对象卡片送回手牌，并根据返回数量提升自身攻击力
function c70583986.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetTargetsRelateToChain()
	local rg=tg:Filter(c70583986.thfilter,nil,tp)
	-- 将符合条件的对象卡片因效果返回持有者手牌
	Duel.SendtoHand(rg,nil,REASON_EFFECT)
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 中断当前效果处理，使后续的攻击力上升处理不与返回手牌同时进行
		Duel.BreakEffect()
		-- 获取上一步实际操作（返回手牌）的卡片组
		local og=Duel.GetOperatedGroup()
		local ct=og:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		if ct>0 then
			-- 这张卡的攻击力直到回合结束时上升这个效果回到手卡的卡数量×500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			e1:SetValue(ct*500)
			c:RegisterEffect(e1)
		end
	end
end
