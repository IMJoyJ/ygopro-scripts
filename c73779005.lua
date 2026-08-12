--ドラコニアの獣竜騎兵
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，自己的通常怪兽战斗破坏对方怪兽的伤害计算后才能发动。从卡组把1只4星以上的通常怪兽加入手卡。
-- 【怪兽描述】
-- 龙人族国家德拉科尼亚帝国所拥有的龙骑士团陆兵部队。使用鸟铳与铁枪组合攻击而无懈可击，令雷普提尔皇国等周边国家有所畏惧。
function c73779005.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动效果）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己的通常怪兽战斗破坏对方怪兽的伤害计算后才能发动。从卡组把1只4星以上的通常怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c73779005.thcon)
	e2:SetTarget(c73779005.thtg)
	e2:SetOperation(c73779005.thop)
	c:RegisterEffect(e2)
end
-- 检查是否满足发动条件：自己的通常怪兽战斗破坏了对方怪兽
function c73779005.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	return a:IsType(TYPE_NORMAL) and d:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 过滤卡组中4星以上的通常怪兽且能加入手卡
function c73779005.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelAbove(4) and c:IsAbleToHand()
end
-- 效果发动的目标检查与操作信息设置（检查卡组中是否存在符合条件的卡，并设置检索操作信息）
function c73779005.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c73779005.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果运行时的具体处理：从卡组选择1只4星以上的通常怪兽加入手卡并给对方确认
function c73779005.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c73779005.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
