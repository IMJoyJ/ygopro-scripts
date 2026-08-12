--ブレイク・ザ・デステニー
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「龙骑士 D-终」或者8星以上的「命运英雄」怪兽为对象才能发动。那只怪兽破坏，下次的对方主要阶段1跳过。
-- ②：把墓地的这张卡除外才能发动。把「打破命运」以外的有「龙骑士 D-终」的卡名或者「命运英雄」怪兽的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
function c4008212.initial_effect(c)
	-- 记录此卡效果文本中记载了「龙骑士 D-终」的卡名
	aux.AddCodeList(c,76263644)
	-- ①：以自己场上1只「龙骑士 D-终」或者8星以上的「命运英雄」怪兽为对象才能发动。那只怪兽破坏，下次的对方主要阶段1跳过。
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
	-- ②：把墓地的这张卡除外才能发动。把「打破命运」以外的有「龙骑士 D-终」的卡名或者「命运英雄」怪兽的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4008212,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,4008212)
	-- 将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c4008212.thtg)
	e2:SetOperation(c4008212.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上自己控制的怪兽，满足以下任意条件：1. 卡片密码为「龙骑士 D-终」；2. 系列为「命运英雄」且等级不低于8
function c4008212.desfilter(c)
	return c:IsFaceup() and (c:IsCode(76263644) or c:IsSetCard(0xc008) and c:IsLevelAbove(8))
end
-- 设定效果目标：选择自己场上满足过滤条件的1只怪兽作为目标
function c4008212.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4008212.desfilter(chkc) end
	-- 检查是否满足发动条件：确认场上是否存在满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c4008212.desfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的1只怪兽作为目标
	local g=Duel.SelectTarget(tp,c4008212.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息：将破坏效果的处理对象设为所选怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若目标怪兽存在且被成功破坏，则设置一个跳过对方主要阶段1的效果
function c4008212.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽是否仍然存在于场上且与当前效果相关，若满足则进行破坏操作
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 创建一个用于跳过对方主要阶段1的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_M1)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		-- 判断当前是否为对方回合且处于主要阶段1或之后
		if Duel.GetTurnPlayer()==1-tp and Duel.GetCurrentPhase()>=PHASE_MAIN1 then
			-- 记录当前回合数，用于后续判断是否跳过对方主要阶段1
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(c4008212.turncon)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		end
		-- 将跳过主要阶段1的效果注册到全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断条件函数：当回合数不等于记录的回合数时，跳过主要阶段1效果生效
function c4008212.turncon(e)
	-- 判断条件函数：当回合数不等于记录的回合数时，跳过主要阶段1效果生效
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 过滤条件：卡牌类型为魔法或陷阱，可以送去手牌，且不是「打破命运」，并且其效果文本中记载了「龙骑士 D-终」或属于「命运英雄」系列
function c4008212.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand() and not c:IsCode(4008212)
		-- 判断卡牌效果文本中是否记载了「龙骑士 D-终」或属于「命运英雄」系列
		and (aux.IsCodeListed(c,76263644) or aux.IsSetNameMonsterListed(c,0xc008))
end
-- 设定效果目标：选择满足过滤条件的1张魔法·陷阱卡作为目标
function c4008212.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：确认卡组中是否存在满足过滤条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c4008212.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：将检索效果的处理对象设为1张魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组中选择1张满足条件的魔法·陷阱卡加入手牌
function c4008212.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c4008212.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法·陷阱卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的魔法·陷阱卡
		Duel.ConfirmCards(1-tp,g)
	end
end
