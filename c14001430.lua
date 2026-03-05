--マドルチェ・シャトー
-- 效果：
-- ①：作为这张卡的发动时的效果处理，自己墓地有「魔偶甜点」怪兽存在的场合，那些全部回到卡组。
-- ②：只要这张卡在场地区域存在，场上的「魔偶甜点」怪兽的攻击力·守备力上升500。
-- ③：「魔偶甜点」怪兽的效果让自己墓地的怪兽回到卡组的场合，也能不回到卡组回到手卡。
function c14001430.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，自己墓地有「魔偶甜点」怪兽存在的场合，那些全部回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14001430.target)
	e1:SetOperation(c14001430.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在场地区域存在，场上的「魔偶甜点」怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 过滤出满足条件的「魔偶甜点」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x71))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：「魔偶甜点」怪兽的效果让自己墓地的怪兽回到卡组的场合，也能不回到卡组回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetTarget(c14001430.reptg)
	e4:SetValue(c14001430.repval)
	c:RegisterEffect(e4)
end
-- 用于筛选墓地中的「魔偶甜点」怪兽
function c14001430.tdfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x71) and c:IsAbleToDeck()
end
-- 效果处理时的处理函数，用于设置发动时的处理目标
function c14001430.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取满足条件的墓地中的「魔偶甜点」怪兽组
	local g=Duel.GetMatchingGroup(c14001430.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 设置连锁操作信息，确定要处理的卡组及数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理时的处理函数，用于执行发动时的效果
function c14001430.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的墓地中的「魔偶甜点」怪兽组
	local g=Duel.GetMatchingGroup(c14001430.tdfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查是否受到奈落的葬列影响，若存在则取消效果处理
	if aux.NecroValleyNegateCheck(g) then return end
	if g:GetCount()>0 then
		-- 将满足条件的怪兽送回卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 用于筛选符合条件的墓地怪兽
function c14001430.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:GetDestination()==LOCATION_DECK and c:IsType(TYPE_MONSTER)
		and c:IsAbleToHand()
end
-- 用于判断是否可以发动「魔偶甜点城堡」的效果
function c14001430.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return bit.band(r,REASON_EFFECT)~=0 and re and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsSetCard(0x71) and eg:IsExists(c14001430.repfilter,1,nil,tp) end
	-- 提示玩家选择是否使用「魔偶甜点城堡」的效果
	if Duel.SelectYesNo(tp,aux.Stringid(14001430,0)) then  --"是否使用「魔偶甜点城堡」的效果？"
		local g=eg:Filter(c14001430.repfilter,nil,tp)
		local ct=g:GetCount()
		if ct>1 then
			-- 提示玩家选择要返回手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			g=g:Select(tp,1,ct,nil)
		end
		local tc=g:GetFirst()
		while tc do
			-- 将目标怪兽的效果改为送回手牌而非卡组
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TO_DECK_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(LOCATION_HAND)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(14001430,RESET_EVENT+0x1de0000+RESET_PHASE+PHASE_END,0,1)
			tc=g:GetNext()
		end
		-- 注册一个用于处理返回手牌效果的持续效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e1:SetCode(EVENT_TO_HAND)
		e1:SetCountLimit(1)
		e1:SetCondition(c14001430.thcon)
		e1:SetOperation(c14001430.thop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果给玩家
		Duel.RegisterEffect(e1,tp)
		return true
	else return false end
end
-- 返回值函数，用于设置替换效果的返回值
function c14001430.repval(e,c)
	return false
end
-- 用于筛选具有标记的怪兽
function c14001430.thfilter(c)
	return c:GetFlagEffect(14001430)~=0
end
-- 用于判断是否触发返回手牌效果
function c14001430.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14001430.thfilter,1,nil)
end
-- 用于处理返回手牌效果的后续处理
function c14001430.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c14001430.thfilter,nil)
	-- 确认玩家手牌中的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切玩家手牌
	Duel.ShuffleHand(tp)
end
