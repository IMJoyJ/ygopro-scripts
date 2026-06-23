--パーペチュアルキングデーモン
-- 效果：
-- 恶魔族怪兽2只
-- 这张卡的控制者在每次自己准备阶段支付500基本分。或者不支付让这张卡破坏。这张卡的①②的效果在同一连锁上各能发动1次。
-- ①：自己把基本分支付的场合才能发动。和那个数值相同的攻击力或守备力的1只恶魔族怪兽从卡组送去墓地。
-- ②：恶魔族怪兽被送去自己墓地的场合才能发动。掷1次骰子，那之内的1只受出现的数目的效果适用。
-- ●1：加入手卡。
-- ●2～5：回到卡组。
-- ●6：特殊召唤。
function c35606858.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只恶魔族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FIEND),2,2)
	-- 自己把基本分支付的场合才能发动。和那个数值相同的攻击力或守备力的1只恶魔族怪兽从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c35606858.mtcon)
	e1:SetOperation(c35606858.mtop)
	c:RegisterEffect(e1)
	-- 恶魔族怪兽被送去自己墓地的场合才能发动。掷1次骰子，那之内的1只受出现的数目的效果适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35606858,0))  --"恶魔族怪兽从卡组送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_PAY_LPCOST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c35606858.tgcon)
	e2:SetCost(c35606858.tgcost)
	e2:SetTarget(c35606858.tgtg)
	e2:SetOperation(c35606858.tgop)
	c:RegisterEffect(e2)
	-- ①：自己把基本分支付的场合才能发动。和那个数值相同的攻击力或守备力的1只恶魔族怪兽从卡组送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35606858,1))  --"掷1次骰子"
	e3:SetCategory(CATEGORY_DICE+CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c35606858.dccost)
	e3:SetTarget(c35606858.dctg)
	e3:SetOperation(c35606858.dcop)
	c:RegisterEffect(e3)
end
-- 准备阶段时，只有当前回合玩家才能发动此效果
function c35606858.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 准备阶段时，只有当前回合玩家才能发动此效果
	return Duel.GetTurnPlayer()==tp
end
-- 支付500基本分或使用万魔殿效果不支付基本分，否则破坏此卡
function c35606858.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否能支付500基本分
	if (Duel.CheckLPCost(tp,500) or Duel.IsPlayerAffectedByEffect(tp,94585852))
		-- 选择是否维持此卡
		and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(35606858,2)) then  --"是否维持「长世国王恶魔」？"
		-- 检查玩家是否未受到万魔殿效果影响
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 选择是否使用万魔殿效果不支付基本分
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 支付500基本分
			Duel.PayLPCost(tp,500)
		end
	else
		-- 破坏此卡
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- 支付基本分时触发，只有支付方才能发动此效果
function c35606858.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 设置发动费用，防止效果在同连锁重复发动
function c35606858.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(35606858)==0 end
	c:RegisterFlagEffect(35606858,RESET_CHAIN,0,1)
end
-- 过滤满足条件的恶魔族怪兽，其攻击力或守备力等于支付的基本分
function c35606858.tgfilter(c,val)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_MONSTER) and (c:IsAttack(val) or c:IsDefense(val)) and c:IsAbleToGrave()
end
-- 设置效果目标，检查是否有满足条件的恶魔族怪兽可送去墓地
function c35606858.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的恶魔族怪兽可送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c35606858.tgfilter,tp,LOCATION_DECK,0,1,nil,ev) end
	-- 设置效果操作信息，指定将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行效果，选择并送去墓地
function c35606858.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,c35606858.tgfilter,tp,LOCATION_DECK,0,1,1,nil,ev)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 设置发动费用，防止效果在同连锁重复发动
function c35606858.dccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(35606859)==0 end
	c:RegisterFlagEffect(35606859,RESET_CHAIN,0,1)
end
-- 过滤满足条件的恶魔族怪兽，必须在墓地且可被处理
function c35606858.cfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
		-- 检查恶魔族怪兽是否可被加入手卡、送回卡组或特殊召唤
		and (c:IsAbleToHand() or c:IsAbleToDeck() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
-- 设置效果目标，检查是否有满足条件的恶魔族怪兽被送去墓地
function c35606858.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的恶魔族怪兽被送去墓地
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp) and eg:IsExists(c35606858.cfilter,1,nil,e,tp) end
	-- 设置效果操作信息，指定将要投掷骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 执行效果，投掷骰子并根据结果处理卡牌
function c35606858.dcop(e,tp,eg,ep,ev,re,r,rp)
	-- 投掷一次骰子
	local d=Duel.TossDice(tp,1)
	-- 筛选满足条件的恶魔族怪兽
	local g=eg:Filter(aux.NecroValleyFilter(c35606858.cfilter),nil,e,tp)
	if g:GetCount()==0 then return end
	local tc=nil
	if g:GetCount()>1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	if d==1 then
		-- 将卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	elseif d==6 then
		-- 特殊召唤卡到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif d>=2 and d<=5 then
		-- 将卡送回卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
