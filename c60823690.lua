--霊魂鳥影－彦孔雀
-- 效果：
-- 「灵魂的降神」降临
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在手卡·场上存在当作「灵魂鸟神-彦孔雀」使用。
-- ②：把仪式召唤的这张卡解放才能发动。从卡组把1只灵魂怪兽和1张仪式魔法卡加入手卡。
-- ③：这张卡被除外的下个回合的准备阶段发动。除外状态的这张卡特殊召唤。
-- ④：这张卡特殊召唤的回合的结束阶段发动。这张卡回到手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含仪式召唤限制、卡名变更、检索效果、除外时标记、下个回合准备阶段特殊召唤以及灵魂怪兽回手效果。
function s.initial_effect(c)
	aux.AddCodeList(c,73055622)
	c:EnableReviveLimit()
	-- 设置这张卡在手卡·场上存在时，卡名当作「灵魂鸟神-彦孔雀」使用。
	aux.EnableChangeCode(c,52900000,LOCATION_HAND+LOCATION_MZONE)
	-- ②：把仪式召唤的这张卡解放才能发动。从卡组把1只灵魂怪兽和1张仪式魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ③：这张卡被除外
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- 下个回合的准备阶段发动。除外状态的这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 注册灵魂怪兽在特殊召唤的回合的结束阶段回到手卡的效果。
	aux.EnableSpiritReturn(c,EVENT_SPSUMMON_SUCCESS)
end
-- 判断此卡是否为仪式召唤，作为检索效果的发动条件。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 定义检索效果的发动成本：解放自身。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 作为发动成本解放自身。
	Duel.Release(c,REASON_COST)
end
-- 过滤函数：筛选卡组中可以加入手牌的指定类型的卡片。
function s.filter(c,typ)
	return c:GetType()&typ==typ and c:IsAbleToHand()
end
-- 检索效果的靶向函数：检查卡组中是否存在可检索的灵魂怪兽和仪式魔法卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只灵魂怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,TYPE_SPIRIT)
		-- 检查卡组中是否存在至少1张仪式魔法卡。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,0x82) end
	-- 设置连锁信息：从卡组将2张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 检索效果的处理函数：从卡组将1只灵魂怪兽和1张仪式魔法卡加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 若卡组中已不存在仪式魔法卡，则不处理效果。
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,0x82) then return end
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只灵魂怪兽。
	local g1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,TYPE_SPIRIT)
	if #g1>0 then
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张仪式魔法卡。
		local g2=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,0x82)
		g1:Merge(g2)
		-- 将选中的卡片加入玩家手牌。
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g1)
	end
end
-- 注册除外时标记的函数，用于记录被除外时的回合数。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 给自身注册一个带有当前回合数作为标签的Flag，持续到下个回合的准备阶段。
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2,Duel.GetTurnCount())
end
-- 特殊召唤效果的发动条件：当前回合是被除外回合的下个回合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetFlagEffectLabel(id)
	-- 获取当前的回合数。
	local tn=Duel.GetTurnCount()
	if not ct or tn==ct then
		c:ResetFlagEffect(id)
		return false
	else return tn==ct+1 end
end
-- 特殊召唤效果的靶向函数：设置特殊召唤自身的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数：将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于除外区，则将其以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
