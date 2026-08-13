--紅玉の宝札
-- 效果：
-- 「红玉之宝札」在1回合只能发动1张。
-- ①：从手卡把1只7星「真红眼」怪兽送去墓地才能发动。自己从卡组抽2张。那之后，可以从卡组把1只7星「真红眼」怪兽送去墓地。
function c32566831.initial_effect(c)
	-- 「红玉之宝札」在1回合只能发动1张。①：从手卡把1只7星「真红眼」怪兽送去墓地才能发动。自己从卡组抽2张。那之后，可以从卡组把1只7星「真红眼」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,32566831+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c32566831.cost)
	e1:SetTarget(c32566831.target)
	e1:SetOperation(c32566831.activate)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：满足「真红眼」字段、等级为7、且可以作为代价送去墓地的怪兽，用于从手卡选择代价。
function c32566831.cfilter(c)
	return c:IsSetCard(0x3b) and c:IsLevel(7) and c:IsAbleToGraveAsCost()
end
-- 代价函数：先检查发动时是否存在可丢弃的代价怪兽；若满足，则从手卡选择1只7星「真红眼」怪兽丢弃作为发动代价。
function c32566831.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：自己的手卡中是否存在至少1只满足「真红眼」字段、7星且可作为代价送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c32566831.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡选择1只满足条件的「真红眼」7星怪兽，以代价理由丢弃去墓地。
	Duel.DiscardHand(tp,c32566831.cfilter,1,1,REASON_COST,nil)
end
-- 目标设定函数：设定效果抽取的对象玩家为自己、抽卡数为2，并登记抽卡分类的操作信息。
function c32566831.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己当前是否可以进行2张抽卡（不受“不能抽卡”效果影响）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的效果对象玩家设为发动者自身，用于后续抽卡处理。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果参数设为2，表示这次效果要抽取的卡数为2。
	Duel.SetTargetParam(2)
	-- 登记抽卡的操作信息：分类为抽卡，抽取玩家为tp，预计抽取2张，提供给相关效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 定义送墓筛选函数：满足「真红眼」字段、等级为7、且可以送去墓地的怪兽，用于从卡组选择追加送墓的卡。
function c32566831.tgfilter(c)
	return c:IsSetCard(0x3b) and c:IsLevel(7) and c:IsAbleToGrave()
end
-- 效果处理函数：执行抽2张；若抽卡成功且卡组存在符合条件的「真红眼」7星怪兽，则由玩家选择是否将1只送去墓地。
function c32566831.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得之前设定的对象玩家和参数，即抽卡玩家p和抽卡数量d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，返回实际抽到的卡数dr。
	local dr=Duel.Draw(p,d,REASON_EFFECT)
	-- 获取玩家p卡组中所有满足「真红眼」字段、7星且可以送去墓地的怪兽集合。
	local g=Duel.GetMatchingGroup(c32566831.tgfilter,p,LOCATION_DECK,0,nil)
	-- 仅当实际抽卡数不为0、卡组存在可选怪兽且玩家选择“是”时，才执行追加从卡组送墓的处理。
	if dr~=0 and g:GetCount()>0 and Duel.SelectYesNo(p,aux.Stringid(32566831,0)) then  --"是否从卡组把1只7星「真红眼」怪兽送去墓地？"
		-- 中断当前效果处理，使后续的送墓处理与抽卡处理视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 显示卡片选择提示“请选择要送去墓地的卡”，供玩家从卡组选择要送去墓地的怪兽。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(p,1,1,nil)
		-- 将玩家选择的怪兽以效果原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
