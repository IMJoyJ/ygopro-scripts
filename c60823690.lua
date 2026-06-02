--霊魂鳥影－彦孔雀
-- 效果：
-- 「灵魂的降神」降临
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在手卡·场上存在当作「灵魂鸟神-彦孔雀」使用。
-- ②：把仪式召唤的这张卡解放才能发动。从卡组把1只灵魂怪兽和1张仪式魔法卡加入手卡。
-- ③：这张卡被除外的下个回合的准备阶段发动。除外状态的这张卡特殊召唤。
-- ④：这张卡特殊召唤的回合的结束阶段发动。这张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册苏生限制、卡名变更、检索并加入手牌效果、被除外时的标记注册、除外下个回合的特召效果，以及灵魂怪兽回到手牌的效果
function s.initial_effect(c)
	-- 记录此卡记述了「灵魂的降神」的卡名事实，以支持相关检索判定
	aux.AddCodeList(c,73055622)
	c:EnableReviveLimit()
	-- 只要这张卡在手卡·场上存在，卡名当作「灵魂鸟神-彦孔雀」使用
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
	-- ③：这张卡被除外的下个回合的准备阶段发动。除外状态的这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的下个回合的准备阶段发动。除外状态的这张卡特殊召唤。
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
	-- ④：这张卡特殊召唤的回合的结束阶段发动。这张卡回到手卡。
	aux.EnableSpiritReturn(c,EVENT_SPSUMMON_SUCCESS)
end
-- 效果②的发动条件判定：这张卡必须是仪式召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果②的Cost支付判定：检查当前卡片是否可以解放，并将其解放
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 解放自身作为效果发动的代价
	Duel.Release(c,REASON_COST)
end
-- 过滤函数：筛选卡片类型包含指定类型，且可以加入手牌的卡
function s.filter(c,typ)
	return c:GetType()&typ==typ and c:IsAbleToHand()
end
-- 效果②的发动准备与条件检查：检查卡组是否同时存在可检索的灵魂怪兽和仪式魔法卡，并设置连锁的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：检查卡组中是否存在可以加入手牌的灵魂怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,TYPE_SPIRIT)
		-- 检查卡组中是否存在可以加入手牌的仪式魔法卡
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,0x82) end
	-- 设置操作信息：从卡组检索2张卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果②的效果处理：分别从卡组选择1只灵魂怪兽和1张仪式魔法卡加入手卡，并向对方玩家确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 安全检查：在效果处理时再次检查卡组中是否存在符合条件的仪式魔法卡
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,0x82) then return end
	-- 向玩家发送提示信息，要求选择要加入手牌的灵魂怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只符合条件的灵魂怪兽
	local g1=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,TYPE_SPIRIT)
	if #g1>0 then
		-- 向玩家发送提示信息，要求选择要加入手牌的仪式魔法卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组中选择1张符合条件的仪式魔法卡
		local g2=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,0x82)
		g1:Merge(g2)
		-- 将选择的2张卡片送往玩家手牌
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的这2张卡片
		Duel.ConfirmCards(1-tp,g1)
	end
end
-- 效果③的除外登记：当这张卡被除外时，注册生命周期到下回合准备阶段结束的全局标记以记录除外时的回合数
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为此卡注册一个跨两个准备阶段的特定标记，并以当前回合数为标记的值以供下回合判定使用
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2,Duel.GetTurnCount())
end
-- 效果③的特召条件检查：在准备阶段检查是否是此卡被除外的下一个回合，如果是则重置标记并返回true
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetFlagEffectLabel(id)
	-- 获取当前的回合数
	local tn=Duel.GetTurnCount()
	if not ct or tn==ct then
		c:ResetFlagEffect(id)
		return false
	else return tn==ct+1 end
end
-- 效果③的特召发动准备：设置特殊召唤自身的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将除外状态下的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的特召效果处理：如果这张卡依然符合条件，则将其在自己场上特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若该卡与当前效果处理相关联，则将其以表侧表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
