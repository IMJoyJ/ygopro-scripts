--エレキマイラ
-- 效果：
-- 名字带有「电气」的调整＋调整以外的雷族怪兽1只以上
-- 这张卡可以直接攻击对方玩家。这张卡直接攻击给与对方基本分战斗伤害时，对方手卡随机1张到卡组最上面放置。
function c2772236.initial_effect(c)
	-- 添加同调召唤手续，要求1只名字带有「电气」的调整和1只以上雷族的调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xe),aux.NonTuner(Card.IsRace,RACE_THUNDER),1)
	c:EnableReviveLimit()
	-- 这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这张卡直接攻击给与对方基本分战斗伤害时，对方手卡随机1张到卡组最上面放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2772236,0))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c2772236.condition)
	e2:SetTarget(c2772236.target)
	e2:SetOperation(c2772236.operation)
	c:RegisterEffect(e2)
end
-- 判断是否为对方造成的战斗伤害且攻击对象为空
function c2772236.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方造成的战斗伤害且攻击对象为空
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 设置效果处理时的目标信息，确定将对方手牌送回卡组
function c2772236.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示要将对方手牌送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
-- 执行效果处理，从对方手牌中随机选择1张送回卡组顶端
function c2772236.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌区域的所有卡片
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将选中的卡片送回对方卡组顶端
	Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
end
