--Lycoris Lilyreaper
-- 效果：
-- 调整+调整以外的怪兽1只以上
-- 这张卡在自己怪兽区域存在的状态，怪兽从场上被送去对方墓地的场合（伤害步骤也能发动）：自己回复对方墓地的那之内1只怪兽的攻击力数值的基本分。
-- 这张卡在自己墓地存在的状态，对方受到效果伤害的场合（伤害步骤除外）：可以把这张卡除外；持有自己和对方的基本分相差数值以下的攻击力的场上1只怪兽送去墓地。
-- 「石蒜百合收割者」的每个效果1回合只能使用1次。
local s,id,o=GetID()
-- 注册卡片的效果，包括同调召唤手续、①效果（场上送墓回复LP）和②效果（墓地受效伤除外送墓场上怪兽）。
function s.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 注册一个合并的延迟送墓事件监听器，用于检测怪兽被送去墓地的时点。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- 这张卡在自己怪兽区域存在的状态，怪兽从场上被送去对方墓地的场合（伤害步骤也能发动）：自己回复对方墓地的那之内1只怪兽的攻击力数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回复基本分"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(custom_code)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.reccon)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	-- 这张卡在自己墓地存在的状态，对方受到效果伤害的场合（伤害步骤除外）：可以把这张卡除外；持有自己和对方的基本分相差数值以下的攻击力的场上1只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tgcon)
	-- 设置发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：原本在场上、送入对方墓地、攻击力在1以上且是怪兽卡。
function s.recfilter(c,tp,e)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(1-tp) and c:IsAttackAbove(1) and c:IsType(TYPE_MONSTER)
end
-- ①效果的发动条件：送去墓地的卡片组中存在满足过滤条件的怪兽。
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.recfilter,1,nil,tp)
end
-- ①效果的发动目标：筛选出满足条件的送墓怪兽并设为效果处理对象，并设置回复LP的操作信息。
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.recfilter,nil,tp,e)
	if chk==0 then return #g>0 end
	-- 将满足条件的送墓怪兽群组设为当前连锁的处理对象。
	Duel.SetTargetCard(g)
	-- 设置效果处理的操作信息为回复LP。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- ①效果的运行空间：让玩家从成为对象的怪兽中选择1只，并回复其攻击力数值的LP。
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 筛选出在当前连锁中仍满足过滤条件的对象怪兽。
	local mg=Duel.GetTargetsRelateToChain():Filter(s.recfilter,nil,tp,e)
	if #mg>0 and c:IsRelateToChain() then
		-- 提示玩家选择要回复攻击力数值LP的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
		local og=mg:Select(tp,1,1,nil)
		local rc=og:GetFirst()
		-- 选中所选怪兽并向双方玩家展示。
		Duel.HintSelection(og)
		-- 回复自身等同于所选怪兽攻击力数值的LP。
		Duel.Recover(tp,rc:GetAttack(),REASON_EFFECT)
	end
end
-- ②效果的发动条件：对方因效果受到伤害。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and ep~=tp
end
-- 过滤条件：场上表侧表示存在、攻击力在指定数值以下且能送去墓地的怪兽。
function s.tgfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsAbleToGrave()
end
-- ②效果的发动目标：检查场上是否存在攻击力在双方LP差值以下的怪兽，并设置送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只攻击力在双方LP差值以下的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))) end
	-- 设置效果处理的操作信息为将场上的怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- ②效果的运行空间：让玩家选择场上1只攻击力在双方LP差值以下的怪兽送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择场上1只攻击力在双方LP差值以下的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp)))
	local tc=g:GetFirst()
	if tc then
		-- 选中所选怪兽并向双方玩家展示。
		Duel.HintSelection(g)
		-- 将所选怪兽因效果送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
