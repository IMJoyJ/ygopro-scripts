--ウィッチクラフト・ポトリー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡解放，从手卡丢弃1张魔法卡才能发动。从卡组把「魔女术工匠·陶器女巫」以外的1只「魔女术」怪兽特殊召唤。
-- ②：自己手卡是0张的场合，把墓地的这张卡除外，以自己墓地1张「魔女术」卡为对象才能发动。那张卡加入手卡。
function c59851535.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方的主要阶段，把这张卡解放，从手卡丢弃1张魔法卡才能发动。从卡组把「魔女术工匠·陶器女巫」以外的1只「魔女术」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59851535,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,59851535)
	e1:SetCondition(c59851535.spcon)
	e1:SetCost(c59851535.spcost)
	e1:SetTarget(c59851535.sptg)
	e1:SetOperation(c59851535.spop)
	c:RegisterEffect(e1)
	-- ②：自己手卡是0张的场合，把墓地的这张卡除外，以自己墓地1张「魔女术」卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,59851536)
	e2:SetCondition(c59851535.thcon)
	-- 将②效果发动时把墓地的这张卡除外作为COST，使用辅助函数aux.bfgcost实现除外自身作为代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c59851535.thtg)
	e2:SetOperation(c59851535.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定函数：仅在当前阶段为主要阶段1或主要阶段2时允许发动，对应“自己·对方的主要阶段”这一限制。
function c59851535.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1或主要阶段2，满足任一即返回真，用于实现“主要阶段才能发动”的效果条件。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义丢弃/送入墓地的魔法卡的筛选条件：手牌中的魔法卡且可丢弃；或满足特定效果（83289866）影响下的表侧卡；或卡组中属于「魔女术」字段的魔法·陷阱卡且可作为代价送入墓地（且满足res条件）。
function c59851535.costfilter(c,tp,res)
	if c:IsLocation(LOCATION_HAND) then return c:IsType(TYPE_SPELL) and c:IsDiscardable() end
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsHasEffect(83289866,tp)
		or not c:IsCode(32353566) and c:IsSetCard(0x128)
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		and c:IsLocation(LOCATION_DECK) and res
end
-- ①效果的代价执行函数：检查能否解放自身并存在满足costfilter的卡，随后让玩家选择一张要丢弃/送入墓地的魔法卡，解放自身，并将选中的卡以对应理由送入墓地。
function c59851535.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家tp是否受到卡号32353566的效果影响且本卡的卡名属于「魔女术」字段，结果存入res；该标志用于扩展代价筛选条件（允许从卡组选卡作为替代等条件）。
	local res=Duel.IsPlayerAffectedByEffect(tp,32353566) and e:GetHandler():IsSetCard(0x128)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 在发动check阶段确认存在至少一张满足costfilter的卡（可从手牌、魔陷区、卡组中选择），结合解放自身作为①效果的发动条件。
		and Duel.IsExistingMatchingCard(c59851535.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,1,nil,tp,res) end
	-- 获取所有满足costfilter的候选卡片组（手牌+魔陷区+卡组），供玩家从中选择要丢弃/送入墓地的魔法卡。
	local g=Duel.GetMatchingGroup(c59851535.costfilter,tp,LOCATION_HAND+LOCATION_SZONE+LOCATION_DECK,0,nil,tp,res)
	-- 发送“请选择要丢弃的手牌”选择提示消息，用于接下来的选卡操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将效果发动者（这张卡）作为代价解放。
	Duel.Release(e:GetHandler(),REASON_COST)
	if not tc:IsLocation(LOCATION_HAND) then
		local te=tc:IsHasEffect(83289866,tp)
		if te then
			te:UseCountLimit(tp)
			-- 为玩家注册一个直到结束阶段有效的标志，卡码为所选卡的代码，用于记录该卡当回合的使用/发动情况（配合特定卡的次数限制）。
			Duel.RegisterFlagEffect(tp,tc:GetCode(),RESET_PHASE+PHASE_END,0,1)
		end
		-- 将所选的非手牌区域的卡作为代价送入墓地。
		Duel.SendtoGrave(tc,REASON_COST)
	else
		-- 将所选的手牌魔法卡作为丢弃代价送入墓地，同时带有REASON_COST和REASON_DISCARD。
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- 定义①效果特殊召唤的筛选条件：卡组中属于「魔女术」字段的怪兽，不能是本卡「魔女术工匠·陶器女巫」，且可以被特殊召唤。
function c59851535.spfilter(c,e,tp)
	return c:IsSetCard(0x128) and not c:IsCode(59851535) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动目标：确认解放后仍有可用怪兽区域，且卡组中存在符合条件的「魔女术」怪兽；并设置效果处理时为特殊召唤操作。
function c59851535.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查解放这张卡后自己场上是否还有可用的怪兽区（数量必须大于0），这是能否发动①效果的前提之一。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 同时确认卡组中存在至少1只可特殊召唤的符合条件的「魔女术」怪兽，与怪兽区条件共同决定①效果能否发动。
		and Duel.IsExistingMatchingCard(c59851535.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次连锁的操作为从卡组特殊召唤1只怪兽，供连锁处理及需要检测特殊召唤操作的其他卡参照。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时，若自己场上仍有空余怪兽区，则从卡组选择1只符合条件的「魔女术」怪兽以表侧攻击表示特殊召唤。
function c59851535.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己怪兽区没有空位，则直接终止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送“请选择要特殊召唤的卡”的提示消息，用于接下来的卡组选卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选出1只满足spfilter的「魔女术」怪兽作为这次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c59851535.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到自己场上，作为①效果处理的特殊召唤操作。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件判定函数：自己手牌数量为0时才能发动。
function c59851535.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己手牌数是否为0，返回真表示手牌为0，满足②效果的发动条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 定义②效果取对象的筛选条件：自己墓地中属于「魔女术」字段的卡且能够加入手卡。
function c59851535.thfilter(c)
	return c:IsSetCard(0x128) and c:IsAbleToHand()
end
-- ②效果的目标设定：以自己墓地1张「魔女术」卡为对象，并设置将对象加入手卡的操作信息；选择前给出提示。
function c59851535.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c59851535.thfilter(chkc) end
	-- 发动时检查自己墓地是否存在至少1张符合条件的「魔女术」卡可以作为对象，且该卡能成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c59851535.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 发送“请选择要加入手牌的卡”的提示消息，用于接下来的墓地选卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己墓地1张满足thfilter的「魔女术」卡，并将其设定为效果对象。
	local g=Duel.SelectTarget(tp,c59851535.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次连锁的操作为把对象卡加入手牌，并指定对象组g及数量1，供连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：取得对象卡，若该卡仍与本次效果相关，则将其加入持有者手卡。
function c59851535.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果理由（REASON_EFFECT）加入持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
