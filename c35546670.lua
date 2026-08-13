--星遺物が刻む傷痕
-- 效果：
-- ①：场上的「机界骑士」怪兽的攻击力·守备力上升300。
-- ②：1回合1次，从手卡丢弃1只「机界骑士」怪兽或者1张「星遗物」卡才能发动。自己从卡组抽1张。
-- ③：从自己墓地以及自己场上的表侧表示怪兽之中把「机界骑士」怪兽8种类各1只除外才能发动。对方的手卡·额外卡组的卡全部送去墓地。
function c35546670.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「机界骑士」怪兽的攻击力上升300（对应①效果中的攻击力部分）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	-- 设置该永续效果影响的对象为场上所有「机界骑士」怪兽（字段0x10c），配合SetTargetRange决定作用于双方怪兽区。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x10c))
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，从手卡丢弃1只「机界骑士」怪兽或者1张「星遗物」卡才能发动。自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(35546670,0))  --"抽卡"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c35546670.drcost)
	e4:SetTarget(c35546670.drtg)
	e4:SetOperation(c35546670.drop)
	c:RegisterEffect(e4)
	-- ③：从自己墓地以及自己场上的表侧表示怪兽之中把「机界骑士」怪兽8种类各1只除外才能发动。对方的手卡·额外卡组的卡全部送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(35546670,1))  --"全部送去墓地"
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCost(c35546670.tgcost)
	e5:SetTarget(c35546670.tgtg)
	e5:SetOperation(c35546670.tgop)
	c:RegisterEffect(e5)
end
-- 用于②的代价筛选：手卡中的「机界骑士」怪兽（须为怪兽卡）或「星遗物」卡，且可以被丢弃。
function c35546670.costfilter1(c)
	return ((c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0xfe)) and c:IsDiscardable()
end
-- ②的代价处理：从手卡丢弃1只「机界骑士」怪兽或1张「星遗物」卡作为发动代价（丢弃+代价原因）。
function c35546670.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）确认手卡中是否存在至少1张满足costfilter1的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c35546670.costfilter1,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示己方发动了②效果（以“对方选择了”的方式显示效果描述）。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 让己方从手卡选择并丢弃1张符合条件的卡，作为发动代价（丢弃+代价）。
	Duel.DiscardHand(tp,c35546670.costfilter1,1,1,REASON_DISCARD+REASON_COST)
end
-- ②的发动目标设定：确认己方可以抽1张卡，并登记对象玩家为己方、抽卡数为1、操作信息为抽卡。
function c35546670.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查阶段确认己方是否拥有抽1张卡的能力（未受“不能抽卡”效果限制），否则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次效果的对象玩家设为己方tp，表示由己方抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果的对象参数设为1，表示抽卡数量为1。
	Duel.SetTargetParam(1)
	-- 登记抽卡类操作信息：无固定对象卡，预计抽卡玩家为tp，抽取1张，供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②的效果处理：根据记录的抽卡玩家和数量执行抽卡。
function c35546670.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设置的对象玩家和对象参数（即抽卡玩家与抽卡数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p抽d张卡，抽卡原因为效果（REASON_EFFECT），完成“自己从卡组抽1张”。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 用于③的代价筛选：自己墓地或自己场上表侧表示怪兽中的「机界骑士」怪兽，且可以作为代价除外。
function c35546670.costfilter2(c)
	return c:IsSetCard(0x10c) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
end
-- ③的代价处理：从符合条件的「机界骑士」怪兽中选择8种类各1只（卡名互不相同）除外；不足8种类则不能发动。
function c35546670.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 收集己方墓地及己方场上表侧表示怪兽中所有可作为③代价的「机界骑士」怪兽，组成候选集合。
	local g=Duel.GetMatchingGroup(c35546670.costfilter2,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=8 end
	-- 向对方玩家提示己方发动了③效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 弹出选择卡片提示，提示玩家正在选择要除外的卡片（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 设置全局额外检查函数为“卡名互不相同”，确保接下来选择的8张卡是8个不同种类（卡名不同）。
	aux.GCheckAdditional=aux.dncheck
	-- 从候选集合中选择8张卡（全部通过aux.TRUE），由于已设置dncheck，选出的8张卡卡名互不相同，满足“8种类各1只”。
	local rg=g:SelectSubGroup(tp,aux.TRUE,false,8,8)
	-- 清空全局额外检查函数，避免影响后续选择逻辑。
	aux.GCheckAdditional=nil
	-- 将选出的8张「机界骑士」怪兽以表侧表示除外，作为发动③的代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- ③的目标设定：确认对方手卡·额外卡组中存在可送去墓地的卡，并登记将这些卡全部送去墓地的操作信息。
function c35546670.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查阶段确认对方手卡·额外卡组中是否至少有1张卡可以送去墓地，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,1,nil) end
	-- 获取对方手卡及额外卡组中所有可以被送去墓地的卡，作为效果处理时的对象集合。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,nil)
	-- 登记送去墓地的操作信息：对象为集合g，数量为g的卡数（对方手卡·额外卡组的可送墓卡总数）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- ③的效果处理：将对方手卡·额外卡组中所有可送去墓地的卡全部送去墓地。
function c35546670.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取对方手卡及额外卡组中当前所有可送去墓地的卡（以处理时状态为准）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_HAND+LOCATION_EXTRA,nil)
	-- 将这些卡全部以效果原因（REASON_EFFECT）送去墓地，完成③的后续处理。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
