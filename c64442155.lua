--慈悲深き機械天使
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己的手卡·场上1只「电子化天使」仪式怪兽解放才能发动。自己从卡组抽2张，那之后选1张手卡回到卡组最下面。这张卡的发动后，直到回合结束时自己不是仪式怪兽不能特殊召唤。
function c64442155.initial_effect(c)
	-- ①：把自己的手卡·场上1只「电子化天使」仪式怪兽解放才能发动。自己从卡组抽2张，那之后选1张手卡回到卡组最下面。这张卡的发动后，直到回合结束时自己不是仪式怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,64442155+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c64442155.cost)
	e1:SetTarget(c64442155.target)
	e1:SetOperation(c64442155.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：属于「电子化天使」系列且是仪式怪兽的卡
function c64442155.costfilter(c)
	return c:IsSetCard(0x2093) and c:GetType()&0x81==0x81
end
-- 发动代价（Cost）：解放手卡·场上1只「电子化天使」仪式怪兽
function c64442155.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·场上是否存在至少1只可解放的「电子化天使」仪式怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c64442155.costfilter,1,REASON_COST,true,nil) end
	-- 设置选择卡片时的提示信息为“请选择要返回卡组的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手卡·场上选择1只满足过滤条件的怪兽用于解放
	local g=Duel.SelectReleaseGroupEx(tp,c64442155.costfilter,1,1,REASON_COST,true,nil)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 效果的目标处理：检查是否能抽卡，并设置抽卡玩家、抽卡数量及操作信息
function c64442155.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的效果处理对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的效果处理参数（抽卡数量）为2
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为“玩家抽2张卡”
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：抽2张卡，然后选1张手卡回到卡组最下面，并适用特殊召唤限制
function c64442155.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
	-- 获取玩家手卡中可以送回卡组的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要送回卡组的卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=g:Select(p,1,1,nil)
		-- 将选中的手卡送回卡组最下面
		Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是仪式怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c64442155.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该限制效果，使其对玩家生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能特殊召唤原本卡片类型不是仪式怪兽的怪兽
function c64442155.splimit(e,c)
	return c:GetOriginalType()&0x81~=0x81
end
