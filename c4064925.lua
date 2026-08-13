--古代の進軍
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把卡盖放。
-- ①：作为这张卡的发动时的效果处理，从卡组把「古代的进军」以外的1张「古代的机械」魔法·陷阱卡加入手卡。
-- ②：1回合1次，把自己场上1只怪兽解放才能发动。自己抽1张，这个回合中，以下效果适用。
-- ●自己在「古代的机械巨人」或者有那个卡名记述的5星以上的怪兽召唤的场合需要的解放可以不用。
function c4064925.initial_effect(c)
	-- 将这张卡的效果文本中记载的「古代的机械巨人」(83104731) 加入代码列表，用于后续判断“有那个卡名记述的怪兽”。
	aux.AddCodeList(c,83104731)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不能把卡盖放。①：作为这张卡的发动时的效果处理，从卡组把「古代的进军」以外的1张「古代的机械」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,4064925+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c4064925.cost)
	e1:SetTarget(c4064925.target)
	e1:SetOperation(c4064925.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把自己场上1只怪兽解放才能发动。自己抽1张，这个回合中，以下效果适用。●自己在「古代的机械巨人」或者有那个卡名记述的5星以上的怪兽召唤的场合需要的解放可以不用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4064925,0))  --"解放怪兽并抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c4064925.drcost)
	e2:SetTarget(c4064925.drtg)
	e2:SetOperation(c4064925.drop)
	c:RegisterEffect(e2)
	if not c4064925.global_check then
		c4064925.global_check=true
		-- 这张卡发动的回合，自己不能把卡盖放。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetOperation(c4064925.checkop)
		-- 将监听通常魔法·陷阱卡盖放(EVENT_SSET)的全局持续效果ge1注册到环境中，每当有玩家盖放魔法陷阱时触发checkop记录该玩家本回合盖放过的标志。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_MSET)
		-- 将ge1的克隆体ge2注册到环境中，监听怪兽的通常召唤·盖放(EVENT_MSET)，用于检测玩家把怪兽里侧守备表示放置到场上的行为。
		Duel.RegisterEffect(ge2,0)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge3:SetCondition(c4064925.ssetcon)
		-- 将ge1的克隆体ge3注册到环境中，监听特殊召唤成功(EVENT_SPSUMMON_SUCCESS)事件，并在发生里侧表示特殊召唤时触发checkop记录。
		Duel.RegisterEffect(ge3,0)
		local ge4=ge1:Clone()
		ge4:SetCode(EVENT_CHANGE_POS)
		ge4:SetCondition(c4064925.cpcon)
		-- 将ge1的克隆体ge4注册到环境中，监听表示形式变更(EVENT_CHANGE_POS)事件，并在有卡从表侧变为里侧时触发checkop记录。
		Duel.RegisterEffect(ge4,0)
	end
end
-- checkop函数：当发生盖放/里侧特殊召唤/表侧变里侧等事件时，为进行该操作的玩家rp注册一个“本回合盖放过卡”的标志，该标志在结束阶段重置，用于本卡禁止盖放效果的发动条件判定。
function c4064925.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家rp注册一个直到结束阶段有效的标志4064925，数量为1，表示该玩家本回合已经进行过盖放操作，之后本卡不能再发动（因为违反自肃）。
	Duel.RegisterFlagEffect(rp,4064925,RESET_PHASE+PHASE_END,0,1)
end
-- cfilter函数：判断事件组中的怪兽是否为里侧表示，用于特殊召唤成功事件中检测是否存在“里侧特殊召唤”的怪兽。
function c4064925.cfilter(c)
	return c:IsFacedown()
end
-- ssetcon函数：特殊召唤成功事件的触发条件——只要本次特殊召唤的怪兽中有里侧表示的怪兽，就返回真，让checkop记录为“盖放”。
function c4064925.ssetcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4064925.cfilter,1,nil)
end
-- cfilter2函数：判断卡片是否从表侧表示变成了里侧表示，用于表示形式变更事件中检测“把卡盖放”的行为。
function c4064925.cfilter2(c)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown()
end
-- cpcon函数：表示形式变更事件的触发条件——只要变更的卡中存在表侧变为里侧的情况，就返回真，让checkop记录为“盖放”。
function c4064925.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4064925.cfilter2,1,nil)
end
-- cost函数（①效果的发动代价）：先确认己方本回合没有盖放过卡；随后为己方附加多个自肃效果：不能里侧表示通常召唤怪兽、不能盖放魔法陷阱、不能把表侧卡变为里侧、不能里侧特殊召唤，从而实现“这张卡发动的回合，自己不能把卡盖放”。
function c4064925.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若在cost检查阶段，己方已有“本回合盖放过”的flag则返回false，保证只有本回合未盖放过卡的玩家才能发动本卡。
	if chk==0 then return Duel.GetFlagEffect(tp,4064925)==0 end
	-- 这张卡发动的回合，自己不能把卡盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetTargetRange(1,0)
	-- 将该禁止效果的目标过滤器设为恒真(aux.TRUE)，使限制效果作用于所有卡，表示“任何卡都不能”进行对应的行为。
	e1:SetTarget(aux.TRUE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能里侧表示通常召唤怪兽”的限制效果注册给己方，直到结束阶段，禁止己方把怪兽盖放。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	-- 将“不能盖放魔法·陷阱卡”的限制效果注册给己方，直到结束阶段，禁止己方将魔法陷阱卡盖放到后场。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	-- 将“不能把表侧表示的卡变成里侧表示”的限制效果注册给己方，直到结束阶段，禁止己方把场上的卡盖放（反转）。
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_LIMIT_SPECIAL_SUMMON_POSITION)
	e4:SetTarget(c4064925.sumlimit)
	-- 将“特殊召唤不能里侧表示”的限制效果注册给己方，直到结束阶段，禁止己方以里侧守备表示特殊召唤怪兽。
	Duel.RegisterEffect(e4,tp)
end
-- sumlimit函数：特殊召唤表示形式限制的判定——若特殊召唤的表示形式中含有里侧表示(POS_FACEDOWN)则返回真（禁止），即不允许里侧特殊召唤。
function c4064925.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)>0
end
-- filter函数：①效果检索卡的过滤器——卡名不是「古代的进军」、属于「古代的机械」字段、是魔法或陷阱卡，并且能够加入手卡。
function c4064925.filter(c)
	return not c:IsCode(4064925) and c:IsSetCard(0x7) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToHand()
end
-- target函数（①效果发动目标判定）：在发动时确认卡组中存在满足filter的检索目标，并设置操作信息为“从卡组将1张卡加入手卡”。
function c4064925.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查阶段：如果卡组中不存在符合条件的「古代的机械」魔法·陷阱卡，则①效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c4064925.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果处理时将把1张卡从卡组加入手卡（目标为卡组，数量1），用于连锁响应等判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- activate函数（①效果处理）：从卡组选择1张符合条件的「古代的机械」魔法·陷阱卡加入手卡，并向对方展示那张卡。
function c4064925.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示消息，引导玩家选择要检索的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让己方从卡组中选择1张符合filter条件的「古代的机械」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c4064925.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送入其持有者的手卡（即加入手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认，使检索公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- drcost函数（②效果的cost）：检查己方场上存在至少1只可解放的怪兽，选择1只解放作为发动代价。
function c4064925.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查阶段：若己方场上没有可解放的怪兽，则②效果不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil,tp) end
	-- 显示“请选择要解放的卡”的提示消息，引导玩家选择解放对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让己方从自己场上选择1只可解放的怪兽。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil,tp)
	-- 将选择的怪兽解放（送去墓地），作为发动②效果的cost。
	Duel.Release(g,REASON_COST)
end
-- drtg函数（②效果目标设定）：检查己方可以抽1张卡，并将抽卡玩家和数量设为己方、1，同时设置操作信息为抽卡。
function c4064925.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查阶段：若己方不能抽卡（受抽卡限制效果影响），则②效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的处理对象玩家设置为己方，使效果处理时以己方为抽卡者。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的处理对象参数设置为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本效果处理时将执行抽1张卡，供相关效果连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- drop函数（②效果处理）：根据设定的抽卡玩家与数量进行抽卡；若成功抽卡且本回合尚未获得过“免解放召唤”效果，则给己方注册一个使符合条件的怪兽召唤时无需解放的效果，并用标志防止重复。
function c4064925.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁信息中的目标玩家和目标参数，即抽卡者和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡后，若确实抽了卡且己方没有4064926标志，才继续赋予免解放召唤效果；4064926标志用于确保一回合只能适用一次该效果。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 and Duel.GetFlagEffect(tp,4064926)==0 then
		-- ●自己在「古代的机械巨人」或者有那个卡名记述的5星以上的怪兽召唤的场合需要的解放可以不用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(4064925,2))  --"使用「古代的进军」的效果召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetCountLimit(1,4064925)
		e1:SetCondition(c4064925.ntcon)
		e1:SetTarget(c4064925.nttg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将无解放召唤的 EFFECT_SUMMON_PROC 效果注册给己方，直到结束阶段，使符合条件的怪兽在召唤时免除解放。
		Duel.RegisterEffect(e1,tp)
		-- 给己方注册一个结束阶段重置的“誓约”标志4064926，表示本回合已经适用过免解放召唤效果，防止重复使用。
		Duel.RegisterFlagEffect(tp,4064926,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
	end
end
-- ntcon函数：无解放召唤的条件——若请求的是c==nil表示检查有无可用额外召唤机会则直接允许；实际召唤时要求解放数minc为0（即无需解放）且召唤者怪兽区有空位。
function c4064925.ntcon(e,c,minc)
	if c==nil then return true end
	-- 无解放召唤条件判定：需要解放的怪兽数为0，并且召唤者场上有空出的怪兽区域可以放置怪兽。
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- nttg函数：适用免解放召唤的怪兽判定——怪兽必须是5星以上，并且是「古代的机械巨人」或卡面记述了「古代的机械巨人」的怪兽。
function c4064925.nttg(e,c)
	-- 返回真条件：怪兽等级≥5 且（卡号是83104731 或效果文本中记载了83104731）。
	return c:IsLevelAbove(5) and (c:IsCode(83104731) or aux.IsCodeListed(c,83104731))
end
