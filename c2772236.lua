--エレキマイラ
-- 效果：
-- 名字带有「电气」的调整＋调整以外的雷族怪兽1只以上
-- 这张卡可以直接攻击对方玩家。这张卡直接攻击给与对方基本分战斗伤害时，对方手卡随机1张到卡组最上面放置。
function c2772236.initial_effect(c)
	-- 为「电气奇美拉」添加同调召唤手续：调整必须为名字带有「电气」的怪兽，调整以外必须为雷族怪兽，数量为1只以上。
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
-- 定义诱发效果的触发条件：仅在受到战斗伤害的玩家不是此卡控制者（即伤害来源为直接攻击对方）且没有攻击对象时，效果才满足发动条件。
function c2772236.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为直接攻击给对方造成战斗伤害：受伤玩家不是效果控制者，且这次战斗没有攻击对象（即直接攻击）。
	return ep~=tp and Duel.GetAttackTarget()==nil
end
-- 定义效果发动前的合法性与操作信息设定：该效果为必发诱发效果，chk==0时直接返回true表示满足发动条件，随后登记将对方手卡1张返回卡组的操作信息。
function c2772236.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果会涉及对方手牌1张卡返回卡组，分类为CATEGORY_TODECK，数量为1，目标玩家为对方（1-tp），位置为手牌。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
-- 定义效果处理时的实际动作：取得受到战斗伤害的对方玩家（ep）的手牌，若手牌为0则不做处理，否则随机选择其中1张，将其放置到持有者卡组最顶端。
function c2772236.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取受到战斗伤害的对方玩家（ep）的手牌组，作为随机选牌的对象。
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选出的1张手牌以效果原因（REASON_EFFECT）送至其持有者的卡组最顶端（SEQ_DECKTOP）。
	Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
end
