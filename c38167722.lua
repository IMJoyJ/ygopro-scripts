--闇霊術－「欲」
-- 效果：
-- 把自己场上1只暗属性怪兽解放才能发动。对方可以从手卡把1张魔法卡给人观看让这张卡的效果无效。没给观看的场合，自己从卡组抽2张卡。
function c38167722.initial_effect(c)
	-- 该脚本实现的效果原文：把自己场上1只暗属性怪兽解放才能发动。对方可以从手卡把1张魔法卡给人观看让这张卡的效果无效。没给观看的场合，自己从卡组抽2张卡。
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
-- cost函数整体：完成发动代价的检测与执行——先确认自己场上有暗属性怪兽可解放，再选择1只解放作为COST。
function c38167722.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己场上是否存在1只暗属性怪兽可以解放作为发动代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_DARK) end
	-- 从自己场上选择1只暗属性怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_DARK)
	-- 将选择出的怪兽以代价解放（REASON_COST）的方式解放，完成发动COST。
	Duel.Release(g,REASON_COST)
end
-- target函数整体：发动时设定效果对象——确认自己可以抽2张卡，将对象玩家设为自己、对象参数设为2，并登记抽卡效果的操作信息。
function c38167722.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：检查发动者tp是否可以抽2张卡，若不能则无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设为tp，即抽卡玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为2，表示抽卡数量为2。
	Duel.SetTargetParam(2)
	-- 登记操作信息：本效果属于抽卡效果，目标玩家为tp，预计抽卡张数为2，用于其他卡的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 过滤函数：选取对方手卡中未公开的魔法卡，作为对方可展示无效的候选卡。
function c38167722.cfilter(c)
	return not c:IsPublic() and c:IsType(TYPE_SPELL)
end
-- activate函数整体：效果处理时先询问对方是否展示手卡魔法卡；若展示则无效本效果并结束，若不展示则自己抽2张卡。
function c38167722.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家p（自己）和参数d（抽卡数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 判断当前连锁是否能被无效（即对方是否仍能通过展示魔法卡来无效本效果）。
	if Duel.IsChainDisablable(0) then
		local sel=1
		-- 获取对方手卡中所有未公开的魔法卡，作为可展示的候选集合。
		local g=Duel.GetMatchingGroup(c38167722.cfilter,p,0,LOCATION_HAND,nil)
		-- 发送提示消息，询问对方是否要将手卡中的一张魔法卡给发动者观看。
		Duel.Hint(HINT_SELECTMSG,1-p,aux.Stringid(38167722,0))  --"是否要把一张魔法卡给对方观看？"
		if g:GetCount()>0 then
			-- 对方选择是否展示魔法卡：选择0为展示（是），选择1为不展示（否）。
			sel=Duel.SelectOption(1-p,1213,1214)
		else
			-- 没有可展示的魔法卡时，强制对方法选择“否”，sel设为1（不展示）。
			sel=Duel.SelectOption(1-p,1214)+1
		end
		if sel==0 then
			-- 提示对方选择一张手卡中的魔法卡以供确认展示。
			Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
			local sg=g:Select(1-p,1,1,nil)
			-- 将对方选择的魔法卡给发动者确认（展示该手卡）。
			Duel.ConfirmCards(p,sg)
			-- 展示后洗切对方手卡，避免手牌顺序信息泄露。
			Duel.ShuffleHand(1-p)
			-- 使当前连锁的效果无效（对方成功展示魔法卡时，发动者的抽卡效果被无效）。
			Duel.NegateEffect(0)
			return
		end
	end
	-- 对方未展示魔法卡的场合，自己从卡组抽2张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
