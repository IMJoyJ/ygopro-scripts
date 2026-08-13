--ブレイク・ザ・デステニー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「龙骑士 D-终」或者8星以上的「命运英雄」怪兽为对象才能发动。那只怪兽破坏，下次的对方主要阶段1跳过。
-- ②：把墓地的这张卡除外才能发动。把「打破命运」以外的有「龙骑士 D-终」的卡名或者「命运英雄」怪兽的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
function c4008212.initial_effect(c)
	-- 记录本卡效果文本中记载了「龙骑士 D-终」（卡号76263644）这一卡名，用于后续判断“有「龙骑士 D-终」的卡名记述”的检索条件。
	aux.AddCodeList(c,76263644)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以自己场上1只「龙骑士 D-终」或者8星以上的「命运英雄」怪兽为对象才能发动。那只怪兽破坏，下次的对方主要阶段1跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4008212,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	e1:SetCountLimit(1,4008212)
	e1:SetTarget(c4008212.destg)
	e1:SetOperation(c4008212.desop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外才能发动。把「打破命运」以外的有「龙骑士 D-终」的卡名或者「命运英雄」怪兽的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4008212,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,4008212)
	-- 设置②效果的发动代价：把墓地中的这张卡自身除外，作为效果的发动COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c4008212.thtg)
	e2:SetOperation(c4008212.thop)
	c:RegisterEffect(e2)
end
-- ①效果的对象筛选函数：要求对象是表侧表示，且是「龙骑士 D-终」（76263644），或是字段为「命运英雄」（0xc008）且等级在8星以上的怪兽。
function c4008212.desfilter(c)
	return c:IsFaceup() and (c:IsCode(76263644) or c:IsSetCard(0xc008) and c:IsLevelAbove(8))
end
-- ①效果的发动目标选择处理：从自己场上选择1只满足desfilter的怪兽作为对象，并登记破坏该对象的操作信息。
function c4008212.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4008212.desfilter(chkc) end
	-- 在发动时点检查自己场上是否存在至少1只满足desfilter条件的表侧怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c4008212.desfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出“请选择要破坏的卡”的选卡提示，要求玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上选择1只符合条件的怪兽，同时将其登记为本连锁的效果对象。
	local g=Duel.SelectTarget(tp,c4008212.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次连锁将破坏1张卡（即所选择的对象），供相关效果和时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：取得对象，若对象仍与效果关联则将其破坏；破坏成功的场合，为对方附加“跳过下次主要阶段1”的效果，并根据发动时的阶段设置持续与重置条件。
function c4008212.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽与效果仍有关联（没有因离场等原因失效），且破坏处理实际成功，才继续执行跳过主要阶段1的效果。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 那只怪兽破坏，下次的对方主要阶段1跳过。②：把墓地的这张卡除外才能发动。把「打破命运」以外的有「龙骑士 D-终」的卡名或者「命运英雄」怪兽的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_M1)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		-- 判断当前是否正处于对方的主要阶段1或之后：如果是，则用回合数标记让跳过效果只作用于下一次对方主要阶段1，避免错误跳过当前回合正在进行的M1。
		if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()>=PHASE_MAIN1 then
			-- 将当前回合数记录到效果标签中，供turncon条件判断。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(c4008212.turncon)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		end
		-- 将“跳过对方主要阶段1”的永续效果注册到场上，对对方玩家生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义跳过M1效果的条件：当前回合数不等于效果记录的回合数，即跳过效果不在发动当回合适用，而是推迟到之后的下一次对方主要阶段1。
function c4008212.turncon(e)
	-- 条件成立条件：Duel.GetTurnCount()已经不是e:GetLabel()记录的回合数，说明回合已经推进到下一次。
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- ②效果的检索筛选函数：对象必须是魔法·陷阱卡、能加入手卡、不是「打破命运」本身，且卡名记述了「龙骑士 D-终」或「命运英雄」怪兽。
function c4008212.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and not c:IsCode(4008212)
		-- 进一步限定：卡的文本中记载了「龙骑士 D-终」（76263644）的卡名，或者记述了「命运英雄」（0xc008）系列怪兽的卡名。
		and (aux.IsCodeListed(c,76263644) or aux.IsSetNameMonsterListed(c,0xc008))
end
-- ②效果的合法性检查与操作信息设置：在卡组中存在满足thfilter的卡时，登记“从卡组将1张卡加入手卡”的处理。
function c4008212.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组是否存在至少1张满足thfilter条件的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c4008212.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理为从卡组检索1张卡加入手卡（属于TOHAND和SEARCH分类）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选1张符合条件的魔法·陷阱卡加入手卡，并将该卡给对方玩家确认。
function c4008212.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足thfilter条件的魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c4008212.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索加入手卡的那张卡展示给对方玩家确认，以证明检索过程合规。
		Duel.ConfirmCards(1-tp,g)
	end
end
