--七星の宝刀
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只7星怪兽除外才能发动。自己从卡组抽2张。
function c45725480.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡以及自己场上的表侧表示怪兽之中把1只7星怪兽除外才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,45725480+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c45725480.cost)
	e1:SetTarget(c45725480.target)
	e1:SetOperation(c45725480.activate)
	c:RegisterEffect(e1)
end
-- 筛选函数：判断一张卡是否满足作为发动代价的条件，即位于手牌或表侧表示、等级为7且可以作为代价除外。
function c45725480.filter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsLevel(7) and c:IsAbleToRemoveAsCost()
end
-- 代价处理函数：先检查是否存在满足条件的7星怪兽，若存在则提示玩家选择1张，然后将选中的怪兽作为代价除外。
function c45725480.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：在代价确认阶段，检查玩家手牌或自己场上的表侧表示怪兽中是否存在至少1只满足筛选条件的7星怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c45725480.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示提示消息，要求其选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手牌及自己场上的表侧表示怪兽中选择1只符合条件的7星怪兽。
	local g=Duel.SelectMatchingCard(tp,c45725480.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽以表侧表示除外，作为这张卡发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动目标设定：确认玩家可以抽2张卡，并把抽卡对象玩家和抽卡数量写入连锁信息，以便处理时使用。
function c45725480.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：确认发动者tp当前能否通过效果抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的效果对象玩家设置为tp，即由这张卡的发动者抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的效果对象参数设置为2，即抽卡数量为2张。
	Duel.SetTargetParam(2)
	-- 设置本次连锁的操作信息：这是一个抽卡效果，预计从tp的卡组抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：从连锁信息中取出目标玩家和抽卡数量，然后让该玩家执行抽卡。
function c45725480.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家和抽卡数量参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡，即实际执行从卡组抽2张。
	Duel.Draw(p,d,REASON_EFFECT)
end
