--Into the VRAINS！
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡把1只怪兽效果无效特殊召唤，用包含那只怪兽的自己场上的怪兽为素材作连接召唤。那次连接召唤不会被无效化，在那次连接召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
-- ②：这张卡在墓地存在的状态，自己场上的连接怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从自己墓地选原本种族和那只怪兽相同的1只怪兽加入手卡。
function c28827503.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡把1只怪兽效果无效特殊召唤，用包含那只怪兽的自己场上的怪兽为素材作连接召唤。那次连接召唤不会被无效化，在那次连接召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28827503,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,28827503+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c28827503.target)
	e1:SetOperation(c28827503.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的连接怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从自己墓地选原本种族和那只怪兽相同的1只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28827503,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置②效果的发动代价为把墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(c28827503.thcon)
	e2:SetTarget(c28827503.thtg)
	e2:SetOperation(c28827503.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断额外卡组的连接怪兽c能否以mc（手卡特召的怪兽）作为连接素材进行连接召唤，即是否存在包含mc的素材组合。
function c28827503.lkfilter(c,mc)
	return c:IsLinkSummonable(nil,mc)
end
-- 过滤函数：选择手卡中能被该效果特殊召唤、且额外卡组存在能以它作为素材进行连接召唤的连接怪兽的怪兽。
function c28827503.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组是否存在至少1只能够以该手卡怪兽为素材进行连接召唤的连接怪兽。
		and Duel.IsExistingMatchingCard(c28827503.lkfilter,tp,LOCATION_EXTRA,0,1,nil,c)
end
-- ①效果的发动条件判定：确认自己仍能进行2次特殊召唤、主要怪兽区有空位、手卡存在符合条件的怪兽。
function c28827503.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp本回合还能进行至少2次特殊召唤（手卡特召1次+连接召唤1次）。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己主要怪兽区有空位，用于特殊召唤手卡怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足spfilter条件的1只怪兽。
		and Duel.IsExistingMatchingCard(c28827503.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果处理涉及特殊召唤，预计从手卡和额外卡组共特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_EXTRA)
end
-- ①效果处理：从手卡选1只符合条件的怪兽表侧表示特殊召唤并使其效果无效，若该怪兽仍在场上，则选择额外卡组1只可用其作素材的连接怪兽，并注册那次连接召唤不被无效化、成功时对方不能发动效果的限制，最后进行连接召唤。
function c28827503.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区还有空位，否则直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家弹出选择提示：请选择要特殊召唤的手卡怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足spfilter条件的怪兽（可被特殊召唤且可作为连接素材）。
	local g=Duel.SelectMatchingCard(tp,c28827503.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选择的手卡怪兽以表侧表示分步特殊召唤到主要怪兽区，若特殊召唤不成功则进入失败分支。
	if not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 若特殊召唤失败，结束特殊召唤流程并中止后续处理。
		Duel.SpecialSummonComplete()
		return
	end
	local c=e:GetHandler()
	-- 从手卡把1只怪兽效果无效特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
	-- 完成特殊召唤流程，使分步特殊召唤的手卡怪兽正式登场。
	Duel.SpecialSummonComplete()
	-- 刷新场地信息，确保刚特殊召唤的怪兽状态即时生效，以便后续判断其是否仍在主要怪兽区。
	Duel.AdjustAll()
	if not tc:IsLocation(LOCATION_MZONE) then return end
	-- 获取额外卡组中所有能够以刚特殊召唤的怪兽为素材进行连接召唤的连接怪兽，作为候选目标。
	local tg=Duel.GetMatchingGroup(c28827503.lkfilter,tp,LOCATION_EXTRA,0,nil,tc)
	if tg:GetCount()>0 then
		-- 弹出选择提示：请选择要连接召唤的连接怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 那次连接召唤不会被无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BE_PRE_MATERIAL)
		e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
		e3:SetCondition(c28827503.effcon)
		e3:SetOperation(c28827503.effop2)
		tc:RegisterEffect(e3,true)
		-- 在那次连接召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_BE_MATERIAL)
		e4:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
		e4:SetCondition(c28827503.effcon)
		e4:SetOperation(c28827503.effop1)
		tc:RegisterEffect(e4,true)
		-- 以包含刚特殊召唤的怪兽的自己场上怪兽为素材，将选择的连接怪兽进行连接召唤。
		Duel.LinkSummon(tp,sc,nil,tc)
	end
end
-- 效果触发条件：怪兽因连接召唤而被作为连接素材时才生效（r为REASON_LINK）。
function c28827503.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
-- 当素材怪兽被用于连接召唤后，给连接召唤成功的连接怪兽注册效果：在其特殊召唤成功时设置连锁限制，使对方不能发动效果。
function c28827503.effop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 那次连接召唤不会被无效化，在那次连接召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetOperation(c28827503.sumop)
	rc:RegisterEffect(e1,true)
	e:Reset()
end
-- 连接怪兽特殊召唤成功时，设置从当前到连锁结束的连锁限制。
function c28827503.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置直到连锁结束的连锁限制，限制内容由chainlm函数决定（只有连接召唤控制者能发动效果）。
	Duel.SetChainLimitTillChainEnd(c28827503.chainlm)
end
-- 连锁限制条件：只有效果发动者tp（连接召唤控制者）可以发动效果，对方不能发动魔法·陷阱·怪兽效果。
function c28827503.chainlm(e,rp,tp)
	return tp==rp
end
-- 在怪兽被作为连接素材前，给即将连接召唤的连接怪兽附加“该连接召唤不会被无效化”的效果。
function c28827503.effop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ②：这张卡在墓地存在的状态，自己场上的连接怪兽被战斗·效果破坏的场合，把这张卡除外才能发动。从自己墓地选原本种族和那只怪兽相同的1只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	e:Reset()
end
-- 过滤函数：判断被破坏的怪兽是自己场上、原在主要怪兽区、是连接怪兽，并且是被战斗或效果破坏。
function c28827503.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_LINK)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ②效果发动条件：被破坏的怪兽中存在自己场上被战斗或效果破坏的连接怪兽，且这张卡本身不包含在被破坏的怪兽中。
function c28827503.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28827503.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤函数：选择墓地中原本种族与破坏怪兽的原本种族（按位或）相同、且能够加入手卡的怪兽。
function c28827503.thfilter(c,race)
	return c:GetOriginalRace()&race>0 and c:IsAbleToHand()
end
-- ②效果的目标判定：从被破坏的连接怪兽中收集原本种族的并集，若墓地存在原本种族相符且可加入手卡的怪兽则可行，并记录该种族信息到效果标签。
function c28827503.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(c28827503.cfilter,nil,tp)
		local race=0
		local tc=g:GetFirst()
		while tc do
			race=bit.bor(race,tc:GetOriginalRace())
			tc=g:GetNext()
		end
		e:SetLabel(race)
		-- 检查墓地是否存在至少1只原本种族匹配且能够加入手卡的怪兽。
		return Duel.IsExistingMatchingCard(c28827503.thfilter,tp,LOCATION_GRAVE,0,1,nil,race)
	end
	-- 设置操作信息：本次效果处理涉及将1只怪兽加入手卡，检索位置为墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从墓地选择1只原本种族匹配且不受王家长眠之谷影响的怪兽加入手卡。
function c28827503.thop(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	-- 弹出选择提示：请选择要加入手卡的墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1只满足种族条件且不受王家长眠之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28827503.thfilter),tp,LOCATION_GRAVE,0,1,1,nil,race)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
