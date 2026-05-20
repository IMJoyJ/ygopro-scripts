--カブレラストーン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把1张「三角阵-O」加入手卡。这张卡是攻击表示的场合，再让这张卡变成守备表示。
-- ②：这张卡被战斗·效果破坏的场合发动。自己受到1000伤害。
local s,id,o=GetID()
-- 在初始化函数中注册该卡的效果：①召唤/反转召唤/特殊召唤成功时检索「三角阵-O」并变更表示形式，②被破坏时给自己造成伤害。
function s.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把1张「三角阵-O」加入手卡。这张卡是攻击表示的场合，再让这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡被战斗·效果破坏的场合发动。自己受到1000伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查卡片是否为「三角阵-O」且能加入手卡。
function s.filter(c)
	return c:IsCode(11489642) and c:IsAbleToHand()
end
-- ①号效果的发动准备：检查卡组是否存在满足条件的卡，并设置将卡加入手卡的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 检查卡组中是否存在至少1张可以加入手卡的「三角阵-O」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,exc) end
	-- 设置当前连锁的操作信息为：将卡组中的1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的处理：从卡组将1张「三角阵-O」加入手卡，若此卡为表侧攻击表示，则再变成守备表示。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「三角阵-O」。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsPosition(POS_FACEUP_ATTACK) then
		-- 中断当前效果处理，使后续的表示形式变更不与加入手卡同时处理（造成错时点）。
		Duel.BreakEffect()
		-- 将这张卡变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- ②号效果的发动条件：这张卡被战斗或效果破坏。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) or c:IsReason(REASON_BATTLE)
end
-- ②号效果的发动准备：设置受到伤害的玩家为自己，伤害数值为1000，并设置伤害操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数（伤害数值）为1000。
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为：给与玩家1000点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1000)
end
-- ②号效果的处理：获取目标玩家和伤害数值，给与该玩家对应的伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
