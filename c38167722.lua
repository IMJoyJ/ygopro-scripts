--闇霊術－「欲」
-- 效果：
-- 把自己场上1只暗属性怪兽解放才能发动。对方可以从手卡把1张魔法卡给人观看让这张卡的效果无效。没给观看的场合，自己从卡组抽2张卡。
function c38167722.initial_effect(c)
	-- 效果：把自己场上1只暗属性怪兽解放才能发动。对方可以从手卡把1张魔法卡给人观看让这张卡的效果无效。没给观看的场合，自己从卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c38167722.cost)
	e1:SetTarget(c38167722.target)
	e1:SetOperation(c38167722.activate)
	c:RegisterEffect(e1)
end
-- 检查并选择1只自己场上的暗属性怪兽进行解放作为发动代价。
function c38167722.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动此效果，即检查自己场上是否存在1只暗属性怪兽可解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_DARK) end
	-- 选择1只自己场上的暗属性怪兽进行解放。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_DARK)
	-- 将选中的怪兽解放，作为发动此效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 设置此效果的目标为发动者本人，准备抽2张卡。
function c38167722.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以发动此效果，即检查发动者是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置此效果的目标玩家为发动者本人。
	Duel.SetTargetPlayer(tp)
	-- 设置此效果的目标参数为2，表示要抽2张卡。
	Duel.SetTargetParam(2)
	-- 设置此效果的操作信息为抽卡效果，目标为发动者本人，数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 过滤函数，用于筛选手牌中未公开的魔法卡。
function c38167722.cfilter(c)
	return not c:IsPublic() and c:IsType(TYPE_SPELL)
end
-- 处理效果的发动，根据对方是否选择公开魔法卡来决定是否无效效果或抽卡。
function c38167722.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数，即发动者本人和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 判断当前连锁是否可以被无效，即是否可以被对方选择是否公开魔法卡来无效。
	if Duel.IsChainDisablable(0) then
		local sel=1
		-- 获取发动者手牌中未公开的魔法卡组。
		local g=Duel.GetMatchingGroup(c38167722.cfilter,p,0,LOCATION_HAND,nil)
		-- 提示对方选择是否公开魔法卡。
		Duel.Hint(HINT_SELECTMSG,1-p,aux.Stringid(38167722,0))  --"是否要把一张魔法卡给对方观看？"
		if g:GetCount()>0 then
			-- 如果对方手牌中有魔法卡，则选择是否公开。
			sel=Duel.SelectOption(1-p,1213,1214)
		else
			-- 如果对方手牌中没有魔法卡，则默认不公开。
			sel=Duel.SelectOption(1-p,1214)+1
		end
		if sel==0 then
			-- 提示对方选择要公开的魔法卡。
			Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
			local sg=g:Select(1-p,1,1,nil)
			-- 将选中的魔法卡展示给对方确认。
			Duel.ConfirmCards(p,sg)
			-- 将对方手牌洗切。
			Duel.ShuffleHand(1-p)
			-- 使当前连锁的效果无效。
			Duel.NegateEffect(0)
			return
		end
	end
	-- 发动者从卡组抽2张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
