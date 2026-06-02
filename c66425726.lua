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
	-- 登记这张卡卡名记有「异色眼降临」
	aux.AddCodeList(c,16494704)
	-- 为这张卡注册灵摆怪兽属性及相关基本规则效果
	aux.EnablePendulumAttribute(c)
	-- 允许该仪式怪兽在满足苏生限制的条件下能从手卡进行灵摆召唤
	aux.EnableReviveLimitPendulumSummonable(c,LOCATION_HAND)
	-- 这张卡用仪式召唤以及从手卡的灵摆召唤才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置除仪式召唤（或允许的特殊灵摆召唤）以外不能特殊召唤的限制过滤条件
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
-- 过滤卡组或墓地中可检索的仪式魔法卡
function c66425726.thfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 仪式魔法卡检索及自身回手效果的发动准备与合法性检查
function c66425726.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在可回收的仪式魔法卡，且自身能回到手牌
	if chk==0 then return Duel.IsExistingMatchingCard(c66425726.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and e:GetHandler():IsAbleToHand() end
	-- 设置在连锁处理时将自身送回手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 仪式魔法卡检索及自身回手效果的实际处理过程
function c66425726.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入手牌的仪式魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组或墓地中选择1张满足条件的仪式魔法卡（受王家长眠之谷限制）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c66425726.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	-- 如果成功将仪式魔法卡加入手牌，则继续处理
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 让玩家对方确认加入手牌的仪式魔法卡
		Duel.ConfirmCards(1-tp,tc)
		if c:IsRelateToEffect(e) then
			-- 中断当前效果，使检索仪式魔法卡和自身回手效果视为不同时处理
			Duel.BreakEffect()
			-- 将此卡送回持有者手牌
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end
end
-- 过滤对方从额外卡组特殊召唤的怪兽
function c66425726.filter(c,sp)
	return c:IsSummonPlayer(sp) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 检查对方是否在连锁之外成功特殊召唤了额外卡组怪兽，作为直接伤害效果的触发条件
function c66425726.damcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66425726.filter,1,nil,1-tp)
		-- 且当前不处于连锁效果处理中
		and not Duel.IsChainSolving()
end
-- 在连锁之外触发时，给与对方伤害的实际处理过程
function c66425726.damop1(e,tp,eg,ep,ev,re,r,rp)
	-- 手动显示此卡的卡片发动动画
	Duel.Hint(HINT_CARD,0,66425726)
	-- 给与对方300点效果伤害
	Duel.Damage(1-tp,300,REASON_EFFECT)
end
-- 检查对方是否在连锁效果处理中特殊召唤了额外怪兽，作为注册伤害标志效果的触发条件
function c66425726.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66425726.filter,1,nil,1-tp)
		-- 且当前正处于连锁效果处理中
		and Duel.IsChainSolving()
end
-- 在该连锁内为卡片注册标记效果，记录该连锁处理中对方从额外卡组特召怪兽的次数
function c66425726.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(66425726,RESET_CHAIN,0,1)
end
-- 检查自身是否被标记了在连锁处理中对方召唤过额外怪兽的标志，作为伤害结算的条件
function c66425726.damcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(66425726)>0
end
-- 连锁处理结束时，根据记录的标志次数，一次性给与对方对应倍数伤害的实际处理过程
function c66425726.damop2(e,tp,eg,ep,ev,re,r,rp)
	local n=e:GetHandler():GetFlagEffect(66425726)
	e:GetHandler():ResetFlagEffect(66425726)
	-- 手动显示此卡的卡片发动动画
	Duel.Hint(HINT_CARD,0,66425726)
	-- 一次性给与对方对方特殊召唤额外怪兽次数乘以300的伤害
	Duel.Damage(1-tp,n*300,REASON_EFFECT)
end
-- 魔法无效效果的发动条件判定（对方发动魔法卡且可被无效）
function c66425726.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否为对方玩家发动的魔法卡的效果，且该效果能被无效
	return ep==1-tp and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 魔法无效并放置于灵摆区效果的发动准备与合法性检查
function c66425726.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOriginalType()&TYPE_PENDULUM~=0
		-- 且自己场上的灵摆区域（左灵摆区或右灵摆区）存在可用空位
		and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
	if e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) then
		e:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
	else
		e:SetCategory(CATEGORY_DISABLE)
	end
	-- 设置在连锁处理时无效目标效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 过滤额外卡组中可特殊召唤的「异色眼」怪兽
function c66425726.spfilter(c,e,tp)
	-- 返回满足是「异色眼」怪兽、能够被特殊召唤、且额外怪兽出场格数大于0的卡片过滤
	return c:IsSetCard(0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 魔法无效并放置于灵摆区，以及满足条件时特殊召唤「异色眼」怪兽的实际处理过程
function c66425726.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
		-- 成功把这张表侧表示的卡移动到自己的灵摆区域后继续处理
		if Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) and c:IsLocation(LOCATION_PZONE) then
			-- 若成功无效对方发动的魔法卡效果，且此卡在场上时是以仪式召唤的形式召唤的
			if Duel.NegateEffect(ev) and c:IsSummonType(SUMMON_TYPE_RITUAL)
				-- 且额外卡组中存在可特殊召唤的「异色眼」怪兽
				and Duel.IsExistingMatchingCard(c66425726.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
				-- 且玩家选择进行特殊召唤时
				and Duel.SelectYesNo(tp,aux.Stringid(66425726,2)) then  --"是否从额外卡组把「异色眼」怪兽特殊召唤？"
				-- 中断当前效果，使无效效果与特殊召唤新怪兽视为不同时处理
				Duel.BreakEffect()
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 玩家从额外卡组选择1只「异色眼」怪兽
				local g=Duel.SelectMatchingCard(tp,c66425726.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
				-- 将所选怪兽在自己场上表侧表示特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
