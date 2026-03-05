--アルトメギア・ペリペティア－激動－
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ①：以对方墓地1只怪兽为对象才能发动。自己场上1只「神艺」怪兽回到手卡·额外卡组，作为对象的怪兽效果无效在自己场上特殊召唤。
-- ②：这张卡为让「神艺学都 神艺学园」的效果发动而被送去墓地的场合才能发动。自己的墓地·除外状态的1张「神艺」魔法卡加入手卡。
local s,id,o=GetID()
-- 初始化效果函数，注册两个效果：①通常连锁发动效果；②墓地触发效果
function s.initial_effect(c)
	-- 记录该卡与「神艺学都 神艺学园」（卡号74733322）为同名卡
	aux.AddCodeList(c,74733322)
	-- ①：以对方墓地1只怪兽为对象才能发动。自己场上1只「神艺」怪兽回到手卡·额外卡组，作为对象的怪兽效果无效在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡为让「神艺学都 神艺学园」的效果发动而被送去墓地的场合才能发动。自己的墓地·除外状态的1张「神艺」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收魔法"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于限制每回合特殊召唤次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，若召唤地点不在额外卡组或为融合怪兽则不计入限制
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_FUSION)
end
-- 费用函数，检查是否已使用过效果，若未使用则设置不能特殊召唤非融合怪兽的限制
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已使用过效果
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个场地方效果，禁止非融合怪兽从额外卡组特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果函数，禁止非融合怪兽从额外卡组特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- 特殊召唤过滤函数，检查怪兽是否可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 选择目标过滤函数，检查场上「神艺」怪兽是否可以返回手牌或额外卡组
function s.thefilter(c,tp,chk)
	return c:IsFaceup() and c:IsSetCard(0x1cd) and (c:IsAbleToHand() or c:IsAbleToExtra())
		-- 若场上怪兽数量足够或不检查，则满足条件
		and (Duel.GetMZoneCount(tp,c)>0 or not chk)
end
-- 目标选择函数，检查是否有符合条件的目标怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.spfilter(chkc,e,tp) end
	-- 检查是否有符合条件的对方墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp)
		-- 检查是否有符合条件的己方场上「神艺」怪兽
		and Duel.IsExistingMatchingCard(s.thefilter,tp,LOCATION_MZONE,0,1,nil,tp,true) end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 发动效果函数，处理特殊召唤和效果无效
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local rg=nil
	-- 检查是否有符合条件的己方场上「神艺」怪兽
	if Duel.IsExistingMatchingCard(s.thefilter,tp,LOCATION_MZONE,0,1,nil,tp,true) then
		-- 选择要返回手牌的怪兽
		rg=Duel.SelectMatchingCard(tp,s.thefilter,tp,LOCATION_MZONE,0,1,1,nil,tp,true)
	else
		-- 选择要返回手牌的怪兽
		rg=Duel.SelectMatchingCard(tp,s.thefilter,tp,LOCATION_MZONE,0,1,1,nil,tp,false)
	end
	if rg and rg:GetCount()>0 then
		-- 显示选择的怪兽被选为对象
		Duel.HintSelection(rg)
		-- 将怪兽送回手牌并检查是否满足特殊召唤条件
		if Duel.SendtoHand(rg,nil,REASON_EFFECT)~=0 and rg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND+LOCATION_EXTRA)
			-- 检查目标怪兽是否与连锁相关且未受王家长眠之谷影响
			and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
			-- 执行特殊召唤步骤
			and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 使目标怪兽无效化
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使目标怪兽效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 墓地触发效果的发动条件，检查是否因支付费用而送去墓地且为「神艺学都 神艺学园」的效果
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:GetHandler():IsCode(74733322)
end
-- 墓地触发效果的魔法卡过滤函数，检查是否为「神艺」魔法卡
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1cd) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 墓地触发效果的目标选择函数，检查是否有符合条件的魔法卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有符合条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息，确定要加入手牌的魔法卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 墓地触发效果的发动处理函数，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择要加入手牌的魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的魔法卡
		Duel.ConfirmCards(1-tp,g)
	end
end
