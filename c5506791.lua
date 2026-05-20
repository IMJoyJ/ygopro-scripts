--マジェスペクター・キャット
-- 效果：
-- ←2 【灵摆】 2→
-- 【怪兽效果】
-- 「威风妖怪·猫」的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功时才能发动。这个回合的结束阶段，从卡组把1张「威风妖怪」卡加入手卡。
-- ②：这张卡只要在怪兽区域存在，不会成为对方的效果的对象，不会被对方的效果破坏。
function c5506791.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、作为灵摆卡发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡召唤·特殊召唤成功时才能发动。这个回合的结束阶段，从卡组把1张「威风妖怪」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,5506791)
	e2:SetOperation(c5506791.regop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡只要在怪兽区域存在，不会成为对方的效果的对象
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不会成为对方卡片效果的对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- 不会被对方的效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	-- 设置不会被对方的卡片效果破坏
	e5:SetValue(aux.indoval)
	c:RegisterEffect(e5)
end
-- 过滤卡组中可加入手牌的「威风妖怪」卡
function c5506791.thfilter(c)
	return c:IsSetCard(0xd0) and c:IsAbleToHand()
end
-- 召唤·特殊召唤成功时效果的发动处理：注册一个在结束阶段触发的延迟效果
function c5506791.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段，从卡组把1张「威风妖怪」卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c5506791.thcon)
	e1:SetOperation(c5506791.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将结束阶段检索的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 结束阶段检索效果的发动条件：卡组中存在可检索的「威风妖怪」卡
function c5506791.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否存在至少1张可加入手牌的「威风妖怪」卡
	return Duel.IsExistingMatchingCard(c5506791.thfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 结束阶段检索效果的具体执行：从卡组选择1张「威风妖怪」卡加入手牌
function c5506791.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了「威风妖怪·猫」的效果
	Duel.Hint(HINT_CARD,0,5506791)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「威风妖怪」卡
	local g=Duel.SelectMatchingCard(tp,c5506791.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
