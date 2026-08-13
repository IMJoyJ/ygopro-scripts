--ブラック・ブースト
-- 效果：
-- 把自己场上表侧表示存在的2只名字带有「黑羽」的调整从游戏中除外发动。从自己卡组抽2张卡。
function c53519297.initial_effect(c)
	-- 把自己场上表侧表示存在的2只名字带有「黑羽」的调整从游戏中除外发动。从自己卡组抽2张卡。
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
-- 定义筛选条件：卡片须为表侧表示、持有「黑羽」字段、是调整怪兽，且可以作为代价被除外。
function c53519297.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x33) and c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 代价处理函数：检查能否从自己场上表侧怪兽区选出2张满足条件的调整；若可以则选择那些卡并作为代价除外。
function c53519297.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段（chk==0）：确认自己场上表侧怪兽区是否存在至少2只满足筛选条件的调整怪兽，以此作为能否发动的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c53519297.filter,tp,LOCATION_MZONE,0,2,nil) end
	-- 向操作者显示选择提示消息，提示文字为『请选择要除外的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上表侧怪兽区中选出2只满足筛选条件的调整怪兽作为代价对象。
	local g=Duel.SelectMatchingCard(tp,c53519297.filter,tp,LOCATION_MZONE,0,2,2,nil)
	-- 将选中的2只调整怪兽以表侧表示除外，除外原因标记为代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动对象/目标设定函数：处理发动时是否允许抽卡，并记录抽卡对象玩家和抽卡数量，为后续处理提供信息。
function c53519297.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 真伪判定（chk==0）：检查玩家tp是否可以效果抽出2张卡，决定效果能否发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的目标玩家设置为发动者tp，表示该效果影响的是这位玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为2，表示后续要处理的抽卡张数为2。
	Duel.SetTargetParam(2)
	-- 登记操作信息：本连锁包含抽卡效果（CATEGORY_DRAW），目标玩家为tp，预计处理数量为2张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：根据连锁中记录的目标玩家和抽卡数量，执行实际的抽卡动作。
function c53519297.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家（p）和目标参数（d），即抽卡对象与抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽取d张卡，完成从卡组抽出2张卡的效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
