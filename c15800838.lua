--マインドクラッシュ
-- 效果：
-- ①：宣言1个卡名才能发动。宣言的卡在对方手卡的场合，对方把手卡的那卡全部丢弃。宣言的卡不在对方手卡的场合，自己手卡随机选1张丢弃。
function c15800838.initial_effect(c)
	-- 效果发动条件设置
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetTarget(c15800838.target)
	e1:SetOperation(c15800838.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时点检查
function c15800838.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认己方手牌数量大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		-- 确认己方手牌中存在至少1张卡
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家宣言卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 玩家宣言一个卡名
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 将宣言的卡名设为效果参数
	Duel.SetTargetParam(ac)
	-- 设置连锁操作信息为宣言卡名
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 效果处理函数
function c15800838.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中宣言的卡名
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 检索己方手牌中与宣言卡名相同的卡
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_HAND,nil,ac)
	if g:GetCount()>0 then
		-- 将符合条件的卡送入墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	else
		-- 获取己方所有手牌
		local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local dg=sg:RandomSelect(tp,1)
		-- 将随机选中的卡送入墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
