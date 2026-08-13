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
-- 过滤函数：筛选出符合「甲虫装机」字段（0x56）、类型为怪兽且未被禁止的卡，作为①效果可选的装备对象。
function c21790410.filter(c)
	return c:IsSetCard(0x56) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ①效果的发动判定：检查自己魔陷区是否有空位，且手牌·墓地是否存在1只以上符合条件的「甲虫装机」怪兽。
function c21790410.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己魔陷区是否有可用的空格，确保能将选中的怪兽作为装备卡装备。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手牌·墓地是否存在至少1张满足c21790410.filter的「甲虫装机」怪兽。
		and Duel.IsExistingMatchingCard(c21790410.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 设置本次连锁的操作信息：将会有1张手牌·墓地的卡被移动（涉及墓地时标记CATEGORY_LEAVE_GRAVE），以便正确触发相关效果。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ①效果的实际处理：若魔陷区仍有空位且本卡状态正常，则从手牌·墓地选择1只符合条件的「甲虫装机」怪兽，使用Duel.Equip将其装备给本卡；若从墓地选择则受王家长眠之谷影响过滤；装备成功后为装备卡注册只能装备给本卡的限制效果。
function c21790410.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认魔陷区仍有空格，否则直接停止处理，避免因场地变化导致装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 向玩家显示选择装备卡的提示消息，提示类型为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己的手牌·墓地选择1只符合条件的「甲虫装机」怪兽；使用aux.NecroValleyFilter过滤掉受王家长眠之谷影响不能从墓地选卡的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c21790410.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的「甲虫装机」怪兽作为装备卡装备给本卡；若装备失败则中止处理。
		if not Duel.Equip(tp,tc,c) then return end
		-- 当作装备卡使用给这张卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c21790410.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制的判定函数：仅当尝试装备的目标怪兽是效果的持有者（即这张蜈蚣）时允许装备，保证装备卡不会错误装备到其他怪兽。
function c21790410.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤函数：判断一张已离场卡是否满足“曾装备给这张蜈蚣且被送去自己墓地”的条件（位于墓地、控制者为发动玩家、装备对象为本卡），用于②效果的触发判定。
function c21790410.cfilter(c,ec,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:GetEquipTarget()==ec
end
-- ②效果的发动条件：本次离场事件（eg）中存在至少1张曾装备给这张蜈蚣并被送去自己墓地的卡。
function c21790410.shcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21790410.cfilter,1,nil,e:GetHandler(),tp)
end
-- 过滤函数：筛选卡组中符合「甲虫装机」字段（0x56）且能够加入手卡的卡，作为②效果可检索的对象。
function c21790410.tgfilter(c)
	return c:IsSetCard(0x56) and c:IsAbleToHand()
end
-- ②效果的发动判定：本卡仍与效果关联（仍在场上/效果有效），且卡组中存在至少1张符合条件的「甲虫装机」卡可加入手卡。
function c21790410.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		-- 检查卡组中是否存在至少1张满足c21790410.tgfilter的「甲虫装机」卡。
		and Duel.IsExistingMatchingCard(c21790410.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：效果将把1张卡从卡组加入手卡（CATEGORY_TOHAND），用于相关发动的检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：从卡组选择1张符合条件的「甲虫装机」卡加入持有者手卡，并向对方展示该卡。
function c21790410.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择要加入手卡的卡的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合c21790410.tgfilter的「甲虫装机」卡。
	local g=Duel.SelectMatchingCard(tp,c21790410.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「甲虫装机」卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡向对方玩家展示，使对方确认加入手卡的卡片信息。
		Duel.ConfirmCards(1-tp,g)
	end
end
