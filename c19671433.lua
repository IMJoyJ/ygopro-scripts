--伍世壊心像
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只「末那愚子族」怪兽或者「维萨斯-斯塔弗罗斯特」给对方观看才能发动。自己从卡组抽2张。那之后，选1张手卡回到卡组最下面。
-- ②：把墓地的这张卡除外，以自己场上1只攻击力1500/守备力2100的怪兽为对象才能发动。那只怪兽直到回合结束时当作调整使用。
local s,id,o=GetID()
-- 注册卡片的两个效果，分别是抽卡效果和变成调整效果
function s.initial_effect(c)
	-- 记录该卡与「维萨斯-斯塔弗罗斯特」的卡号关联
	aux.AddCodeList(c,56099748)
	-- 效果①的定义，包括抽卡和回卡组的效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 效果②的定义，将墓地的自己场上1只攻击力1500/守备力2100的怪兽变成调整
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变成调整"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 效果②的发动需要把此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tuntg)
	e2:SetOperation(s.tunop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否满足条件的卡（公开状态且为末那愚子族怪兽或维萨斯-斯塔弗罗斯特）
function s.cfilter(c)
	local b1=c:IsCode(56099748)
	local b2=c:IsSetCard(0x190) and c:IsType(TYPE_MONSTER)
	return not c:IsPublic() and (b1 or b2)
end
-- 效果①的发动费用处理，选择并确认给对方观看的卡
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动条件（手卡存在符合条件的卡）
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
end
-- 效果①的发动效果处理，设置抽卡和回卡组的目标信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动条件（玩家可以抽2张卡）
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果①的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果①的目标参数为2（抽2张卡）
	Duel.SetTargetParam(2)
	-- 设置效果①的抽卡操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置效果①的回卡组操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 效果①的发动效果处理，执行抽卡和回卡组操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果并判断是否成功抽到2张卡
	if Duel.Draw(p,d,REASON_EFFECT)==2 then
		-- 洗切自己的手牌
		Duel.ShuffleHand(p)
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 选择要返回卡组的卡
		local sg=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,1,nil)
		if #sg>0 then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的卡送回卡组最底端
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
-- 过滤函数，用于判断场上是否满足条件的怪兽（不是调整且攻击力1500/守备力2100）
function s.tfilter(c)
	return not c:IsType(TYPE_TUNER) and c:IsFaceup() and c:IsAttack(1500) and c:IsDefense(2100)
end
-- 效果②的发动效果处理，选择目标怪兽
function s.tuntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tfilter(chkc) end
	-- 检查是否满足效果②的发动条件（场上存在符合条件的怪兽）
	if chk==0 then return Duel.IsExistingTarget(s.tfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的怪兽作为对象
	Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的发动效果处理，将目标怪兽变成调整
function s.tunop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽变成调整的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
