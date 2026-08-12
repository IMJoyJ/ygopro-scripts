--EMスカイ・マジシャン
-- 效果：
-- 「娱乐伙伴 天空魔术家」的②的效果1回合只能使用1次。
-- ①：1回合1次，自己把魔法卡发动的场合发动。这张卡的攻击力上升300。
-- ②：以自己场上1张永续魔法卡为对象才能发动。那张卡回到持有者手卡。那之后，可以从手卡把1张「魔术师」永续魔法卡发动。这个效果在对方回合也能发动。
-- ③：表侧表示的这张卡从场上离开的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c73734821.initial_effect(c)
	-- ①：1回合1次，自己把魔法卡发动的场合发动。这张卡的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73734821,0))  --"这张卡攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c73734821.atkcon)
	e1:SetOperation(c73734821.atkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(73734821)
	c:RegisterEffect(e2)
	-- ②：以自己场上1张永续魔法卡为对象才能发动。那张卡回到持有者手卡。那之后，可以从手卡把1张「魔术师」永续魔法卡发动。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(73734821,1))  --"自己永续魔法卡回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,73734821)
	e3:SetTarget(c73734821.thtg)
	e3:SetOperation(c73734821.thop)
	c:RegisterEffect(e3)
	-- ③：表侧表示的这张卡从场上离开的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(73734821,3))  --"场上卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(c73734821.descon)
	e4:SetTarget(c73734821.destg)
	e4:SetOperation(c73734821.desop)
	c:RegisterEffect(e4)
end
-- 判定发动条件：是否为自己发动的魔法卡的效果发动
function c73734821.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and rp==tp
end
-- 效果处理：使这张卡的攻击力上升300
function c73734821.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件：自己场上表侧表示且能回到手牌的永续魔法卡
function c73734821.thfilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsAbleToHand()
end
-- 判定效果发动并选择自己场上1张表侧表示的永续魔法卡作为对象
function c73734821.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c73734821.thfilter(chkc) end
	-- 判定自己场上是否存在符合条件的永续魔法卡
	if chk==0 then return Duel.IsExistingTarget(c73734821.thfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1张表侧表示的永续魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c73734821.thfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 设置操作信息：将选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤条件：手牌中可以发动的「魔术师」永续魔法卡
function c73734821.tffilter(c,tp)
	return c:IsSetCard(0x98) and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:GetActivateEffect():IsActivatable(tp,true)
end
-- 效果处理：将对象卡片送回手牌，并可以从手牌发动1张「魔术师」永续魔法卡
function c73734821.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片仍适用效果，则将其送回持有者手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		-- 获取手牌中所有符合条件的「魔术师」永续魔法卡
		local g=Duel.GetMatchingGroup(c73734821.tffilter,tp,LOCATION_HAND,0,nil,tp)
		-- 若手牌有符合条件的卡，询问玩家是否发动「魔术师」永续魔法卡
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(73734821,2)) then  --"是否把「魔术师」永续魔法卡发动？"
			-- 中断当前效果处理，使后续的发动处理与回手牌不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要放置到场上的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local sc=g:Select(tp,1,1,nil):GetFirst()
			-- 将选中的「魔术师」永续魔法卡以表侧表示移动到自己的魔法与陷阱区域
			Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			local te=sc:GetActivateEffect()
			local tep=sc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			-- 触发卡片发动的相关时点事件
			Duel.RaiseEvent(sc,73734821,te,0,tp,tp,Duel.GetCurrentChain())
		end
	end
end
-- 判定发动条件：这张卡离场前是否为表侧表示
function c73734821.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 判定效果发动并选择场上1张卡作为对象
function c73734821.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判定场上是否存在可以作为对象的卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏的对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏作为对象的卡片
function c73734821.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为破坏对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏作为对象的卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
