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
	-- 为卡片添加连接召唤手续，要求使用至少2个机械族怪兽作为连接素材
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
-- 判断此卡是否为连接召唤 summoned
function c44097050.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检查是否满足特殊召唤衍生物的条件：未受青眼精灵龙影响、场上怪兽区空位大于2、可以特殊召唤衍生物
function c44097050.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查场上怪兽区空位是否大于2
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) end
	-- 设置连锁操作信息：特殊召唤3只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
	-- 设置连锁操作信息：召唤3只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
end
-- 执行特殊召唤衍生物的操作：创建并特殊召唤3只衍生物
function c44097050.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		local ct=3
		while ct>0 do
			-- 创建一只幻兽机衍生物
			local token=Duel.CreateToken(tp,44097051)
			-- 将衍生物特殊召唤到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			ct=ct-1
		end
		-- 完成特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
	-- 设置永续效果：本回合不能连接召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44097050.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制连接召唤的特殊召唤
function c44097050.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- 检查场上是否存在至少一张可以解放的卡
function c44097050.costfilter(c,tp)
	-- 检查场上是否存在至少一张可以解放的卡
	return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 检查是否为幻兽机卡组的怪兽且可以特殊召唤
function c44097050.spfilter(c,e,tp)
	return c:IsSetCard(0x101b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否为陷阱卡且可以加入手牌
function c44097050.thfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置解放怪兽的费用：检查是否有满足条件的怪兽可解放并选择效果
function c44097050.rlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家可解放的卡片组
	local g=Duel.GetReleaseGroup(tp)
	-- 检查是否有至少一张满足条件的怪兽可解放
	local b1=Duel.CheckReleaseGroup(tp,c44097050.costfilter,1,nil,tp)
	-- 检查是否有至少两张怪兽可解放且满足怪兽区空位要求
	local b2=g:GetCount()>1 and g:CheckSubGroup(aux.mzctcheck,2,2,tp)
		-- 检查卡组中是否存在幻兽机怪兽
		and Duel.IsExistingMatchingCard(c44097050.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	-- 检查墓地中是否存在陷阱卡
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
	-- 选择发动的效果
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(opval[op])
	local rg=nil
	if opval[op]==1 then
		-- 选择1只满足条件的怪兽进行解放
		rg=Duel.SelectReleaseGroup(tp,c44097050.costfilter,1,1,nil,tp)
	elseif opval[op]==2 then
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 选择2只满足条件的怪兽进行解放
		rg=g:SelectSubGroup(tp,aux.mzctcheck,false,2,2,tp)
		-- 使用额外的解放次数
		aux.UseExtraReleaseCount(rg,tp)
	else
		-- 选择3只怪兽进行解放
		rg=Duel.SelectReleaseGroup(tp,nil,3,3,nil)
	end
	-- 解放选定的怪兽
	Duel.Release(rg,REASON_COST)
end
-- 设置效果的处理目标：根据选择的效果设置不同的处理类别
function c44097050.rltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sel=e:GetLabel()
	local cat=0
	if sel==1 then
		-- 获取场上所有卡
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		e:SetCategory(bit.bor(cat,CATEGORY_DESTROY))
		-- 设置连锁操作信息：破坏1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	elseif sel==2 then
		e:SetCategory(bit.bor(cat,CATEGORY_SPECIAL_SUMMON))
		-- 设置连锁操作信息：特殊召唤1只幻兽机怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(bit.bor(cat,CATEGORY_TOHAND))
		-- 设置连锁操作信息：加入手牌1张陷阱卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 执行效果处理：根据选择的效果执行对应操作
function c44097050.rlop(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1张卡进行破坏
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 显示被选为对象的动画效果
			Duel.HintSelection(g)
			-- 破坏选定的卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif sel==2 then
		-- 检查场上是否有怪兽区空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只幻兽机怪兽
		local g=Duel.SelectMatchingCard(tp,c44097050.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 特殊召唤选定的怪兽
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从墓地选择1张陷阱卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c44097050.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选定的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方看到选定的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
