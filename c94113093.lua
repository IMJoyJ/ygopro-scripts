--らくがきちょう－とおせんぼ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的恐龙族怪兽被选择作为攻击对象时才能发动。那次攻击无效。那之后，可以从自己墓地选1只「涂鸦兽」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏，结束阶段破坏。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只5星以上的恐龙族怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c94113093.initial_effect(c)
	-- ①：自己的恐龙族怪兽被选择作为攻击对象时才能发动。那次攻击无效。那之后，可以从自己墓地选1只「涂鸦兽」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCountLimit(1,94113093)
	e1:SetCondition(c94113093.negcon)
	e1:SetOperation(c94113093.negop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1只5星以上的恐龙族怪兽加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,94113094)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 限制该效果在这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c94113093.thtg)
	e2:SetOperation(c94113093.thop)
	c:RegisterEffect(e2)
end
-- 检查被选择作为攻击对象的怪兽是否是自己场上表侧表示的恐龙族怪兽
function c94113093.negcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsFaceup() and tc:IsRace(RACE_DINOSAUR)
end
-- 过滤自己墓地中可以特殊召唤的「涂鸦兽」怪兽
function c94113093.spfilter(c,e,tp)
	return c:IsSetCard(0x1185) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理：无效攻击，并可以从墓地特殊召唤1只「涂鸦兽」怪兽，使其获得战破抗性并在结束阶段破坏
function c94113093.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效那次攻击，若成功则继续处理
	if Duel.NegateAttack() then
		-- 获取自己墓地中不受「王家之谷」影响且满足特殊召唤条件的「涂鸦兽」怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c94113093.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
		-- 获取自己场上可用的怪兽区域数量
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 若有可用怪兽区域、墓地有符合条件的怪兽，且玩家选择进行特殊召唤
		if ct>0 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(94113093,0)) then  --"是否从墓地特殊召唤？"
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			if tc then
				-- 中断当前效果处理，使后续的特殊召唤处理不与无效攻击同时进行
				Duel.BreakEffect()
				-- 将选中的怪兽在自己场上表侧表示特殊召唤
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
				local fid=e:GetHandler():GetFieldID()
				tc:RegisterFlagEffect(94113093,RESET_EVENT+RESETS_STANDARD,0,1,fid)
				-- 这个效果特殊召唤的怪兽不会被战斗破坏
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(94113093,2))  --"「涂鸦本-挡路」效果适用中"
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 结束阶段破坏。
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetCode(EVENT_PHASE+PHASE_END)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e2:SetCountLimit(1)
				e2:SetLabel(fid)
				e2:SetLabelObject(tc)
				e2:SetCondition(c94113093.descon)
				e2:SetOperation(c94113093.desop)
				-- 注册在结束阶段破坏该怪兽的全局延迟效果
				Duel.RegisterEffect(e2,tp)
			end
		end
	end
end
-- 检查目标怪兽是否仍带有对应的标记，若不带则重置此效果，若带则在结束阶段触发
function c94113093.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(94113093)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行结束阶段破坏怪兽的操作
function c94113093.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将目标怪兽破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
-- 过滤卡组中5星以上的恐龙族怪兽
function c94113093.thfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查卡组中是否存在符合条件的怪兽，并设置检索操作信息
function c94113093.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只5星以上的恐龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94113093.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组将1只5星以上的恐龙族怪兽加入手卡
function c94113093.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只5星以上的恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c94113093.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
