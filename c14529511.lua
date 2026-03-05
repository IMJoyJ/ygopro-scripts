--冥骸王－メメントラン・テクトリカ
-- 效果：
-- 「莫忘」怪兽×3
-- 这个卡名的①②③的效果1回合各能使用1次，①②的效果在同一连锁上不能发动。
-- ①：这张卡融合召唤的场合才能发动。从卡组·额外卡组把3张「莫忘」卡送去墓地。
-- ②：自己·对方回合，以自己场上的「莫忘」怪兽和对方场上的卡各相同数量为对象才能发动。那些卡破坏。
-- ③：把墓地的这张卡除外才能发动。从卡组把1张「冥骸府-莫忘冥府」加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册融合召唤手续并创建三个效果
function s.initial_effect(c)
	-- 记录该卡拥有「冥骸府-莫忘冥府」的卡名
	aux.AddCodeList(c,43338320)
	-- 设置该卡融合召唤时需要3个「莫忘」怪兽作为素材
	aux.AddFusionProcFunRep(c,s.ffilter,3,true)
	c:EnableReviveLimit()
	-- ①：这张卡融合召唤的场合才能发动。从卡组·额外卡组把3张「莫忘」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，以自己场上的「莫忘」怪兽和对方场上的卡各相同数量为对象才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"场上卡片破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。从卡组把1张「冥骸府-莫忘冥府」加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"卡组检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	-- 效果发动时需要将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤函数，判断是否为「莫忘」系列怪兽
function s.ffilter(c)
	return c:IsFusionSetCard(0x1a1)
end
-- 效果①的发动条件，判断是否为融合召唤
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①中用于检索「莫忘」卡的过滤函数
function s.filter(c)
	return c:IsSetCard(0x1a1) and c:IsAbleToGrave()
end
-- 效果①的发动时处理，检查是否满足条件并设置操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动条件，即是否有3张「莫忘」卡可送去墓地且本回合未发动过
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,3,nil) and Duel.GetFlagEffect(tp,id)==0 end
	-- 设置连锁操作信息，表示将有3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_DECK+LOCATION_EXTRA)
	-- 注册标识效果，防止本回合再次发动效果①
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,EFFECT_FLAG_OATH,1)
end
-- 效果①的处理，选择并送去墓地3张「莫忘」卡
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择3张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,3,3,nil)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 效果②中用于选择场上「莫忘」怪兽的过滤函数
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a1)
end
-- 效果②的发动时处理，检查是否满足条件
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查是否满足效果②的发动条件，即本回合未发动过
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		-- 检查自己场上是否有「莫忘」怪兽
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否有卡
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的卡数量
	local ct=Duel.GetMatchingGroupCount(Card.IsCanBeEffectTarget,tp,0,LOCATION_ONFIELD,nil,e)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的「莫忘」怪兽
	local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,ct,nil)
	local ect=g1:GetCount()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的卡，数量与自己场上的「莫忘」怪兽相同
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,ect,ect,nil)
	g1:Merge(g2)
	-- 设置连锁操作信息，表示将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
	-- 注册标识效果，防止本回合再次发动效果②
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,EFFECT_FLAG_OATH,1)
end
-- 效果②的处理，破坏指定数量的卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 破坏目标卡
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 效果③中用于检索「冥骸府-莫忘冥府」的过滤函数
function s.thfilter(c)
	return c:IsCode(43338320) and c:IsAbleToHand()
end
-- 效果③的发动时处理，检查是否满足条件并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果③的发动条件，即卡组中是否有「冥骸府-莫忘冥府」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的处理，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
