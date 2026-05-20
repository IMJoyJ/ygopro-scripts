--Vivid Tail
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1张卡为对象才能发动。那张卡回到持有者手卡。
-- ②：这张卡在墓地存在的场合，以自己场上1张表侧表示的卡为对象才能发动。这张卡在自己场上盖放，那张表侧表示的卡回到持有者手卡。这个效果盖放的这张卡从场上离开的场合除外。这个回合，自己不能把这个效果回到手卡的卡以及那些同名卡的效果发动。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（场上卡回手）和②效果（墓地自身盖放、场上表侧卡回手）
function s.initial_effect(c)
	-- ①：以自己场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1张表侧表示的卡为对象才能发动。这张卡在自己场上盖放，那张表侧表示的卡回到持有者手卡。这个效果盖放的这张卡从场上离开的场合除外。这个回合，自己不能把这个效果回到手卡的卡以及那些同名卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备与目标选择，确认场上是否存在可回手的卡并将其设为效果对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and chkc:IsAbleToHand() and chkc~=c end
	-- 检查自己场上是否存在除这张卡以外、可以返回持有者手卡的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,1,c) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1张可以返回手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置效果处理信息，表示该连锁将把选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的执行函数，将作为对象的卡送回持有者手牌
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上表侧表示且能返回手牌的卡
function s.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- ②效果的发动准备与目标选择，确认自己场上是否有表侧表示可回手的卡，且墓地的这张卡是否可以盖放
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() and s.thfilter(chkc) end
	-- 检查自己场上是否存在表侧表示且可以返回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and e:GetHandler():IsSSetable() end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1张表侧表示且可以返回手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果处理信息，表示该连锁将把选中的卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果处理信息，表示该连锁涉及将墓地的这张卡移出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果的执行函数，将墓地的这张卡盖放，并将作为对象的卡送回手牌，同时适用离场除外和同名卡效果发动限制
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果相关，并成功在自己场上盖放
	if c:IsRelateToEffect(e) and Duel.SSet(tp,c)>0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
		-- 获取被选为效果对象的表侧表示卡片
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup()
			-- 成功将目标卡片送回手牌，且该卡确实到达了手牌
			and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
			-- 这个回合，自己不能把这个效果回到手卡的卡以及那些同名卡的效果发动。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetTargetRange(1,0)
			e2:SetValue(s.aclimit)
			e2:SetLabel(tc:GetCode())
			e2:SetReset(RESET_PHASE+PHASE_END)
			-- 给玩家注册该回合内不能发动同名卡效果的限制
			Duel.RegisterEffect(e2,tp)
		end
	end
end
-- 限制发动的判定函数，阻止玩家发动与回到手牌的卡同名的卡片效果
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
