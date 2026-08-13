--竜呼相打つ
-- 效果：
-- 「龙呼相争」在1回合只能发动1张。
-- ①：从卡组选1只「龙剑士」灵摆怪兽和1只「龙魔王」灵摆怪兽给对方观看，对方从那之中随机选1只。对方选的灵摆怪兽在自己的灵摆区域放置或特殊召唤。剩下的灵摆怪兽表侧表示加入自己的额外卡组。
function c14733538.initial_effect(c)
	-- 「龙呼相争」在1回合只能发动1张。①：从卡组选1只「龙剑士」灵摆怪兽和1只「龙魔王」灵摆怪兽给对方观看，对方从那之中随机选1只。对方选的灵摆怪兽在自己的灵摆区域放置或特殊召唤。剩下的灵摆怪兽表侧表示加入自己的额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCountLimit(1,14733538+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14733538.target)
	e1:SetOperation(c14733538.activate)
	e1:SetValue(c14733538.zones)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断卡组中的卡是否可作为候选——属于指定系列（「龙剑士」或「龙魔王」）的灵摆怪兽、未被禁止，并且（灵摆区有空位时可直接放置，或可以被特殊召唤）。
function c14733538.filter(c,e,tp,b1,setcode)
	return c:IsSetCard(setcode) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
		and (b1 or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 区域限制函数（配合EFFECT_FLAG_LIMIT_ZONE）：计算本卡发动时可使用的区域。若两个灵摆区都可用，或存在可特殊召唤的怪兽区空位，则不限制（返回全区域）；否则只返回当前可用的灵摆区位置，使卡只能在可用灵摆区发动。
function c14733538.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	-- 检查自己左侧灵摆区（PZONE 0号位）是否为空位可用。
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	-- 检查自己右侧灵摆区（PZONE 1号位）是否为空位可用。
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 检查自己的主要怪兽区是否有空位，以判断是否能特殊召唤。
	local sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只符合条件的「龙剑士」灵摆怪兽（此处以false作为b1，要求可作为特殊召唤对象）。
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,false,0xc7)
		-- 检查卡组中是否存在至少1只符合条件的「龙魔王」灵摆怪兽（此处以false作为b1，要求可作为特殊召唤对象）。
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,false,0xda)
	if p0==p1 or sp then return zone end
	if p0 then zone=zone-0x1 end
	if p1 then zone=zone-0x10 end
	return zone
end
-- 效果发动判定及操作信息登记：当自己灵摆区或主要怪兽区有空位，且卡组中存在至少1只符合条件的「龙剑士」与「龙魔王」灵摆怪兽时允许发动；发动时登记“卡组中的卡加入额外卡组”的操作信息。
function c14733538.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区（左或右）是否有可用空位，用于放置灵摆怪兽。
	local b1=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 检查自己的主要怪兽区是否有空位，用于特殊召唤。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return (b1 or b2)
		-- 检查卡组中是否存在至少1只符合条件的「龙剑士」灵摆怪兽；b1表示若灵摆区有空位，则不要求可特殊召唤。
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,b1,0xc7)
		-- 检查卡组中是否存在至少1只符合条件的「龙魔王」灵摆怪兽；b1表示若灵摆区有空位，则不要求可特殊召唤。
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,b1,0xda) end
	-- 设置操作信息：效果处理中会将卡组中的1张卡加入额外卡组（CATEGORY_TOEXTRA），供连锁判定和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组各选1只「龙剑士」「龙魔王」灵摆怪兽给对方确认，对方随机选1只；选中的卡根据条件放置到自己的灵摆区或特殊召唤，剩下的一张表侧加入自己的额外卡组。
function c14733538.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区（左或右）是否有可用空位，用于放置灵摆怪兽。
	local b1=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 检查自己的主要怪兽区是否有空位，用于特殊召唤。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if not b1 and not b2 then return end
	-- 从卡组中筛选出所有符合条件的「龙剑士」灵摆怪兽，作为可选集合g1。
	local g1=Duel.GetMatchingGroup(c14733538.filter,tp,LOCATION_DECK,0,nil,e,tp,b1,0xc7)
	-- 从卡组中筛选出所有符合条件的「龙魔王」灵摆怪兽，作为可选集合g2。
	local g2=Duel.GetMatchingGroup(c14733538.filter,tp,LOCATION_DECK,0,nil,e,tp,b1,0xda)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 设置选择提示文本为“请选择给对方确认的卡”，用于随后从「龙剑士」灵摆怪兽中选择1张展示给对方。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local sg1=g1:Select(tp,1,1,nil)
	-- 设置选择提示文本为“请选择给对方确认的卡”，用于随后从「龙魔王」灵摆怪兽中选择1张展示给对方。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	-- 将从卡组选出的两张灵摆怪兽（g1+g2）展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,sg1)
	-- 因为从卡组取出了卡片，洗切发动者的卡组，保持卡组随机性。
	Duel.ShuffleDeck(tp)
	local cg=sg1:Select(1-tp,1,1,nil)
	local tc=cg:GetFirst()
	-- 向双方展示对方随机选中的那只灵摆怪兽，以卡片动画的形式提示。
	Duel.Hint(HINT_CARD,0,tc:GetCode())
	-- 决定对方所选灵摆怪兽的处理方式：若有灵摆区空位，且（无怪兽区空位/该卡不能特殊召唤/发动者选择放置到灵摆区）时，将其放置到灵摆区；否则将其特殊召唤。
	if b1 and (not b2 or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectOption(tp,1160,1152)==0) then
		-- 将对方选中的灵摆怪兽表侧表示放置到自己的灵摆区（由自己控制）。
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	else
		-- 将对方选中的灵摆怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	sg1:RemoveCard(tc)
	-- 将剩下的一张灵摆怪兽（未被对方选中的那张）表侧表示加入持有者的额外卡组（即自己的额外卡组）。
	Duel.SendtoExtraP(sg1,nil,REASON_EFFECT)
end
