--ハチビー
-- 效果：
-- 把这张卡和自己场上表侧表示存在的「小蜜蜂」以外的1只昆虫族怪兽解放发动。从自己卡组抽2张卡。
function c1474910.initial_effect(c)
	-- 把这张卡和自己场上表侧表示存在的「小蜜蜂」以外的1只昆虫族怪兽解放发动。从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1474910,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c1474910.cost)
	e1:SetTarget(c1474910.target)
	e1:SetOperation(c1474910.operation)
	c:RegisterEffect(e1)
end
-- 定义可作为解放对象的卡的条件：必须是表侧表示、昆虫族、且卡名不是「小蜜蜂」（卡号1474910）以外的昆虫族怪兽。
function c1474910.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and not c:IsCode(1474910)
end
-- 发动代价处理：选择自己场上1只满足条件的“小蜜蜂”以外的昆虫族怪兽，与这张卡自身一起解放。
function c1474910.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost检查阶段确认代价是否可行：这张卡自身可以解放，并且自己场上存在至少1只满足条件的其他昆虫族怪兽。
	if chk==0 then return e:GetHandler():IsReleasable() and Duel.CheckReleaseGroup(tp,c1474910.cfilter,1,nil) end
	-- 选择1只满足条件的“小蜜蜂”以外的表侧表示昆虫族怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c1474910.cfilter,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选择的怪兽和这张卡一起解放，作为发动效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 效果的发动目标设定：检查是否可以抽2张卡，并将对象玩家设为发动者、抽卡数设为2，同时登记抽卡效果的操作信息。
function c1474910.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在target检查阶段确认发动者是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为发动者自己（抽卡的玩家）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为2（抽卡数量）。
	Duel.SetTargetParam(2)
	-- 登记操作信息：这是抽卡效果，对象玩家为自己，预计抽卡数为2，用于抽卡时点的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理阶段：从连锁信息中取出对象玩家和抽卡数，实际执行抽卡。
function c1474910.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设置的对象玩家（p）和抽卡数（d）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p抽d张卡（即2张），抽卡原因记为效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
