--リコリス・リリィパー
-- 效果：
-- 调整+调整以外的怪兽1只以上
-- 这张卡在自己怪兽区域存在的状态，怪兽从场上被送去对方墓地的场合（伤害步骤也能发动）：自己回复对方墓地的那之内1只怪兽的攻击力数值的基本分。
-- 这张卡在自己墓地存在的状态，对方受到效果伤害的场合（伤害步骤除外）：可以把这张卡除外；持有自己和对方的基本分相差数值以下的攻击力的场上1只怪兽送去墓地。
-- 「石蒜百合收割者」的每个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册同调召唤手续、①怪兽送去对方墓地时回复生命值、②对方受效果伤害时除外自身送墓场上怪兽效果
function s.initial_effect(c)
	-- 同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 注册合并延迟事件：监听怪兽被送去墓地的时点
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- ①：这张卡在自己怪兽区域存在的状态，怪兽从场上被送去对方墓地的场合（伤害步骤也能发动）：自己回复对方墓地的那之内1只怪兽的攻击力数值的基本分。
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
	-- ②：这张卡在自己墓地存在的状态，对方受到效果伤害的场合（伤害步骤除外）：可以把这张卡除外；持有自己和对方的基本分相差数值以下的攻击力的场上1只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tgcon)
	-- 发动Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 回复基本分过滤条件：从场上送去对方墓地且攻击力在1以上的怪兽
function s.recfilter(c,tp,e)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(1-tp) and c:IsAttackAbove(1) and c:IsType(TYPE_MONSTER)
end
-- ①效果发动条件：存在满足条件的被送去对方墓地的怪兽
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.recfilter,1,nil,tp)
end
-- ①效果发动准备：设为对象并设置回复基本分的操作信息
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.recfilter,nil,tp,e)
	if chk==0 then return #g>0 end
	-- 将满足条件的被送墓怪兽设为连锁对象
	Duel.SetTargetCard(g)
	-- 设置连锁操作信息：回复玩家基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- ①效果处理：选择对方墓地1只被送墓的怪兽并回复其攻击力数值的基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁设定且仍满足条件的目标怪兽
	local mg=Duel.GetTargetsRelateToChain():Filter(s.recfilter,nil,tp,e)
	if #mg>0 and c:IsRelateToChain() then
		-- 提示玩家选择要参照攻击力的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
		local og=mg:Select(tp,1,1,nil)
		local rc=og:GetFirst()
		-- 高亮显示选择的目标怪兽
		Duel.HintSelection(og)
		-- 回复选择怪兽攻击力数值的基本分
		Duel.Recover(tp,rc:GetAttack(),REASON_EFFECT)
	end
end
-- ②效果发动条件：对方因卡的效果受到伤害
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and ep~=tp
end
-- 送去墓地过滤条件：场上表侧表示且攻击力在双方基本分差值以下的怪兽
function s.tgfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsAbleToGrave()
end
-- ②效果发动准备：检查场上是否存在满足条件的怪兽并设置送去墓地操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：场上是否存在攻击力小于等于双方基本分差值的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))) end
	-- 设置连锁操作信息：将场上1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- ②效果处理：选择场上1只满足条件的怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1只攻击力小于等于双方基本分差值的怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp)))
	local tc=g:GetFirst()
	if tc then
		-- 高亮显示选中的怪兽
		Duel.HintSelection(g)
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
