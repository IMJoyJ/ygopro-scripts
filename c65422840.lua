--酒呑童子
-- 效果：
-- ①：1回合1次，可以从以下效果选择1个发动。
-- ●从自己墓地把2只不死族怪兽除外才能发动。自己从卡组抽1张。
-- ●以除外的1只自己的不死族怪兽为对象才能发动。那只怪兽回到卡组最上面。
function c65422840.initial_effect(c)
	-- ①：1回合1次，可以从以下效果选择1个发动。●从自己墓地把2只不死族怪兽除外才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65422840,0))  --"除外并抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCost(c65422840.drcost)
	e1:SetTarget(c65422840.drtg)
	e1:SetOperation(c65422840.drop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，可以从以下效果选择1个发动。●以除外的1只自己的不死族怪兽为对象才能发动。那只怪兽回到卡组最上面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65422840,1))  --"回收除外的卡"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(c65422840.tdtg)
	e2:SetOperation(c65422840.tdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地的不死族怪兽且可以作为代价除外
function c65422840.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 抽卡效果的cost（代价）处理：从自己墓地把2只不死族怪兽除外
function c65422840.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少2只可以作为代价除外的不死族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65422840.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地2只满足条件的不死族怪兽
	local g=Duel.SelectMatchingCard(tp,c65422840.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的怪兽表侧表示除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 抽卡效果的target（目标）处理：确认玩家是否能抽卡并设置抽卡操作信息
function c65422840.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以效果抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家tp抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的operation（效果处理）：执行抽卡
function c65422840.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤条件：除外的表侧表示的不死族怪兽且可以回到卡组
function c65422840.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToDeck()
end
-- 回收效果的target（目标）处理：选择除外的1只自己的不死族怪兽为对象，并设置回卡组操作信息
function c65422840.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c65422840.filter(chkc) end
	-- 检查除外区是否存在至少1只满足条件的自己的不死族怪兽
	if chk==0 then return Duel.IsExistingTarget(c65422840.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择除外的1只自己的不死族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c65422840.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 回收效果的operation（效果处理）：将对象怪兽回到卡组最上面
function c65422840.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回持有者卡组的最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
