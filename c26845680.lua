--オルフェゴール・プライム
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上（表侧表示）把1只「自奏圣乐」怪兽或「星遗物」怪兽送去墓地才能发动。自己抽2张。
function c26845680.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上（表侧表示）把1只「自奏圣乐」怪兽或「星遗物」怪兽送去墓地才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26845680+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c26845680.cost)
	e1:SetTarget(c26845680.target)
	e1:SetOperation(c26845680.activate)
	c:RegisterEffect(e1)
end
-- 定义可作为代价的卡：拥有「自奏圣乐」或「星遗物」字段的怪兽，且（手牌任意，场上的必须表侧表示），并且可以作为代价被送去墓地。
function c26845680.costfilter(c)
	return c:IsSetCard(0xfe,0x11b) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsAbleToGraveAsCost()
end
-- 代价处理：确认存在满足条件的卡后，从手牌或场上表侧表示选择1张符合条件的卡送去墓地作为发动代价。
function c26845680.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动的代价检查：检查我方手牌或场上是否存在至少1张满足costfilter筛选条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c26845680.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从我方手牌和场上选择1张满足costfilter条件的卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c26845680.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选中的卡送入墓地，送入原因为发动代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时的目标设定：确认自己可以抽2张，将当前连锁的对象玩家设为自己，抽卡数设为2，并登记抽卡的操作信息。
function c26845680.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：当前玩家是否可以抽2张卡（若被“不能抽卡”效果限制则无法发动）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁处理的对象玩家设置为自己（tp），表示效果影响的是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁处理的对象参数设置为2，表示要抽取的卡数为2。
	Duel.SetTargetParam(2)
	-- 登记操作信息：本连锁包含抽卡效果（CATEGORY_DRAW），对象玩家为自己，预计抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：从连锁信息中取出记录的对象玩家与抽卡数，并执行对应抽卡。
function c26845680.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 读取当前连锁中保存的对象玩家和对象参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家p抽取d张卡，抽卡原因记为效果（REASON_EFFECT）。
	Duel.Draw(p,d,REASON_EFFECT)
end
