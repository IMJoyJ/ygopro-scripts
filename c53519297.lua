--ブラック・ブースト
-- 效果：
-- 把自己场上表侧表示存在的2只名字带有「黑羽」的调整从游戏中除外发动。从自己卡组抽2张卡。
function c53519297.initial_effect(c)
	-- 效果原文内容：把自己场上表侧表示存在的2只名字带有「黑羽」的调整从游戏中除外发动。从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c53519297.cost)
	e1:SetTarget(c53519297.target)
	e1:SetOperation(c53519297.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上正面表示、黑羽卡组、调整类型且能作为除外代价的卡片
function c53519297.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 效果处理的除外代价阶段，检查是否满足条件并选择2张符合条件的卡进行除外
function c53519297.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少2张满足filter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c53519297.filter,tp,LOCATION_MZONE,0,2,nil) end
	-- 向玩家提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张卡作为除外对象
	local g=Duel.SelectMatchingCard(tp,c53519297.filter,tp,LOCATION_MZONE,0,2,2,nil)
	-- 将选中的卡以正面表示形式从游戏中除外，作为效果发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果的目标为当前玩家并设定抽卡数量为2
function c53519297.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为2（表示抽2张卡）
	Duel.SetTargetParam(2)
	-- 设置效果操作信息，表明本次效果将执行抽卡行为
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果发动时的处理函数，获取目标玩家和抽卡数量并执行抽卡
function c53519297.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
