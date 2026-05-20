--貪欲なウツボ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示的鱼族·海龙族·水族怪兽除外才能发动。自己抽2张。
local s,id,o=GetID()
-- 注册卡片发动时的效果：包含抽卡分类、自由时点发动、同名卡一回合一次限制、影响玩家属性、代价、目标及操作处理。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只表侧表示的鱼族·海龙族·水族怪兽除外才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.act)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的鱼族、海龙族或水族怪兽，且可以作为代价除外。
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH+RACE_SEASERPENT+RACE_AQUA) and c:IsAbleToRemoveAsCost()
end
-- 效果发动的代价处理：检查并选择自己场上1只表侧表示的鱼族·海龙族·水族怪兽除外。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤1（检查）：检查自己场上是否存在至少1只满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己场上1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽以表侧表示除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的目标处理：检查玩家是否能抽卡，并设置抽卡玩家、抽卡数量及操作信息。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 步骤1（检查）：检查自己当前是否可以效果抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2（抽卡张数）。
	Duel.SetTargetParam(2)
	-- 设置连锁的操作信息为：自己抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果的运行空间（操作处理）：获取目标玩家和参数，执行抽卡。
function s.act(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
