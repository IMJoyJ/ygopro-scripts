--転生炎獣フォクシー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤成功时才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1张「转生炎兽」卡加入手卡。剩下的卡回到卡组。
-- ②：这张卡在墓地存在，场上有表侧表示的魔法·陷阱卡存在的场合，从手卡丢弃1张「转生炎兽」卡才能发动。这张卡特殊召唤。那之后，可以选场上1张表侧表示的魔法·陷阱卡破坏。
function c94620082.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1张「转生炎兽」卡加入手卡。剩下的卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94620082,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,94620082)
	e1:SetTarget(c94620082.thtg)
	e1:SetOperation(c94620082.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，场上有表侧表示的魔法·陷阱卡存在的场合，从手卡丢弃1张「转生炎兽」卡才能发动。这张卡特殊召唤。那之后，可以选场上1张表侧表示的魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94620082,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,94620082)
	e2:SetCondition(c94620082.spcon)
	e2:SetCost(c94620082.spcost)
	e2:SetTarget(c94620082.sptg)
	e2:SetOperation(c94620082.spop)
	c:RegisterEffect(e2)
end
-- 效果①的Target函数（发动准备与检测）：检查卡组数量并设置操作信息
function c94620082.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组最上方是否有至少3张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 过滤条件：属于「转生炎兽」且可以加入手卡的卡
function c94620082.thfilter(c)
	return c:IsSetCard(0x119) and c:IsAbleToHand()
end
-- 效果①的Operation函数（效果处理）：翻开卡组上方3张卡，选择加入手卡并洗卡
function c94620082.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 确认该玩家卡组最上方的3张卡
	Duel.ConfirmDecktop(p,3)
	-- 获取该玩家卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(p,3)
	-- 如果翻开的卡中存在「转生炎兽」卡，且玩家选择将其加入手卡
	if g:GetCount()>0 and g:IsExists(c94620082.thfilter,1,nil) and Duel.SelectYesNo(p,aux.Stringid(94620082,1)) then  --"是否选卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:FilterSelect(p,c94620082.thfilter,1,1,nil)
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-p,sg)
		-- 洗切该玩家的手卡
		Duel.ShuffleHand(p)
	end
	-- 洗切该玩家的卡组
	Duel.ShuffleDeck(p)
end
-- 过滤条件：场上表侧表示的魔法·陷阱卡
function c94620082.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果②的发动条件：场上有表侧表示的魔法·陷阱卡存在
function c94620082.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1张表侧表示的魔法·陷阱卡
	return Duel.IsExistingMatchingCard(c94620082.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 过滤条件：手卡中可以丢弃的「转生炎兽」卡
function c94620082.cfilter(c)
	return c:IsSetCard(0x119) and c:IsDiscardable()
end
-- 效果②的发动Cost：从手卡丢弃1张「转生炎兽」卡
function c94620082.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可作为Cost丢弃的「转生炎兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c94620082.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡中的「转生炎兽」卡
	Duel.DiscardHand(tp,c94620082.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 效果②的Target函数：检查自身是否能特殊召唤并设置操作信息
function c94620082.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的Operation函数：特殊召唤自身，之后可选择破坏场上1张表侧表示的魔法·陷阱卡
function c94620082.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡仍存在于墓地，则将其以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取场上所有表侧表示的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c94620082.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 如果场上存在表侧表示的魔法·陷阱卡，且玩家选择将其破坏
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(94620082,3)) then  --"是否选魔法·陷阱卡破坏？"
			-- 中断当前效果处理，使后续的破坏处理不与特殊召唤同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=g:Select(tp,1,1,nil)
			-- 选中要破坏的卡并显示选中动画
			Duel.HintSelection(dg)
			-- 因效果破坏选中的卡
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
