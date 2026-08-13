--鉄獣戦線 徒花のフェリジット
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只4星以下的兽族·兽战士族·鸟兽族怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
-- ②：这张卡被送去墓地的场合才能发动。自己抽1张。那之后，选1张自己的手卡回到卡组最下面。
function c26847978.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只兽族·兽战士族·鸟兽族怪兽作为连接素材（满足其中一种种族即可）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),2,2)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。从手卡把1只4星以下的兽族·兽战士族·鸟兽族怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26847978,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,26847978)
	e1:SetTarget(c26847978.sptg)
	e1:SetOperation(c26847978.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。自己抽1张。那之后，选1张自己的手卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26847978,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,26847979)
	e2:SetTarget(c26847978.drtg)
	e2:SetOperation(c26847978.drop)
	c:RegisterEffect(e2)
end
-- 定义①效果的特殊召唤过滤条件：满足兽族/兽战士族/鸟兽族之一、等级4以下、且可被效果特殊召唤的怪兽。
function c26847978.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件检查：在chk==0时，确认自己主要怪兽区存在空位且手牌有满足spfilter条件的怪兽。
function c26847978.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ①效果的发动条件：自己主要怪兽区必须存在可用空格，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ①效果的发动条件：手牌中必须存在至少1只满足spfilter条件的怪兽（4星以下兽族/兽战士族/鸟兽族且可特殊召唤）。
		and Duel.IsExistingMatchingCard(c26847978.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：标记为特殊召唤分类，预计从手牌特殊召唤1只怪兽（对象在处理时选择，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果处理：若主要怪兽区有空位，从手牌选1只符合条件的怪兽表侧特殊召唤；随后给自己场上施加自肃，使非兽族/兽战士族/鸟兽族怪兽不能作为连接素材。
function c26847978.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 特殊召唤处理前再次确认主要怪兽区仍有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示，要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌选择1张满足spfilter条件的怪兽作为特殊召唤对象（若无合法对象则选择结果为空）。
		local g=Duel.SelectMatchingCard(tp,c26847978.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上（不检查召唤条件与苏生限制）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。②：这张卡被送去墓地的场合才能发动。自己抽1张。那之后，选1张自己的手卡回到卡组最下面。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置自肃效果的影响对象：不是兽族/兽战士族/鸟兽族的怪兽（这些怪兽不能作为连接素材）。
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)))
	e1:SetValue(c26847978.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到当前玩家场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的Value函数：仅当怪兽的控制者是发动①效果的玩家时，才适用“不能作为连接素材”的限制。
function c26847978.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- ②效果的发动条件与目标设置：判定自己能否抽1张卡；若可以，则设置目标玩家为自己、参数为1，并设置操作信息。
function c26847978.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果的发动条件检查：自己必须能够抽1张卡（卡组有卡且无抽卡限制）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设为自己，表示后续抽卡与回卡组的玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：包含抽卡分类，预计自己抽1张卡（具体抽到的卡在处理时确定，targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置操作信息：包含回卡组分类，预计从自己手牌选1张卡返回卡组（具体卡在处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,1)
end
-- ②效果处理：先执行抽1张卡，若成功，则选择1张自己的手卡返回卡组最下面；若抽卡失败则不再处理回卡组。
function c26847978.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家p（自己）和参数d（1），用于后续抽卡。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡：玩家p抽d张卡；若实际抽卡数为0，则终止效果处理。
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	-- 显示选择提示，要求玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己的手牌中选择1张能够返回卡组的卡（通常刚抽到的卡），作为回卡组对象。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果链，使抽卡和回卡组分步处理，避免错过抽卡后的时点。
		Duel.BreakEffect()
		-- 将选中的手牌返回其持有者卡组最下面。
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
