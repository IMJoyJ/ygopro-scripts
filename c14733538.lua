--竜呼相打つ
-- 效果：
-- 「龙呼相争」在1回合只能发动1张。
-- ①：从卡组选1只「龙剑士」灵摆怪兽和1只「龙魔王」灵摆怪兽给对方观看，对方从那之中随机选1只。对方选的灵摆怪兽在自己的灵摆区域放置或特殊召唤。剩下的灵摆怪兽表侧表示加入自己的额外卡组。
function c14733538.initial_effect(c)
	-- 「龙呼相争」在1回合只能发动1张。
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
-- 过滤函数，用于筛选满足条件的灵摆怪兽
function c14733538.filter(c,e,tp,b1,setcode)
	return c:IsSetCard(setcode) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
		and (b1 or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 计算发动时可放置的灵摆区域
function c14733538.zones(e,tp,eg,ep,ev,re,r,rp)
	local zone=0xff
	-- 检查玩家场上灵摆区0是否可用
	local p0=Duel.CheckLocation(tp,LOCATION_PZONE,0)
	-- 检查玩家场上灵摆区1是否可用
	local p1=Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 检查玩家场上主要怪兽区是否有空位
	local sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在满足条件的「龙剑士」灵摆怪兽
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,false,0xc7)
		-- 检查卡组是否存在满足条件的「龙魔王」灵摆怪兽
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,false,0xda)
	if p0==p1 or sp then return zone end
	if p0 then zone=zone-0x1 end
	if p1 then zone=zone-0x10 end
	return zone
end
-- 效果处理函数，用于判断是否可以发动此效果
function c14733538.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否拥有可用的灵摆区域
	local b1=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 判断玩家是否拥有可用的主要怪兽区
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then return (b1 or b2)
		-- 检查卡组是否存在满足条件的「龙剑士」灵摆怪兽
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,b1,0xc7)
		-- 检查卡组是否存在满足条件的「龙魔王」灵摆怪兽
		and Duel.IsExistingMatchingCard(c14733538.filter,tp,LOCATION_DECK,0,1,nil,e,tp,b1,0xda) end
	-- 设置连锁操作信息，指定将要送入额外卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
-- 效果发动处理函数，执行效果的主要逻辑
function c14733538.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家是否拥有可用的灵摆区域
	local b1=Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	-- 判断玩家是否拥有可用的主要怪兽区
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if not b1 and not b2 then return end
	-- 获取卡组中所有满足条件的「龙剑士」灵摆怪兽
	local g1=Duel.GetMatchingGroup(c14733538.filter,tp,LOCATION_DECK,0,nil,e,tp,b1,0xc7)
	-- 获取卡组中所有满足条件的「龙魔王」灵摆怪兽
	local g2=Duel.GetMatchingGroup(c14733538.filter,tp,LOCATION_DECK,0,nil,e,tp,b1,0xda)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	-- 提示玩家选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg1=g1:Select(tp,1,1,nil)
	-- 提示玩家选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	-- 向对方确认选择的卡
	Duel.ConfirmCards(1-tp,sg1)
	-- 将玩家卡组洗切
	Duel.ShuffleDeck(tp)
	local cg=sg1:Select(1-tp,1,1,nil)
	local tc=cg:GetFirst()
	-- 提示对方选择了某张卡
	Duel.Hint(HINT_CARD,0,tc:GetCode())
	-- 判断是否将选择的卡放置于灵摆区或特殊召唤
	if b1 and (not b2 or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or Duel.SelectOption(tp,1160,1152)==0) then
		-- 将卡移动到玩家的灵摆区域
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	else
		-- 将卡特殊召唤到玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	sg1:RemoveCard(tc)
	-- 将剩余的卡表侧表示加入玩家的额外卡组
	Duel.SendtoExtraP(sg1,nil,REASON_EFFECT)
end
