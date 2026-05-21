--マジェスペクター・フォックス
-- 效果：
-- ←2 【灵摆】 2→
-- 【怪兽效果】
-- 「威风妖怪·狐」的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1张「威风妖怪」陷阱卡加入手卡。
-- ②：这张卡只要在怪兽区域存在，不会成为对方的效果的对象，不会被对方的效果破坏。
function c94784213.initial_effect(c)
	-- 为怪兽卡注册灵摆怪兽属性（包括灵摆召唤和作为灵摆卡发动）。
	aux.EnablePendulumAttribute(c)
	-- 「威风妖怪·狐」的①的怪兽效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功时才能发动。从卡组把1张「威风妖怪」陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,94784213)
	e2:SetTarget(c94784213.thtg)
	e2:SetOperation(c94784213.thop)
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
	-- 设置不能成为效果对象的效果过滤函数，使其仅对对方的效果生效。
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- 不会被对方的效果破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	-- 设置不会被效果破坏的效果过滤函数，使其仅对对方的效果生效。
	e5:SetValue(aux.indoval)
	c:RegisterEffect(e5)
end
-- 过滤卡组中属于「威风妖怪」系列且是陷阱卡、并且能加入手牌的卡片。
function c94784213.thfilter(c)
	return c:IsSetCard(0xd0) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 检索效果的发动条件检测与操作信息注册函数。
function c94784213.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张满足条件的「威风妖怪」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c94784213.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 注册连锁处理时的操作信息，表示该效果会将卡组中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的实际处理函数。
function c94784213.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「威风妖怪」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c94784213.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片通过效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
