--黒猫の睨み
-- 效果：
-- ①：自己场上有里侧守备表示怪兽2只以上存在的场合，对方战斗阶段才能发动。那次战斗阶段结束。
-- ②：把墓地的这张卡除外，以包含「占术姬」怪兽的场上2只表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。
function c67381587.initial_effect(c)
	-- ①：自己场上有里侧守备表示怪兽2只以上存在的场合，对方战斗阶段才能发动。那次战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c67381587.condition)
	e1:SetOperation(c67381587.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以包含「占术姬」怪兽的场上2只表侧表示怪兽为对象才能发动。那些怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将墓地的这张卡除外作为发动的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c67381587.postg)
	e2:SetOperation(c67381587.posop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定：对方战斗阶段，且自己场上有2只以上的里侧守备表示怪兽存在
function c67381587.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合的战斗阶段（从战斗阶段开始到战斗阶段结束）
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
		-- 判定自己场上是否存在至少2只里侧守备表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,0,2,nil,POS_FACEDOWN_DEFENSE)
end
-- 效果①的效果处理：结束对方的战斗阶段
function c67381587.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过对方的战斗阶段，使其直接进入结束步骤（即结束战斗阶段）
	Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
end
-- 过滤条件1：场上表侧表示、可以变成里侧守备表示的「占术姬」怪兽，且场上还存在其他可以变成里侧守备表示的表侧表示怪兽
function c67381587.posfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xcc) and c:IsCanTurnSet()
		-- 检查场上是否存在除自身以外的、可以变成里侧守备表示的表侧表示怪兽
		and Duel.IsExistingTarget(c67381587.posfilter2,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 过滤条件2：场上表侧表示且可以变成里侧守备表示的怪兽
function c67381587.posfilter2(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果②的靶向处理（Target）：选择包含「占术姬」怪兽在内的场上2只表侧表示怪兽作为对象
function c67381587.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动效果时，检查场上是否存在至少1只满足过滤条件1的「占术姬」怪兽
	if chk==0 then return Duel.IsExistingTarget(c67381587.posfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息：请选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择1只满足过滤条件1的「占术姬」怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c67381587.posfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 给玩家发送提示信息：请选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择除第一只怪兽以外的、另1只满足过滤条件2的表侧表示怪兽作为效果对象
	local g2=Duel.SelectTarget(tp,c67381587.posfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1:GetFirst())
	g1:Merge(g2)
	-- 设置效果处理信息：将选择的2只怪兽改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,2,0,0)
end
-- 效果②的操作处理（Operation）：将作为对象的2只怪兽变成里侧守备表示
function c67381587.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与此效果相关的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将这些怪兽全部变成里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
