--SRビーダマシーン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，自己的守备表示怪兽被选择作为攻击对象时才能发动。那只怪兽变成表侧攻击表示。这个回合，那只怪兽不会被战斗破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把1只「疾行机人」怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
function c96708940.initial_effect(c)
	-- 启用灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动效果）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己的守备表示怪兽被选择作为攻击对象时才能发动。那只怪兽变成表侧攻击表示。这个回合，那只怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c96708940.condition)
	e1:SetTarget(c96708940.target)
	e1:SetOperation(c96708940.opetation)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时才能发动。从卡组把1只「疾行机人」怪兽加入手卡。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96708940,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,96708940)
	e2:SetTarget(c96708940.thtg)
	e2:SetOperation(c96708940.thop)
	c:RegisterEffect(e2)
end
-- 检查是否满足发动条件：自己的守备表示怪兽被选择作为攻击对象
function c96708940.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击的怪兽
	local at=Duel.GetAttackTarget()
	return at and at:IsControler(tp) and at:IsPosition(POS_DEFENSE)
end
-- 效果发动时的靶向处理，使被攻击怪兽与此效果建立关系
function c96708940.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 使被攻击的怪兽与当前发动的效果建立关系
	Duel.GetAttackTarget():CreateEffectRelation(e)
end
-- 效果处理：将被攻击怪兽变为表侧攻击表示，并使其在本回合不会被战斗破坏
function c96708940.opetation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取当前被攻击的怪兽
	local at=Duel.GetAttackTarget()
	if at:IsRelateToEffect(e) then
		-- 将被攻击的怪兽改变为表侧攻击表示
		Duel.ChangePosition(at,POS_FACEUP_ATTACK)
		-- 这个回合，那只怪兽不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		at:RegisterEffect(e1)
	end
end
-- 过滤卡组中可以加入手牌的「疾行机人」怪兽
function c96708940.thfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备，检查卡组中是否存在可检索怪兽并设置操作信息
function c96708940.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的「疾行机人」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96708940.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果处理：从卡组将1只「疾行机人」怪兽加入手牌，并适用特殊召唤限制
function c96708940.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的「疾行机人」怪兽
	local g=Duel.SelectMatchingCard(tp,c96708940.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c96708940.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在玩家身上注册该特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤风属性怪兽
function c96708940.splimit(e,c,tp,sumtp,sumpos)
	return c:GetAttribute()~=ATTRIBUTE_WIND
end
