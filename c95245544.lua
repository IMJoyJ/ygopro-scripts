--ウィッチクラフト・ピットレ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡解放，从手卡丢弃1张魔法卡才能发动。从卡组把「魔女术工匠·绘画女巫」以外的1只「魔女术」怪兽特殊召唤。
-- ②：把墓地的这张卡除外才能发动。自己从卡组抽1张，那之后从手卡选1张「魔女术」卡送去墓地。手卡没有「魔女术」卡的场合，手卡全部除外。
function c95245544.initial_effect(c)
	-- ①：自己·对方的主要阶段，把这张卡解放，从手卡丢弃1张魔法卡才能发动。从卡组把「魔女术工匠·绘画女巫」以外的1只「魔女术」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95245544,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,95245544)
	e1:SetCondition(c95245544.spcon)
	e1:SetCost(c95245544.spcost)
	e1:SetTarget(c95245544.sptg)
	e1:SetOperation(c95245544.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己从卡组抽1张，那之后从手卡选1张「魔女术」卡送去墓地。手卡没有「魔女术」卡的场合，手卡全部除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,95245545)
	-- 把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c95245544.drtg)
	e2:SetOperation(c95245544.drop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判断函数
function c95245544.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为自己或对方的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤手卡中的魔法卡（或适用魔女术代破效果的场上魔法卡）作为发动成本
function c95245544.costfilter(c,tp)
	if c:IsLocation(LOCATION_HAND) then return c:IsType(TYPE_SPELL) and c:IsDiscardable() end
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsHasEffect(83289866,tp)
end
-- 效果①的发动成本处理函数
function c95245544.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 检查手卡或魔法与陷阱区是否存在可作为成本送去墓地的魔法卡
		and Duel.IsExistingMatchingCard(c95245544.costfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil,tp) end
	-- 获取手卡及魔法与陷阱区中满足成本过滤条件的卡片组
	local g=Duel.GetMatchingGroup(c95245544.costfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,nil,tp)
	-- 提示玩家选择要丢弃的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	local te=tc:IsHasEffect(83289866,tp)
	if te then
		te:UseCountLimit(tp)
		-- 解放自身作为发动成本（代破效果适用时）
		Duel.Release(e:GetHandler(),REASON_COST)
		-- 将选中的卡作为发动成本送去墓地（代破效果适用时）
		Duel.SendtoGrave(tc,REASON_COST)
	else
		-- 解放自身作为发动成本
		Duel.Release(e:GetHandler(),REASON_COST)
		-- 将选中的手卡魔法卡丢弃送去墓地作为发动成本
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 过滤卡组中「魔女术工匠·绘画女巫」以外的「魔女术」怪兽
function c95245544.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and not c:IsCode(95245544) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备函数
function c95245544.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查解放自身后是否有可用的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在可特殊召唤的「魔女术」怪兽
		and Duel.IsExistingMatchingCard(c95245544.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，准备从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数
function c95245544.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若满则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的「魔女术」怪兽
	local g=Duel.SelectMatchingCard(tp,c95245544.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动准备函数
function c95245544.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能进行除外和抽卡操作
	if chk==0 then return Duel.IsPlayerCanRemove(tp) and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置抽卡的操作信息，准备抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤手卡中可以送去墓地的「魔女术」卡片
function c95245544.tgfilter(c)
	return c:IsSetCard(0x128) and c:IsAbleToGrave()
end
-- 效果②的效果处理函数
function c95245544.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽卡
	Duel.Draw(p,d,REASON_EFFECT)
	-- 洗切目标玩家的手卡
	Duel.ShuffleHand(p)
	-- 中断当前效果，使后续处理不与抽卡同时进行
	Duel.BreakEffect()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1张「魔女术」卡片
	local g=Duel.SelectMatchingCard(p,c95245544.tgfilter,p,LOCATION_HAND,0,1,1,nil)
	local tg=g:GetFirst()
	if tg then
		-- 尝试将选中的「魔女术」卡片送去墓地，若送墓失败
		if Duel.SendtoGrave(g,REASON_EFFECT)==0 then
			-- 给对方玩家确认该卡片
			Duel.ConfirmCards(1-p,tg)
			-- 重新洗切手卡
			Duel.ShuffleHand(p)
		end
	else
		-- 手卡没有「魔女术」卡时，获取玩家的全部手卡
		local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		-- 尝试将全部手卡除外，若除外失败
		if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)==0 then
			-- 给对方玩家确认这些手卡
			Duel.ConfirmCards(1-p,sg)
			-- 重新洗切手卡
			Duel.ShuffleHand(p)
		end
	end
end
