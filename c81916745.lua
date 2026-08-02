--リコリス・リリィパー
-- 效果：
-- 调整+调整以外的怪兽1只以上
-- 这张卡在自己怪兽区域存在的状态，怪兽从场上被送去对方墓地的场合（伤害步骤也能发动）：自己回复对方墓地的那之内1只怪兽的攻击力数值的基本分。
-- 这张卡在自己墓地存在的状态，对方受到效果伤害的场合（伤害步骤除外）：可以把这张卡除外；持有自己和对方的基本分相差数值以下的攻击力的场上1只怪兽送去墓地。
-- 「石蒜百合收割者」的每个效果1回合只能使用1次。
local s,id,o=GetID()
-- 声明initial_effect函数，添加同调召唤手续，注册送去墓地时的自定义事件并注册回复基本分和送去墓地等效果
function s.initial_effect(c)
	-- 添加同调召唤手续，条件为调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 为卡片注册被送去墓地时的合并延迟事件
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
	-- 可以把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：怪兽从场上被送去对方墓地，且攻击力大于0
function s.recfilter(c,tp,e)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(1-tp) and c:IsAttackAbove(1) and c:IsType(TYPE_MONSTER)
end
-- 判断是否有怪兽从场上被送去对方墓地
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.recfilter,1,nil,tp)
end
-- 过滤满足条件的怪兽，将其设为效果对象并设置回复基本分的操作信息
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.recfilter,nil,tp,e)
	if chk==0 then return #g>0 end
	-- 将满足条件的怪兽设为正在处理的连锁的对象
	Duel.SetTargetCard(g)
	-- 设置回复基本分的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- 选择目标怪兽并自己回复其攻击力数值的基本分
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中仍然存在且满足条件的对象怪兽组
	local mg=Duel.GetTargetsRelateToChain():Filter(s.recfilter,nil,tp,e)
	if #mg>0 and c:IsRelateToChain() then
		-- 向玩家发出“请选择”的操作提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)  --"请选择"
		local og=mg:Select(tp,1,1,nil)
		local rc=og:GetFirst()
		-- 手动为选中的怪兽显示被选为对象的动画
		Duel.HintSelection(og)
		-- 自己回复对方墓地的那之内1只怪兽的攻击力数值的基本分
		Duel.Recover(tp,rc:GetAttack(),REASON_EFFECT)
	end
end
-- 对方受到效果伤害的场合
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and ep~=tp
end
-- 持有自己和对方的基本分相差数值以下的攻击力
function s.tgfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsAbleToGrave()
end
-- 检查双方基本分相差数值，判断是否存在满足条件的怪兽，并设置送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在攻击力在基本分相差数值以下的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))) end
	-- 设置送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 让玩家选择场上1只满足条件的怪兽并送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出“请选择要送去墓地的卡”的操作提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1只攻击力在基本分相差数值以下的怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp)))
	local tc=g:GetFirst()
	if tc then
		-- 手动为选中的怪兽显示被选为对象的动画
		Duel.HintSelection(g)
		-- 持有自己和对方的基本分相差数值以下的攻击力的场上1只怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
