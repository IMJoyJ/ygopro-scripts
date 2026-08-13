--幻獣機アウローラドン
-- 效果：
-- 机械族怪兽2只以上
-- ①：这张卡连接召唤成功的场合才能发动。在自己场上把3只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这个回合，自己不能连接召唤。
-- ②：1回合1次，把自己场上最多3只怪兽解放才能发动。解放的怪兽数量的以下效果适用。
-- ●1只：选场上1张卡破坏。
-- ●2只：从卡组把1只「幻兽机」怪兽特殊召唤。
-- ●3只：从自己墓地选1张陷阱卡加入手卡。
function c44097050.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：需要2只以上机械族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2)
	-- ①：这张卡连接召唤成功的场合才能发动。在自己场上把3只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这个回合，自己不能连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44097050,0))  --"特殊召唤衍生物"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c44097050.tkcon)
	e1:SetTarget(c44097050.tktg)
	e1:SetOperation(c44097050.tkop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把自己场上最多3只怪兽解放才能发动。解放的怪兽数量的以下效果适用。●1只：选场上1张卡破坏。●2只：从卡组把1只「幻兽机」怪兽特殊召唤。●3只：从自己墓地选1张陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44097050,1))  --"解放怪兽"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c44097050.rlcost)
	e2:SetTarget(c44097050.rltg)
	e2:SetOperation(c44097050.rlop)
	c:RegisterEffect(e2)
end
-- 触发条件判断：这张卡是以连接召唤方式成功特殊召唤的场合才满足发动条件。
function c44097050.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 发动时合法性检查：确认己方不受“青眼精灵龙”等“不能同时特殊召唤2只以上怪兽”效果影响，并有足够怪兽区空格且能特殊召唤3只幻兽机衍生物。
function c44097050.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查己方主要怪兽区可用空格数大于2（至少需要3个空位才能放置3只衍生物）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查己方玩家是否能特殊召唤3只“幻兽机衍生物”（机械族·风·3星·攻/守0，衍生物类型）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置操作信息：本次效果将特殊召唤3只怪兽，用于连锁/效果应对的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
	-- 设置操作信息：本次效果将生成3只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
end
-- 效果处理时再次确认条件，若满足则连续创建3只幻兽机衍生物并特殊召唤，随后给己方附加“这个回合不能连接召唤”的限制。
function c44097050.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 效果处理时再次检查是否能特殊召唤3只幻兽机衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		local ct=3
		while ct>0 do
			-- 创建1只幻兽机衍生物（卡号44097051）的token。
			local token=Duel.CreateToken(tp,44097051)
			-- 将衍生物以表侧表示作为连续特殊召唤的一步特殊召唤出来。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			ct=ct-1
		end
		-- 完成连续特殊召唤步骤，统一处理所有衍生物特殊召唤成功。
		Duel.SpecialSummonComplete()
	end
	-- 这个回合，自己不能连接召唤。②：1回合1次，把自己场上最多3只怪兽解放才能发动。解放的怪兽数量的以下效果适用。●1只：选场上1张卡破坏。●2只：从卡组把1只「幻兽机」怪兽特殊召唤。●3只：从自己墓地选1张陷阱卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44097050.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能连接召唤”的限制效果作为场地效果注册到场上，持续到本回合结束，且只影响己方玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制判断函数：若召唤类型为连接召唤则禁止该次特殊召唤，从而实现“这个回合自己不能连接召唤”。
function c44097050.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- costfilter过滤器：判断某卡之外场上是否还存在其他卡，用于解放1只分支的可行性检查。
function c44097050.costfilter(c,tp)
	-- 检查场上除c外是否存在至少1张卡。
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- spfilter过滤器：判定卡组中的卡是否为「幻兽机」字段怪兽且能够被特殊召唤。
function c44097050.spfilter(c,e,tp)
	return c:IsSetCard(0x101b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- thfilter过滤器：判定墓地中的卡是否为陷阱卡且能够加入手卡。
function c44097050.thfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 发动代价处理：根据可选的解放数量显示选项，让玩家选择解放1/2/3只，并选择对应解放卡后解放作为cost。
function c44097050.rlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方玩家当前可解放的怪兽集合（非上级召唤用）。
	local g=Duel.GetReleaseGroup(tp)
	-- 检查是否存在1张满足costfilter的怪兽可被解放（对应解放1只分支）。
	local b1=Duel.CheckReleaseGroup(tp,c44097050.costfilter,1,nil,tp)
	-- 检查可解放怪兽数多于1只，且解放2只后己方场上仍有怪兽区空格（对应解放2只并特召的情况）。
	local b2=g:GetCount()>1 and g:CheckSubGroup(aux.mzctcheck,2,2,tp)
		-- 检查卡组中是否存在可特殊召唤的「幻兽机」怪兽（解放2只分支的后续条件）。
		and Duel.IsExistingMatchingCard(c44097050.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	-- 检查场上是否有3只可解放怪兽且墓地存在满足thfilter的陷阱卡（解放3只分支）。
	local b3=Duel.CheckReleaseGroup(tp,nil,3,nil) and Duel.IsExistingMatchingCard(c44097050.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	local off=0
	local ops={}
	local opval={}
	off=1
	if b1 then
		ops[off]=aux.Stringid(44097050,2)  --"1只：选场上1张卡破坏"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(44097050,3)  --"2只：从卡组把1只「幻兽机」怪兽特殊召唤"
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(44097050,4)  --"3只：从自己墓地选1张陷阱卡加入手卡"
		opval[off-1]=3
		off=off+1
	end
	-- 让玩家从可用分支中选择要适用的解放数量，返回所选选项序号。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(opval[op])
	local rg=nil
	if opval[op]==1 then
		-- 选择解放1只怪兽时，从场上选择1只满足costfilter的可解放怪兽。
		rg=Duel.SelectReleaseGroup(tp,c44097050.costfilter,1,1,nil,tp)
	elseif opval[op]==2 then
		-- 提示玩家选择要解放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 选择解放2只怪兽时，从可解放卡组中选择2只，且保证解放后仍有怪兽区空格供后续特殊召唤使用。
		rg=g:SelectSubGroup(tp,aux.mzctcheck,false,2,2,tp)
		-- 如果使用了“暗影敌托邦”等代替解放效果，消耗对应的使用次数。
		aux.UseExtraReleaseCount(rg,tp)
	else
		-- 选择解放3只怪兽时，直接从可解放怪兽中选择3只。
		rg=Duel.SelectReleaseGroup(tp,nil,3,3,nil)
	end
	-- 将选中的怪兽解放，作为效果发动的代价。
	Duel.Release(rg,REASON_COST)
end
-- 目标阶段根据已选择的解放数量设置对应的效果类别和操作信息（破坏/特殊召唤/加入手卡）。
function c44097050.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sel=e:GetLabel()
	local cat=0
	if sel==1 then
		-- 获取场上所有卡作为破坏候选集合。
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		e:SetCategory(bit.bor(cat,CATEGORY_DESTROY))
		-- 设置操作信息：本次效果将破坏场上1张卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	elseif sel==2 then
		e:SetCategory(bit.bor(cat,CATEGORY_SPECIAL_SUMMON))
		-- 设置操作信息：本次效果将从卡组特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(bit.bor(cat,CATEGORY_TOHAND))
		-- 设置操作信息：本次效果将从墓地选1张陷阱卡加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 效果处理阶段根据解放数量分别执行：破坏场上1张卡、从卡组特殊召唤1只「幻兽机」怪兽、或从墓地选1张陷阱卡加入手卡。
function c44097050.rlop(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从场上选择1张卡作为破坏对象。
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 给被选中的卡播放被选为对象的动画，并记录该卡为对象。
			Duel.HintSelection(g)
			-- 将选择的卡以效果破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif sel==2 then
		-- 特殊召唤前检查自己怪兽区是否有空位，若没有空位则直接结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足spfilter的「幻兽机」怪兽。
		local g=Duel.SelectMatchingCard(tp,c44097050.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的「幻兽机」怪兽特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 提示玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从墓地选择1张陷阱卡，且不受王家长眠之谷等效果影响。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c44097050.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认被加入手卡的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
