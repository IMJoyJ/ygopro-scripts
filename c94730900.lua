--焔聖騎士－モージ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被送去墓地的场合，从自己墓地的卡以及除外的自己的卡之中让这张卡以外的战士族·炎属性怪兽或者「圣剑」卡合计3张回到卡组才能发动。自己从卡组抽1张。
-- ②：这张卡在墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
-- ③：这张卡的装备怪兽不会被战斗破坏。
function c94730900.initial_effect(c)
	-- ①：这张卡被送去墓地的场合，从自己墓地的卡以及除外的自己的卡之中让这张卡以外的战士族·炎属性怪兽或者「圣剑」卡合计3张回到卡组才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,94730900)
	e1:SetCost(c94730900.drcost)
	e1:SetTarget(c94730900.drtg)
	e1:SetOperation(c94730900.drop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,94730901)
	e2:SetTarget(c94730900.eqtg)
	e2:SetOperation(c94730900.eqop)
	c:RegisterEffect(e2)
	-- ③：这张卡的装备怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤条件：在墓地或表侧表示除外，且是该卡以外的战士族·炎属性怪兽或「圣剑」卡，且能回到卡组
function c94730900.cfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and ((c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)) or c:IsSetCard(0x207a)) and c:IsAbleToDeckAsCost()
end
-- 效果①的发动代价（Cost）：从自己墓地·除外区选择3张满足条件的卡回到卡组
function c94730900.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地及除外的卡中是否存在至少3张该卡以外的战士族·炎属性怪兽或「圣剑」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c94730900.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,e:GetHandler()) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择3张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c94730900.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,e:GetHandler())
	-- 显现所选择的卡片
	Duel.HintSelection(g)
	-- 将选择的卡作为发动代价洗回卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果①的发动准备（Target）：确认玩家是否可以抽卡，并设置抽卡操作信息
function c94730900.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以效果抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的参数为1张
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的效果处理（Operation）：执行抽卡
function c94730900.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 过滤条件：场上表侧表示的战士族怪兽
function c94730900.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果②的发动准备（Target）：检查魔法与陷阱区域是否有空位，并选择自己场上1只战士族怪兽作为对象
function c94730900.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c94730900.eqfilter(chkc) end
	-- 检查自己的魔法与陷阱区域是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且检查自己场上是否存在可以作为对象的表侧表示战士族怪兽
		and Duel.IsExistingTarget(c94730900.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的战士族怪兽作为效果对象
	Duel.SelectTarget(tp,c94730900.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁的操作信息为将自身装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置连锁的操作信息为自身离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（Operation）：将自身作为装备卡装备给目标怪兽，并添加装备限制
function c94730900.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为装备对象的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToEffect(e) then
		-- 尝试将自身作为装备卡装备给目标怪兽，若失败则结束处理
		if not Duel.Equip(tp,c,tc) then return end
		-- 这张卡当作装备卡使用给那只自己怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(c94730900.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 装备限制：该装备卡只能装备给作为对象的那只怪兽
function c94730900.eqlimit(e,c)
	return c==e:GetLabelObject()
end
