--冥骸王－メメントラン・テクトリカ
-- 效果：
-- 「莫忘」怪兽×3
-- 这个卡名的①②③的效果1回合各能使用1次，①②的效果在同一连锁上不能发动。
-- ①：这张卡融合召唤的场合才能发动。从卡组·额外卡组把3张「莫忘」卡送去墓地。
-- ②：自己·对方回合，以自己场上的「莫忘」怪兽和对方场上的卡各相同数量为对象才能发动。那些卡破坏。
-- ③：把墓地的这张卡除外才能发动。从卡组把1张「冥骸府-莫忘冥府」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- 将「冥骸府-莫忘冥府」的卡片密码（43338320）加入该卡的关联卡片密码列表中
	aux.AddCodeList(c,43338320)
	-- 为这张卡添加融合素材为3只满足条件「ffilter」的怪兽的融合召唤手续
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
	-- 将墓地中的这张卡除外作为效果发动的Cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：作为融合素材的「莫忘」怪兽
function s.ffilter(c)
	return c:IsFusionSetCard(0x1a1)
end
-- 定义效果①的Condition：检查这张卡是否为融合召唤
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤条件：属于「莫忘」系列且可以送去墓地的卡片
function s.filter(c)
	return c:IsSetCard(0x1a1) and c:IsAbleToGrave()
end
-- 定义效果①的Target：检查卡组·额外卡组中是否存在3张「莫忘」卡，并限制同一连锁上不能与效果②共同发动，最后设置送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在3张可以送去墓地的「莫忘」卡片，并确认此连锁中效果① and ②未曾发动
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,3,nil) and Duel.GetFlagEffect(tp,id)==0 end
	-- 设置操作信息：从卡组及额外卡组将3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_DECK+LOCATION_EXTRA)
	-- 为此玩家注册同一连锁上的发动限制标识效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,EFFECT_FLAG_OATH,1)
end
-- 定义效果①的Operation：从卡组·额外卡组选择3张「莫忘」卡片送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择送去墓地的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家在卡组以及额外卡组中选择3张符合条件的「莫忘」卡片
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,3,3,nil)
	-- 将选中的卡片送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 过滤条件：自己场上表侧表示、属于「莫忘」系列且可以成为效果对象的怪兽
function s.desfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x1a1) and c:IsCanBeEffectTarget(e)
end
-- 定义效果②的Target：以自己场上的「莫忘」怪兽和对方场上的卡各相同数量为对象，并限制同一连锁上不能与效果①共同发动，最后设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有可作为破坏对象的「莫忘」怪兽
	local g1=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil,e)
	-- 获取对方场上所有可作为破坏对象的卡片
	local g2=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,0,LOCATION_ONFIELD,nil,e)
	-- 确认此连锁中效果① and ②未曾发动
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		and #g1>0 and #g2>0 end
	-- 向玩家发送选择破坏的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家在双方场上选择相同数量的卡片作为效果对象
	local sg=aux.SelectSameCount(tp,g1,g2)
	-- 将选中的双方场上相同数量的卡片设置为当前连锁的效果对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息：将选中的卡片破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 为此玩家注册同一连锁上的发动限制标识效果
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,EFFECT_FLAG_OATH,1)
end
-- 定义效果②的Operation：将设定的卡片破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的所有目标对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将依旧符合破坏条件的目标卡片全部破坏
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- 过滤条件：卡名为「冥骸府-莫忘冥府」且能加入手牌的卡片
function s.thfilter(c)
	return c:IsCode(43338320) and c:IsAbleToHand()
end
-- 定义效果③的Target：检查卡组中是否存在「冥骸府-莫忘冥府」，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以检索的「冥骸府-莫忘冥府」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果③的Operation：从卡组检索1张「冥骸府-莫忘冥府」加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择加入手牌的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家在卡组中选择1张「冥骸府-莫忘冥府」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入持有者手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
