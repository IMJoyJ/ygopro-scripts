--烙印開幕
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：选自己1张手卡丢弃。那之后，从卡组选1只「死狱乡」怪兽加入手卡或守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的融合怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c36637374.initial_effect(c)
	-- ①：选自己1张手卡丢弃。那之后，从卡组选1只「死狱乡」怪兽加入手卡或守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,36637374)
	e1:SetTarget(c36637374.target)
	e1:SetOperation(c36637374.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的融合怪兽被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,36637375)
	e2:SetTarget(c36637374.reptg)
	e2:SetValue(c36637374.repval)
	e2:SetOperation(c36637374.repop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「死狱乡」怪兽，可加入手卡或特殊召唤。
function c36637374.selfilter(c,e,tp,check)
	return c:IsSetCard(0x164) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or check and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE))
end
-- 判断是否满足①效果的发动条件，即手牌有可丢弃的卡且卡组有符合条件的「死狱乡」怪兽。
function c36637374.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有怪兽区域可用。
	local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 检查玩家手牌中是否存在可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 检查玩家卡组中是否存在符合条件的「死狱乡」怪兽。
		and Duel.IsExistingMatchingCard(c36637374.selfilter,tp,LOCATION_DECK,0,1,nil,e,tp,check) end
	-- 设置连锁操作信息，表示将要丢弃1张手牌。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- ①效果的处理函数，发动后设置场上不能特殊召唤非融合怪兽的效果，并丢弃手牌后选择卡组中的「死狱乡」怪兽进行处理。
function c36637374.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 创建并注册一个永续效果，使玩家在回合结束前不能从额外卡组特殊召唤非融合怪兽。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c36637374.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到玩家场上。
		Duel.RegisterEffect(e1,tp)
	end
	-- 执行丢弃1张手牌的操作。
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
		-- 中断当前效果处理，使后续效果视为错时处理。
		Duel.BreakEffect()
		-- 判断玩家场上是否有怪兽区域可用。
		local check=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 提示玩家选择要操作的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从卡组中选择符合条件的「死狱乡」怪兽。
		local g=Duel.SelectMatchingCard(tp,c36637374.selfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,check)
		if #g==0 then return end
		local tc=g:GetFirst()
		if check and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断是否选择特殊召唤该怪兽，若不可加入手卡则选择特殊召唤。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将选中的「死狱乡」怪兽以守备表示特殊召唤到场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		else
			-- 将选中的「死狱乡」怪兽加入手牌。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方查看该怪兽。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
-- 判断是否为额外卡组中的非融合怪兽，若是则不能特殊召唤。
function c36637374.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
-- 过滤函数，用于筛选场上被效果破坏的融合怪兽。
function c36637374.repfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足②效果的发动条件，即墓地的此卡可除外且有融合怪兽被效果破坏。
function c36637374.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c36637374.repfilter,1,nil,tp) end
	-- 提示玩家是否发动②效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回是否为融合怪兽的判断结果。
function c36637374.repval(e,c)
	return c36637374.repfilter(c,e:GetHandlerPlayer())
end
-- ②效果的处理函数，将此卡从墓地除外。
function c36637374.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从墓地除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
