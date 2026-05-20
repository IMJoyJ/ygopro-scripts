--セリオンズ・チャージ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·魔法与陷阱区域（表侧表示）把1张「兽带斗神突击」以外的「兽带斗神」卡或者「无尽机关 银星系统」送去墓地才能发动。自己抽2张。
function c57285770.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·魔法与陷阱区域（表侧表示）把1张「兽带斗神突击」以外的「兽带斗神」卡或者「无尽机关 银星系统」送去墓地才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,57285770+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c57285770.cost)
	e1:SetTarget(c57285770.target)
	e1:SetOperation(c57285770.activate)
	c:RegisterEffect(e1)
end
-- 过滤作为发动代价送去墓地的卡：手牌中或魔陷区表侧表示的、除「兽带斗神突击」以外的「兽带斗神」卡或「无尽机关 银星系统」
function c57285770.costfilter(c)
	return (c:IsSetCard(0x179) or c:IsCode(21887075)) and not c:IsCode(57285770) and c:IsAbleToGraveAsCost()
		and ((c:IsFaceup() and c:GetSequence()<5) or not c:IsLocation(LOCATION_SZONE))
end
-- 效果发动的代价处理：从手牌或魔陷区将1张符合条件的卡送去墓地
function c57285770.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌或魔陷区是否存在至少1张满足条件的卡可以作为代价送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c57285770.costfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手牌或魔陷区选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c57285770.costfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,1,nil)
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动的目标处理：检查玩家是否能抽卡，并设置抽卡玩家、抽卡数量以及操作信息
function c57285770.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为自身
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数（抽卡数量）设置为2
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：获取目标玩家和抽卡数量，执行抽卡效果
function c57285770.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
