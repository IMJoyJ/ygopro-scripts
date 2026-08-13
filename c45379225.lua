--サイコ・ヘルストランサー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 把自己墓地存在的1只念动力族怪兽从游戏中除外发动。自己回复1200基本分。这个效果1回合只能使用1次。
function c45379225.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（无其他条件）＋1只以上调整以外的怪兽（无其他条件）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 把自己墓地存在的1只念动力族怪兽从游戏中除外发动。自己回复1200基本分。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45379225,0))  --"回复1200基本分"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c45379225.cost)
	e1:SetTarget(c45379225.target)
	e1:SetOperation(c45379225.operation)
	c:RegisterEffect(e1)
end
-- 定义除外代价的过滤条件：从自己墓地选择1只念动力族怪兽，且该怪兽可以作为代价被除外。
function c45379225.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：发动前检查墓地是否存在满足条件的念动力族怪兽；支付时从墓地选择1只念动力族怪兽，以表侧表示除外作为发动代价。
function c45379225.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己墓地存在至少1只满足条件的念动力族怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c45379225.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的念动力族怪兽（此时选择的卡将成为发动的代价）。
	local g=Duel.SelectMatchingCard(tp,c45379225.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的念动力族怪兽以表侧表示除外，作为效果发动的代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动的目标设定：无对象，但记录回复目标和回复数值；发动时确立本效果将回复自己1200基本分。
function c45379225.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的对象玩家设定为效果发动者本人（tp），即回复基本分的对象是自己。
	Duel.SetTargetPlayer(tp)
	-- 将连锁的对象参数设定为1200，记录需要回复的基本分数值。
	Duel.SetTargetParam(1200)
	-- 向系统登记本连锁的操作信息，声明这是一个回复效果（CATEGORY_RECOVER），回复对象为自己，回复量为1200。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1200)
end
-- 效果处理：取得连锁中记录的对象玩家和回复数值，为对应的玩家回复相应基本分（由效果原因引起）。
function c45379225.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取出对象玩家（p）和对象参数（d），即之前保存的回复目标和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家 p 回复 d 点基本分，回复原因标记为效果（REASON_EFFECT）。
	Duel.Recover(p,d,REASON_EFFECT)
end
