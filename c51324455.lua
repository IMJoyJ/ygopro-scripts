--魔製産卵床
-- 效果：
-- 自己场上表侧表示存在的鱼族·海龙族·水族怪兽从游戏中除外时才能发动。从自己卡组把1只4星以下的鱼族·海龙族·水族怪兽加入手卡。
function c51324455.initial_effect(c)
	-- 效果原文内容：自己场上表侧表示存在的鱼族·海龙族·水族怪兽从游戏中除外时才能发动。从自己卡组把1只4星以下的鱼族·海龙族·水族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c51324455.condition)
	e1:SetTarget(c51324455.target)
	e1:SetOperation(c51324455.activate)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查被除外的怪兽是否满足条件（表侧表示、在主要怪兽区、是自己控制、种族为鱼/海龙/水）
function c51324455.cfilter(c,tp)
	return c:IsFaceup() and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA)
end
-- 规则层面操作：判断是否有满足cfilter条件的怪兽被除外
function c51324455.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c51324455.cfilter,1,nil,tp)
end
-- 规则层面操作：过滤出卡组中等级4以下且种族为鱼/海龙/水的怪兽
function c51324455.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and c:IsAbleToHand()
end
-- 规则层面操作：设置连锁处理信息，准备从卡组检索1只符合条件的怪兽加入手牌
function c51324455.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断是否满足检索条件（卡组中是否存在符合条件的怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(c51324455.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 规则层面操作：设置操作信息为CATEGORY_TOHAND，表示将要执行回手牌效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：发动效果，提示选择并检索符合条件的怪兽加入手牌
function c51324455.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：向玩家发送提示消息“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c51324455.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的怪兽以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 规则层面操作：向对方确认被送入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
