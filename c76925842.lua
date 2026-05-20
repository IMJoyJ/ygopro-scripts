--ダーク・パーシアス
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，可以把自己墓地存在的1只暗属性怪兽从游戏中除外，从自己卡组抽1张卡。这张卡的攻击力上升自己墓地存在的暗属性怪兽数量×100的数值。
function c76925842.initial_effect(c)
	-- 这张卡的攻击力上升自己墓地存在的暗属性怪兽数量×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c76925842.atkval)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏对方怪兽的场合，可以把自己墓地存在的1只暗属性怪兽从游戏中除外，从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76925842,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c76925842.drcon)
	e2:SetCost(c76925842.drcost)
	e2:SetTarget(c76925842.drtg)
	e2:SetOperation(c76925842.drop)
	c:RegisterEffect(e2)
end
-- 计算攻击力上升值的函数
function c76925842.atkval(e,c)
	-- 返回自己墓地存在的暗属性怪兽数量乘以100的数值
	return Duel.GetMatchingGroupCount(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK)*100
end
-- 判断是否满足发动条件：此卡在战斗中，且战斗破坏了对方的怪兽
function c76925842.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 过滤条件：自己墓地可以作为代价除外的暗属性怪兽
function c76925842.rfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 执行发动代价：将自己墓地1只暗属性怪兽除外
function c76925842.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地是否存在至少1只可除外的暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76925842.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c76925842.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果目标与操作信息（抽卡）
function c76925842.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前效果的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家tp抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行效果处理：玩家抽卡
function c76925842.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
