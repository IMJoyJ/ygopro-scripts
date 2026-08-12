--甲虫装機 センチピード
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只「甲虫装机」怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡在自己场上存在，给这张卡装备的卡被送去自己墓地的场合才能发动。从卡组把1张「甲虫装机」卡加入手卡。
-- ③：把这张卡当作装备卡使用来装备的怪兽的等级上升3星。
function c21790410.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。从自己的手卡·墓地选1只「甲虫装机」怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21790410,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c21790410.eqtg)
	e1:SetOperation(c21790410.eqop)
	c:RegisterEffect(e1)
	-- ③：把这张卡当作装备卡使用来装备的怪兽的等级上升3星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetValue(3)
	c:RegisterEffect(e2)
	-- ②：这张卡在自己场上存在，给这张卡装备的卡被送去自己墓地的场合才能发动。从卡组把1张「甲虫装机」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21790410,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c21790410.shcon)
	e3:SetTarget(c21790410.shtg)
	e3:SetOperation(c21790410.shop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选「甲虫装机」怪兽（不包括被禁止的怪兽）
function c21790410.filter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果处理时的条件判断，检查是否满足装备条件
function c21790410.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家手牌或墓地是否存在符合条件的「甲虫装机」怪兽
		and Duel.IsExistingMatchingCard(c21790410.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置效果处理信息，表示将要从墓地或手牌中选择一张卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 装备效果的处理函数，执行装备操作
function c21790410.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家场上是否有足够的魔法陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的「甲虫装机」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c21790410.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将选中的怪兽装备给当前卡
		if not Duel.Equip(tp,tc,c) then return end
		-- 设置装备限制效果，确保只有当前卡能装备该怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c21790410.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制效果的判断函数，确保只能装备给当前卡
function c21790410.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 用于判断装备卡是否被送入墓地的过滤函数
function c21790410.cfilter(c,ec,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:GetEquipTarget()==ec
end
-- 触发效果的条件判断，检查是否有装备卡被送入墓地
function c21790410.shcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21790410.cfilter,1,nil,e:GetHandler(),tp)
end
-- 用于检索「甲虫装机」卡的过滤函数
function c21790410.tgfilter(c)
	return c:IsSetCard(0x56) and c:IsAbleToHand()
end
-- 检索效果的处理函数，判断是否满足检索条件
function c21790410.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		-- 检查玩家卡组中是否存在符合条件的「甲虫装机」卡
		and Duel.IsExistingMatchingCard(c21790410.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，表示将要从卡组中检索一张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，执行检索操作
function c21790410.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的「甲虫装机」卡
	local g=Duel.SelectMatchingCard(tp,c21790410.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
