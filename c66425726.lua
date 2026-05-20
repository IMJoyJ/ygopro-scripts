--オッドアイズ・ペンデュラムグラフ・ドラゴン
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己·对方的结束阶段才能发动。从自己的卡组·墓地选1张仪式魔法卡加入手卡。那之后，这张卡回到持有者手卡。
-- 【怪兽效果】
-- 「异色眼降临」降临。这张卡用仪式召唤以及从手卡的灵摆召唤才能特殊召唤。
-- ①：每次对方从额外卡组把怪兽特殊召唤，给与对方300伤害。
-- ②：1回合1次，对方把魔法卡的效果发动时才能发动。这张卡在自己的灵摆区域放置，那个对方的效果无效。把仪式召唤的这张卡在灵摆区域放置的场合，可以再从额外卡组把1只「异色眼」怪兽特殊召唤。
function c66425726.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动效果）
	aux.EnablePendulumAttribute(c)
	-- 允许这张卡从手卡进行灵摆召唤，并在此情况下解除苏生限制
	aux.EnableReviveLimitPendulumSummonable(c,LOCATION_HAND)
	-- 这张卡用仪式召唤以及从手卡的灵摆召唤才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为必须通过仪式召唤（或符合条件的灵摆召唤）才能特殊召唤
	e0:SetValue(aux.ritlimit)
	c:RegisterEffect(e0)
	-- ①：自己·对方的结束阶段才能发动。从自己的卡组·墓地选1张仪式魔法卡加入手卡。那之后，这张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66425726,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,66425726)
	e1:SetTarget(c66425726.thtg)
	e1:SetOperation(c66425726.thop)
	c:RegisterEffect(e1)
	-- ①：每次对方从额外卡组把怪兽特殊召唤，给与对方300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c66425726.damcon1)
	e2:SetOperation(c66425726.damop1)
	c:RegisterEffect(e2)
	-- ①：每次对方从额外卡组把怪兽特殊召唤，给与对方300伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c66425726.regcon)
	e3:SetOperation(c66425726.regop)
	c:RegisterEffect(e3)
	-- ①：每次对方从额外卡组把怪兽特殊召唤，给与对方300伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c66425726.damcon2)
	e4:SetOperation(c66425726.damop2)
	c:RegisterEffect(e4)
	-- ②：1回合1次，对方把魔法卡的效果发动时才能发动。这张卡在自己的灵摆区域放置，那个对方的效果无效。把仪式召唤的这张卡在灵摆区域放置的场合，可以再从额外卡组把1只「异色眼」怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(66425726,1))
	e5:SetCategory(CATEGORY_DISABLE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c66425726.discon)
	e5:SetTarget(c66425726.distg)
	e5:SetOperation(c66425726.disop)
	c:RegisterEffect(e5)
end
-- 过滤仪式魔法卡且能加入手卡的过滤函数
function c66425726.thfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 灵摆效果①的发动准备函数，检查卡组或墓地是否存在仪式魔法卡，并设置操作信息
function c66425726.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：检查自己卡组或墓地是否存在可检索的仪式魔法卡，且自身能回到手卡
	if chk==0 then return Duel.IsExistingMatchingCard(c66425726.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将自身加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 灵摆效果①的效果处理函数：从卡组或墓地将1张仪式魔法卡加入手卡，之后自身回到手卡
function c66425726.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或墓地选择1张仪式魔法卡（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c66425726.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 如果成功将选中的仪式魔法卡加入手卡
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
		if c:IsRelateToEffect(e) then
			-- 中断当前效果，使之后的效果处理（自身回手卡）视为不同时处理
			Duel.BreakEffect()
			-- 将这张卡（灵摆区域的自身）送回持有者手卡
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end
end
-- 过滤由指定玩家从额外卡组特殊召唤的怪兽的过滤函数
function c66425726.filter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 伤害效果①的触发条件（非连锁处理中）：对方从额外卡组特殊召唤了怪兽
function c66425726.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66425726.filter,1,nil,1-tp)
		-- 并且当前没有在进行连锁的效果处理（即非连锁中途的特殊召唤）
		and not Duel.IsChainSolving()
end
-- 伤害效果①的效果处理（非连锁处理中）：给与对方300点伤害
function c66425726.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动效果的卡片（显示卡片动画）
	Duel.Hint(HINT_CARD,0,66425726)
	-- 给与对方300点效果伤害
	Duel.Damage(1-tp,300,REASON_EFFECT)
end
-- 连锁处理中触发伤害的标记条件：对方在连锁处理中从额外卡组特殊召唤了怪兽
function c66425726.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66425726.filter,1,nil,1-tp)
		-- 并且当前正在进行连锁的效果处理
		and Duel.IsChainSolving()
end
-- 连锁处理中触发伤害的标记处理：在自身注册一个在连锁结束时重置的标记，记录触发次数
function c66425726.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(66425726,RESET_CHAIN,0,1)
end
-- 连锁处理完毕后触发伤害的条件：自身带有在连锁中触发特殊召唤的标记
function c66425726.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(66425726)>0
end
-- 连锁处理完毕后触发伤害的效果处理：根据标记数量给与对方对应的伤害（每次300）
function c66425726.damop2(e,tp,eg,ep,ev,re,r,rp)
	local n=e:GetHandler():GetFlagEffect(66425726)
	e:GetHandler():ResetFlagEffect(66425726)
	-- 提示发动效果的卡片（显示卡片动画）
	Duel.Hint(HINT_CARD,0,66425726)
	-- 给与对方 标记数量 * 300 点的效果伤害
	Duel.Damage(1-tp,n*300,REASON_EFFECT)
end
-- 怪兽效果②的发动条件：对方把魔法卡的效果发动，且该效果可以被无效，自身未被战斗破坏
function c66425726.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的魔法卡效果，且该效果可以被无效
	return ep==1-tp and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 怪兽效果②的发动准备：检查自身是否为灵摆怪兽、自己的灵摆区域是否有空位，并根据自身是否为仪式召唤设置效果分类
function c66425726.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOriginalType()&TYPE_PENDULUM~=0
		-- 并且自己的左侧或右侧灵摆区域有空位
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
	if e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) then
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	else
		e:SetCategory(CATEGORY_DISABLE)
	end
	-- 设置操作信息：无效该魔法卡的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 过滤额外卡组中可以特殊召唤的「异色眼」怪兽的过滤函数
function c66425726.spfilter(c,e,tp)
	-- 检查卡片是否属于「异色眼」系列，可以被特殊召唤，且额外卡组怪兽出场位置充足
	return c:IsSetCard(0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 怪兽效果②的效果处理：将自身放置在灵摆区域，无效对方的效果；若自身是仪式召唤的，可再从额外卡组特殊召唤1只「异色眼」怪兽
function c66425726.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
		-- 如果成功将自身移动并放置到自己的灵摆区域
		if Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and c:IsLocation(LOCATION_PZONE) then
			-- 如果成功无效了对方的效果，且这张卡是仪式召唤的
			if Duel.NegateEffect(ev) and c:IsSummonType(SUMMON_TYPE_RITUAL)
				-- 并且额外卡组存在可以特殊召唤的「异色眼」怪兽
				and Duel.IsExistingMatchingCard(c66425726.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
				-- 并且玩家选择发动特殊召唤的效果
				and Duel.SelectYesNo(tp,aux.Stringid(66425726,2)) then  --"是否从额外卡组把「异色眼」怪兽特殊召唤？"
				-- 中断当前效果，使之后的特殊召唤处理视为不同时处理
				Duel.BreakEffect()
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 让玩家从额外卡组选择1只满足条件的「异色眼」怪兽
				local g=Duel.SelectMatchingCard(tp,c66425726.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
				-- 将选中的「异色眼」怪兽在自己场上表侧表示特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
