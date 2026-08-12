--受け継ぎし魂
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己只能用1只怪兽攻击。
-- ①：把自己场上1只效果怪兽解放，以对方场上1只效果怪兽为对象才能发动。那只怪兽送去墓地。那之后，从手卡·卡组把1只7星以上的通常怪兽在自己场上特殊召唤。
function c69145169.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己只能用1只怪兽攻击。①：把自己场上1只效果怪兽解放，以对方场上1只效果怪兽为对象才能发动。那只怪兽送去墓地。那之后，从手卡·卡组把1只7星以上的通常怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69145169,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,69145169+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c69145169.cost)
	e1:SetTarget(c69145169.target)
	e1:SetOperation(c69145169.activate)
	c:RegisterEffect(e1)
	if not c69145169.global_check then
		c69145169.global_check=true
		-- 这张卡发动的回合，自己只能用1只怪兽攻击。①：把自己场上1只效果怪兽解放，以对方场上1只效果怪兽为对象才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c69145169.checkop)
		-- 注册全局效果，用于记录玩家的攻击宣言次数。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言时的全局监听函数，用于记录怪兽的攻击状态和玩家的攻击次数。
function c69145169.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p=tc:GetControler()
	if tc:GetFlagEffect(69145169)==0 then
		tc:RegisterFlagEffect(69145169,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 检查该玩家在本回合是否是第一次进行攻击宣言。
		if Duel.GetFlagEffect(p,69145169)==0 then
			-- 给玩家注册已进行过1次攻击宣言的标记。
			Duel.RegisterFlagEffect(p,69145169,RESET_PHASE+PHASE_END,0,1)
		else
			-- 给玩家注册已进行过2次或以上攻击宣言的标记（用于限制不能发动此卡）。
			Duel.RegisterFlagEffect(p,69145170,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 过滤对方场上表侧表示、可以送去墓地的效果怪兽。
function c69145169.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsAbleToGrave()
end
-- 过滤自己场上可以解放的效果怪兽，且必须满足对方场上有可作为对象的效果怪兽。
function c69145169.costfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_EFFECT) and (c:IsFaceup() or c:IsControler(tp))
		-- 检查对方场上是否存在至少1只可作为对象的效果怪兽（排除自身）。
		and Duel.IsExistingTarget(c69145169.filter,tp,0,LOCATION_MZONE,1,c)
end
-- 效果发动的Cost处理，检查攻击限制并解放自己场上1只效果怪兽。
function c69145169.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤1：检查本回合自己是否未进行过2次或以上的攻击宣言。
	if chk==0 then return Duel.GetFlagEffect(tp,69145170)==0
		-- 步骤2：检查自己场上是否存在可解放的效果怪兽。
		and Duel.CheckReleaseGroup(tp,c69145169.costfilter,1,nil,tp) end
	-- 玩家选择自己场上1只效果怪兽解放。
	local g=Duel.SelectReleaseGroup(tp,c69145169.costfilter,1,1,nil,tp)
	-- 解放选中的怪兽作为发动Cost。
	Duel.Release(g,REASON_COST)
	-- 这张卡发动的回合，自己只能用1只怪兽攻击。①：以对方场上1只效果怪兽为对象才能发动。那只怪兽送去墓地。那之后，从手卡·卡组把1只7星以上的通常怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c69145169.atkcon)
	e1:SetTarget(c69145169.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制攻击的效果给发动玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制效果的启用条件：本回合自己已经进行过攻击宣言。
function c69145169.atkcon(e)
	-- 检查玩家本回合是否已经进行过至少1次攻击宣言。
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),69145169)~=0
end
-- 攻击限制效果的对象过滤：使本回合未进行过攻击宣言的其他怪兽不能攻击。
function c69145169.atktg(e,c)
	return c:GetFlagEffect(69145169)==0
end
-- 过滤手卡·卡组中可以特殊召唤的7星以上的通常怪兽。
function c69145169.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的Target处理，检查并选择对方场上的效果怪兽作为对象，并声明特殊召唤效果。
function c69145169.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c69145169.filter(chkc) end
	-- 步骤1：检查对方场上是否存在可作为对象的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(c69145169.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 步骤2：检查自己手卡·卡组是否存在可特殊召唤的7星以上通常怪兽。
		and Duel.IsExistingMatchingCard(c69145169.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择对方场上1只效果怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c69145169.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将选中的1只怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置效果处理信息：从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理函数，将对象怪兽送去墓地，并特殊召唤手卡·卡组的7星以上通常怪兽。
function c69145169.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽用效果送去墓地，并确认其已成功送去墓地。
		if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
			-- 检查自己场上是否有可用的怪兽区域，若无则结束效果处理。
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 玩家从手卡·卡组选择1只满足条件的7星以上通常怪兽。
			local g=Duel.SelectMatchingCard(tp,c69145169.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 中断当前效果处理，使后续的特殊召唤处理与送去墓地不视为同时处理。
				Duel.BreakEffect()
				-- 将选中的通常怪兽在自己场上表侧表示特殊召唤。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
