--竜呼相打つ
-- 效果：
-- 「龙呼相争」在1回合只能发动1张。
-- ①：从卡组选1只「龙剑士」灵摆怪兽和1只「龙魔王」灵摆怪兽给对方观看，对方从那之中随机选1只。对方选的灵摆怪兽在自己的灵摆区域放置或特殊召唤。剩下的灵摆怪兽表侧表示加入自己的额外卡组。
function c14733538.initial_effect(c)
	-- 「龙呼相争」在1回合只能发动1张。 ①：从卡组选1只「龙剑士」灵摆怪兽和1只「龙魔王」灵摆怪兽给对方观看，对方从那之中随机选1只。对方选的灵摆怪兽在自己的灵摆区域放置或特殊召唤。剩下的灵摆怪兽表侧表示加入自己的额外卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCountLimit(1,14733538+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c14733538.target)
	e1:SetOperation(c14733538.activate)
	e1:SetValue(c14733538.zones)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查卡组中是否为未被禁止的指定字段灵摆怪兽，且灵摆区有空位或该怪兽可以特殊召唤
function c14733538.filter(c,e,tp,b1,setcode)
	return c:IsSetCard(setcode) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
		and (b1 or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 限制发动区域，若仅有一侧灵摆区空着且无法从卡组特殊召唤对应怪兽，则禁止将此卡发动在空着的一侧灵摆区
function c14733538.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	-- 检查自己左侧灵摆区域是否可用
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	-- 检查自己右侧灵摆区域是否可用
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 检查自己怪兽区是否有空位，以及卡组中是否同时存在可特殊召唤的「龙剑士」与「龙魔王」灵摆怪兽
	local sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在1只可特殊召唤的「龙剑士」灵摆怪兽
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,false,0xc7)
		-- 检查卡组中是否存在1只可特殊召唤的「龙魔王」灵摆怪兽
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,false,0xda)
	if p0==p1 or sp then return zone end
	if p0 then zone=zone-0x1 end
	if p1 then zone=zone-0x10 end
	return zone
end
-- 发动条件检查，确认自己灵摆区或怪兽区有空位且卡组同时存在符合条件的「龙剑士」与「龙魔王」灵摆怪兽
function c14733538.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域是否至少有1个空位
	local b1=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 检查自己怪兽区域是否有空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return (b1 or b2)
		-- 检查卡组中是否存在满足放置或特殊召唤条件的「龙剑士」灵摆怪兽
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,b1,0xc7)
		-- 检查卡组中是否存在满足放置或特殊召唤条件的「龙魔王」灵摆怪兽
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,b1,0xda) end
	-- 设置将卡组1张卡加入额外卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 效果处理，从卡组选「龙剑士」与「龙魔王」灵摆怪兽各1只给对方确认，对方随机选1只放置于灵摆区或特殊召唤，另1只表侧表示加入额外卡组
function c14733538.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己灵摆区域是否有空位
	local b1=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 效果处理时再次确认自己怪兽区域是否有空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if not b1 and not b2 then return end
	-- 获取卡组中所有满足条件的「龙剑士」灵摆怪兽
	local g1=Duel.GetMatchingGroup(c14733538.filter,tp,LOCATION_DECK,0,nil,e,tp,b1,0xc7)
	-- 获取卡组中所有满足条件的「龙魔王」灵摆怪兽
	local g2=Duel.GetMatchingGroup(c14733538.filter,tp,LOCATION_DECK,0,nil,e,tp,b1,0xda)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 提示控制者选择给对方确认的「龙剑士」灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local sg1=g1:Select(tp,1,1,nil)
	-- 提示控制者选择给对方确认的「龙魔王」灵摆怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	-- 向对方展示选出的2只灵摆怪兽
	Duel.ConfirmCards(1-tp,sg1)
	-- 洗切自己的卡组
	Duel.ShuffleDeck(tp)
	local cg=sg1:Select(1-tp,1,1,nil)
	local tc=cg:GetFirst()
	-- 提示并显示对方选中的灵摆怪兽卡片信息
	Duel.Hint(HINT_CARD,0,tc:GetCode())
	-- 判断将选中的怪兽放置到灵摆区域还是特殊召唤（灵摆区有空且无法特召或玩家选择放置时则放置）
	if b1 and (not b2 or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectOption(tp,1160,1152)==0) then
		-- 将对方选中的灵摆怪兽表侧表示放置到自己的灵摆区域
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	else
		-- 将对方选中的灵摆怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	sg1:RemoveCard(tc)
	-- 将剩下的另1只灵摆怪兽表侧表示加入自己的额外卡组
	Duel.SendtoExtraP(sg1,nil,REASON_EFFECT)
end
