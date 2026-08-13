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
	-- 为这张卡添加连接召唤手续：以2只恶魔族怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_FIEND),2,2)
	-- 这张卡的控制者在每次自己准备阶段支付500基本分。或者不支付让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c35606858.mtcon)
	e1:SetOperation(c35606858.mtop)
	c:RegisterEffect(e1)
	-- ①：自己把基本分支付的场合才能发动。和那个数值相同的攻击力或守备力的1只恶魔族怪兽从卡组送去墓地。
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
	-- ②：恶魔族怪兽被送去自己墓地的场合才能发动。掷1次骰子，那之内的1只受出现的数目的效果适用。●1：加入手卡。●2～5：回到卡组。●6：特殊召唤。
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
-- 准备阶段维持效果的发动条件：当前回合玩家必须是这张卡的控制者（即自己的准备阶段）。
function c35606858.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否等于效果控制者，用于限定只在控制者的准备阶段处理维持Cost。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段维持Cost的处理函数：如果玩家能支付500LP或受万魔殿影响，则询问是否维持；若选择维持，再判断是否使用万魔殿免除支付，否则支付500LP。
function c35606858.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者是否满足支付500基本分的条件，或是否受到万魔殿效果影响（可不支付基本分维持）。
	if (Duel.CheckLPCost(tp,500) or Duel.IsPlayerAffectedByEffect(tp,94585852))
		-- 询问控制者是否维持这张卡（即选择支付或不支付），若选择否则进入破坏分支。
		and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(35606858,2)) then  --"是否维持「长世国王恶魔」？"
		-- 判断控制者是否没有受到万魔殿效果影响，若没有则必须实际支付基本分。
		if not Duel.IsPlayerAffectedByEffect(tp,94585852)
			-- 或控制者选择不使用万魔殿效果来免除支付，满足条件则执行实际支付。
			or not Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(94585852,1)) then  --"是否使用「万魔殿-恶魔的巢窟-」的效果不支付基本分？"
			-- 让控制者支付500基本分，作为准备阶段的维持Cost。
			Duel.PayLPCost(tp,500)
		end
	else
		-- 当控制者选择不支付维持Cost时，将这张卡以Cost原因破坏。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
-- ①效果的发动条件：只有基本分支付者是这张卡的控制者（自己）时，效果才能发动。
function c35606858.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- ①效果的发动限制：检查这张卡在本连锁上是否已经发动过①效果，若没有则注册连锁内标志，确保同一连锁上①效果只能发动1次。
function c35606858.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(35606858)==0 end
	c:RegisterFlagEffect(35606858,RESET_CHAIN,0,1)
end
-- 定义①效果检索的过滤条件：选择恶魔族怪兽，且其攻击力或守备力与所支付的基本分数值相同，并且可以被送去墓地。
function c35606858.tgfilter(c,val)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_MONSTER) and (c:IsAttack(val) or c:IsDefense(val)) and c:IsAbleToGrave()
end
-- ①效果的发动目标与操作信息：确认卡组存在符合条件的恶魔族怪兽，并设置从卡组将1张卡送去墓地的操作信息。
function c35606858.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认卡组中是否存在至少1只攻击力或守备力等于所支付基本分数值的恶魔族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c35606858.tgfilter,tp,LOCATION_DECK,0,1,nil,ev) end
	-- 设置连锁操作信息：本效果将从卡组把1张卡送去墓地（供其他卡进行响应检测）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只攻击力或守备力与所支付基本分相同的恶魔族怪兽送去墓地。
function c35606858.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示控制者选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张符合条件的恶魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,c35606858.tgfilter,tp,LOCATION_DECK,0,1,1,nil,ev)
	if g:GetCount()>0 then
		-- 将选择的恶魔族怪兽送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果的发动限制：检查这张卡在本连锁上是否已经发动过②效果，若没有则注册连锁内标志，确保同一连锁上②效果只能发动1次。
function c35606858.dccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(35606859)==0 end
	c:RegisterFlagEffect(35606859,RESET_CHAIN,0,1)
end
-- 定义②效果可适用的墓地恶魔族怪兽条件：必须是恶魔族怪兽，位于墓地且属于自己，并能加入手卡、回到卡组或可被特殊召唤（骰子结果为6时需要空位）。
function c35606858.cfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_MONSTER) and c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp)
		-- 判断怪兽至少能适用骰子结果中的一种移动方式（加入手卡、回卡组或特殊召唤），以保证后续处理有效。
		and (c:IsAbleToHand() or c:IsAbleToDeck() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
-- ②效果发动条件与操作信息：确认玩家可以进行特殊召唤，且本次送去墓地的恶魔族怪兽中有可适用的对象；同时设置将进行掷骰子的操作信息。
function c35606858.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够特殊召唤（因骰子结果可能为6），以及被送去墓地的怪兽组中是否存在符合条件的恶魔族怪兽。
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp) and eg:IsExists(c35606858.cfilter,1,nil,e,tp) end
	-- 设置连锁操作信息：本效果包含掷1次骰子。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- ②效果处理：掷1次骰子，从符合条件的墓地恶魔族怪兽中选择1只，按点数适用效果：1加入手卡、2～5回到卡组、6特殊召唤。
function c35606858.dcop(e,tp,eg,ep,ev,re,r,rp)
	-- 让控制者掷1次骰子，得到点数d。
	local d=Duel.TossDice(tp,1)
	-- 从本次被送去墓地的怪兽中筛选出符合条件的恶魔族怪兽，并排除受王家长眠之谷影响而不能移动的卡。
	local g=eg:Filter(aux.NecroValleyFilter(c35606858.cfilter),nil,e,tp)
	if g:GetCount()==0 then return end
	local tc=nil
	if g:GetCount()>1 then
		-- 提示玩家选择骰子效果适用的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	if d==1 then
		-- 骰子结果为1时，将选择的怪兽加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	elseif d==6 then
		-- 骰子结果为6时，将选择的怪兽以表侧表示特殊召唤到控制者场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif d>=2 and d<=5 then
		-- 骰子结果为2～5时，将选择的怪兽回到持有者卡组并洗切。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
