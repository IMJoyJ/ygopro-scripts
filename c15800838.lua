--マインドクラッシュ
-- 效果：
-- ①：宣言1个卡名才能发动。宣言的卡在对方手卡的场合，对方把手卡的那卡全部丢弃。宣言的卡不在对方手卡的场合，自己手卡随机选1张丢弃。
function c15800838.initial_effect(c)
	-- ①：宣言1个卡名才能发动。宣言的卡在对方手卡的场合，对方把手卡的那卡全部丢弃。宣言的卡不在对方手卡的场合，自己手卡随机选1张丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_HANDES_OPPO)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND)
	e1:SetTarget(c15800838.target)
	e1:SetOperation(c15800838.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件的目标过滤检查：要求对方手卡数量大于0且自己手卡数量大于0
function c15800838.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动检查阶段判断对方手卡数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		-- 并且判断自己手卡中是否至少存在1张卡
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家宣言一个卡名
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	getmetatable(e:GetHandler()).announce_filter={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT}
	-- 让玩家宣言一个卡名（排除融合、同调、超量、连接等无法存放在手卡中的额外卡片）
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	-- 保存玩家宣言的卡名作为连锁的效果参数
	Duel.SetTargetParam(ac)
	-- 设置当前连锁的操作信息为宣言卡名
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
-- 定义效果处理函数：获取宣言卡名，若在对方手卡中则将其全部丢弃，不在则随机丢弃自己1张手卡
function c15800838.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在连锁中保存的宣言卡名参数
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 获取对方手卡中与宣言卡名相同的卡片组
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_HAND,nil,ac)
	if g:GetCount()>0 then
		-- 对方将手卡中的这些卡全部因效果丢弃送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	else
		-- 获取自己手卡中的所有卡片
		local sg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
		local dg=sg:RandomSelect(tp,1)
		-- 将自己随机选出的1张手卡因效果丢弃送去墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
