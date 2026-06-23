--マジェスペクター・ラクーン
-- 效果：
-- ←5 【灵摆】 5→
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤时才能发动。从卡组把1只「威风妖怪」怪兽加入手卡。
-- ②：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
function c31991800.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：这张卡召唤·特殊召唤时才能发动。从卡组把1只「威风妖怪」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,31991800)
	e2:SetTarget(c31991800.thtg)
	e2:SetOperation(c31991800.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果值为过滤函数aux.tgoval，用于判断是否不会成为对方的卡的效果对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ②：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e5:SetRange(LOCATION_MZONE)
	-- 设置效果值为过滤函数aux.indoval，用于判断是否不会被对方的卡的效果破坏
	e5:SetValue(aux.indoval)
	c:RegisterEffect(e5)
end
-- 定义过滤函数，用于检索满足条件的「威风妖怪」怪兽（怪兽卡且可加入手牌）
function c31991800.thfilter(c)
	return c:IsSetCard(0xd0) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果的发动条件和处理目标，检查卡组是否存在满足条件的怪兽并设置操作信息
function c31991800.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查以玩家tp来看的卡组中是否存在至少1张满足过滤条件的「威风妖怪」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c31991800.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果的处理函数，用于选择并把符合条件的卡加入手牌
function c31991800.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c31991800.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
