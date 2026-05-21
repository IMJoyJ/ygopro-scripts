--精霊術の使い手
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：丢弃1张手卡才能发动。从卡组选「灵使」怪兽、「凭依装着」怪兽、「凭依」魔法·陷阱卡之内2张（同名卡最多1张）。那之内的1张加入手卡，另1张在自己场上盖放。
function c91530236.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：丢弃1张手卡才能发动。从卡组选「灵使」怪兽、「凭依装着」怪兽、「凭依」魔法·陷阱卡之内2张（同名卡最多1张）。那之内的1张加入手卡，另1张在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_MSET+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,91530236+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c91530236.cost)
	e1:SetTarget(c91530236.target)
	e1:SetOperation(c91530236.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理函数：丢弃1张手卡
function c91530236.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的可丢弃卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：检查卡片是否为「灵使」怪兽、「凭依装着」怪兽或「凭依」魔法·陷阱卡
function c91530236.filter(c)
	return c:IsSetCard(0xbf) and c:IsType(TYPE_MONSTER)
		or c:IsSetCard(0x10c0) and c:IsType(TYPE_MONSTER)
		or c:IsSetCard(0xc0) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤函数：检查卡片是否能加入手卡，且卡组中存在另一张不同名的可盖放卡片
function c91530236.thfilter(c,e,tp,mft,sft)
	return c91530236.filter(c) and c:IsAbleToHand()
		-- 检查卡组中是否存在另一张满足盖放条件且与第一张卡不同名的卡片
		and Duel.IsExistingMatchingCard(c91530236.setfilter,tp,LOCATION_DECK,0,1,c,e,tp,mft,sft,c:GetCode())
end
-- 过滤函数：检查卡片是否与第一张卡不同名，且满足在魔陷区盖放或在怪兽区里侧特殊召唤的条件
function c91530236.setfilter(c,e,tp,mft,sft,code)
	return c91530236.filter(c) and not c:IsCode(code)
		and (sft>0 and c:IsSSetable(true) or mft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
end
-- 效果发动准备（Target）处理函数：检查卡组中是否存在满足条件的2张卡，并设置操作信息
function c91530236.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上可用的怪兽区域数量
		local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 获取自己场上可用的魔法·陷阱区域数量
		local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then sft=sft-1 end
		-- 检查卡组中是否存在满足检索和盖放条件的卡片组合
		return Duel.IsExistingMatchingCard(c91530236.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,mft,sft)
	end
	-- 设置效果处理信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理（Operation）函数：从卡组选2张满足条件的卡，1张加入手卡，另1张在场上盖放
function c91530236.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local mft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己场上可用的魔法·陷阱区域数量
	local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择第1张卡（加入手卡的卡）
	local tc1=Duel.SelectMatchingCard(tp,c91530236.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mft,sft):GetFirst()
	if tc1 then
		-- 提示玩家选择要盖放的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让玩家从卡组选择第2张卡（盖放的卡，不能与第1张卡同名）
		local tc2=Duel.SelectMatchingCard(tp,c91530236.setfilter,tp,LOCATION_DECK,0,1,1,tc1,e,tp,mft,sft,tc1:GetCode()):GetFirst()
		-- 将第1张卡加入玩家手卡
		Duel.SendtoHand(tc1,nil,REASON_EFFECT)
		if tc2:IsType(TYPE_MONSTER) then
			-- 如果是怪兽卡，则在自己场上里侧守备表示特殊召唤（盖放）
			Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		else
			-- 如果是魔法·陷阱卡，则在自己场上盖放
			Duel.SSet(tp,tc2,tp,false)
		end
		-- 向对方玩家展示这两张卡片进行确认
		Duel.ConfirmCards(1-tp,Group.FromCards(tc1,tc2))
	end
end
