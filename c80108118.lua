--X－セイバー ウルベルム
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 对方手卡有4张以上的场合，这张卡给与对方基本分战斗伤害时，对方手卡随机1张回到卡组最上面。
function c80108118.initial_effect(c)
	-- 为卡片添加同调召唤手续：需要调整和1只以上的非调整怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对方手卡有4张以上的场合，这张卡给与对方基本分战斗伤害时，对方手卡随机1张回到卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80108118,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c80108118.condition)
	e1:SetTarget(c80108118.target)
	e1:SetOperation(c80108118.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：检查是否给与对方战斗伤害，且对方手卡在4张以上
function c80108118.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断受到伤害的玩家是对方，且对方手卡数量大于等于4张
	return ep~=tp and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=4
end
-- 定义效果发动目标函数：因为是必发效果，直接确认发动，并注册将对方手牌送回卡组的操作信息
function c80108118.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：预计将对方手牌中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end
-- 定义效果处理函数：获取对方手牌，随机选择1张送回卡组最上面
function c80108118.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取受到伤害的玩家（对方）的所有手牌
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选择的卡片以效果原因送回卡组最上面
	Duel.SendtoDeck(sg,nil,SEQ_DECKTOP,REASON_EFFECT)
end
