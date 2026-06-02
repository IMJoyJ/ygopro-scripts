--無窮の三幻魔－幻魔皇ラビエル
-- 效果：
-- 这张卡不能通常召唤，用「三幻魔」卡的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从卡组把「无穷之三幻魔-幻魔皇 拉比艾尔」以外的1只「三幻魔」怪兽加入手卡。那之后，选自己1张手卡丢弃。
-- ②：自己·对方回合1次，把自己场上2只其他的「三幻魔」怪兽解放才能发动。对方场上的怪兽全部破坏，这张卡的攻击力上升破坏数量×1000。
local s,id,o=GetID()
-- 注册这张卡的特殊召唤限制条件、手牌展示检索并丢弃效果以及在场上发动的全场破坏并增加攻击力效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「三幻魔」卡的效果才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- ①：把手卡的这张卡给对方观看才能发动。从卡组把「无穷之三幻魔-幻魔皇 拉比艾尔」以外的1只「三幻魔」怪兽加入手卡。那之后，选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合1次，把自己场上2只其他的「三幻魔」怪兽解放才能发动。对方场上的怪兽全部破坏，这张卡的攻击力上升破坏数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e2:SetCountLimit(1)
	-- 限制效果只能在非伤害阶段或尚未进行伤害计算的伤害阶段发动。
	e2:SetCondition(aux.dscon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 限制只能用「三幻魔」卡的效果特殊召唤的特殊召唤限制条件判定函数。
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x1144)
end
-- 效果①发动的代价处理：确认这张卡在手牌中且未给对方观看。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤卡组中除自身外「三幻魔」怪兽的过滤函数。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1144) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①发动的检测处理：确认卡组中存在可检索怪兽，并设置连锁信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：确认卡组中是否存在除自身外且满足条件的「三幻魔」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息：从卡组把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置当前连锁的操作信息：自己选择1张手牌丢弃。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果①的处理：从卡组将1只除自身外的「三幻魔」怪兽加入手牌，给对方确认，并从手牌中选择1张丢弃。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的「三幻魔」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「三幻魔」怪兽加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将选中的怪兽给对方确认。
		Duel.ConfirmCards(1-tp,g)
		-- 从手牌中选择1张可丢弃的卡片。
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_DISCARD+REASON_EFFECT)
		if dg:GetCount()>0 then
			-- 洗切玩家的手牌。
			Duel.ShuffleHand(tp)
			-- 将选中的那张手牌丢弃送去墓地。
			Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
-- 过滤场上用于作为发动代价解放的「三幻魔」怪兽的过滤函数。
function s.costfilter(c,tp)
	-- 代价过滤条件：卡片属于「三幻魔」系列且场上存在可用于解放的卡。
	return c:IsSetCard(0x1144) and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,c)
end
-- 效果②发动的代价处理：把自己场上2只其他的「三幻魔」怪兽解放。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己场上是否存在2只除自身外的可解放的「三幻魔」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,2,e:GetHandler(),tp) end
	-- 选择自己场上2只除自身外的可解放的「三幻魔」怪兽。
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,2,2,e:GetHandler(),tp)
	-- 将选中的怪兽作为发动代价解放。
	Duel.Release(g,REASON_COST)
end
-- 效果②发动的靶向处理：确认对方场上是否存在怪兽，并设置连锁信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：确认对方场上是否存在至少1只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的怪兽卡片组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息：破坏对方场上的全部怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的处理：破坏对方场上全部怪兽，并按破坏数量增加这张卡的攻击力。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有的怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 破坏对方场上所有选中的怪兽，并获取实际被破坏的数量。
	local atk=Duel.Destroy(g,REASON_EFFECT)
	if c:IsRelateToChain() and c:IsFaceup() then
		-- 这张卡的攻击力上升破坏数量×1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
