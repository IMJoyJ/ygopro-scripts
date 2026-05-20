--ラヴァルバル・サラマンダー
-- 效果：
-- 调整＋调整以外的炎属性怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。自己从卡组抽2张，那之后从手卡把包含炎属性怪兽的2张卡送去墓地。手卡没有炎属性怪兽的场合，手卡全部公开，回到卡组。
-- ②：1回合1次，从自己墓地把1只炎属性怪兽除外才能发动。选最多有自己场上的「熔岩」怪兽数量的对方场上的表侧表示怪兽变成里侧守备表示。
function c67797569.initial_effect(c)
	-- 设置同调召唤的手续：调整+1只以上调整以外的炎属性怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。自己从卡组抽2张，那之后从手卡把包含炎属性怪兽的2张卡送去墓地。手卡没有炎属性怪兽的场合，手卡全部公开，回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67797569,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,67797569)
	e1:SetCondition(c67797569.drcon)
	e1:SetTarget(c67797569.drtg)
	e1:SetOperation(c67797569.drop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从自己墓地把1只炎属性怪兽除外才能发动。选最多有自己场上的「熔岩」怪兽数量的对方场上的表侧表示怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67797569,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c67797569.cost)
	e2:SetTarget(c67797569.settg)
	e2:SetOperation(c67797569.setop)
	c:RegisterEffect(e2)
end
-- 设置效果①的发动条件：这张卡同调召唤成功
function c67797569.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果①的发动准备（检查是否能抽卡、设置效果分类为抽卡）
function c67797569.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为2（抽卡张数）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：自己从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 检查选中的卡片组中是否包含至少1只炎属性怪兽
function c67797569.tgcheck(g)
	return g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE)
end
-- 效果①的效果处理：抽2张卡，之后从手卡送去2张卡（包含炎属性）到墓地，若没有炎属性则公开全部手卡并回到卡组
function c67797569.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
	-- 中断当前效果处理，使后续处理与抽卡不视为同时进行
	Duel.BreakEffect()
	-- 获取自己当前的所有手卡
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tg=g:SelectSubGroup(tp,c67797569.tgcheck,false,2,2)
	if tg then
		-- 将选中的2张卡因效果送去墓地，并检查是否成功送去墓地
		if Duel.SendtoGrave(tg,REASON_EFFECT)==0 then
			-- 洗切玩家的手卡
			Duel.ShuffleHand(p)
		end
	else
		-- 获取玩家当前的所有手卡（用于手卡没有炎属性怪兽时的处理）
		local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
		-- 将手卡全部公开给对方玩家确认
		Duel.ConfirmCards(1-p,sg)
		-- 将全部手卡送回持有者的卡组并洗牌
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤墓地中可以作为发动代价除外的炎属性怪兽
function c67797569.refilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价（cost）：从自己墓地把1只炎属性怪兽除外
function c67797569.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以除外的炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67797569.refilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地的1只炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c67797569.refilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤自己场上表侧表示的「熔岩」怪兽
function c67797569.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x39)
end
-- 过滤对方场上可以变成里侧守备表示的表侧表示怪兽
function c67797569.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果②的发动准备（检查自己场上是否有「熔岩」怪兽，以及对方场上是否有可变里侧的表侧怪兽）
function c67797569.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的「熔岩」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67797569.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查对方场上是否存在至少1只可以变成里侧守备表示的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c67797569.posfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果②的效果处理：选最多有自己场上的「熔岩」怪兽数量的对方场上的表侧表示怪兽变成里侧守备表示
function c67797569.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上表侧表示的「熔岩」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c67797569.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择对方场上1到ct张（ct为自己场上「熔岩」怪兽数量）可以变里侧的表侧表示怪兽
	local g=Duel.SelectMatchingCard(tp,c67797569.posfilter,tp,0,LOCATION_MZONE,1,ct,nil)
	if #g>0 then
		-- 给选中的怪兽显示被选择的动画效果
		Duel.HintSelection(g)
		-- 将选中的怪兽变成里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
