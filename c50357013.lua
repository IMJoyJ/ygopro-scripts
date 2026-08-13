--十種神鏡陣
-- 效果：
-- ①：等级合计直到变成10星为止，从自己的手卡·场上（表侧表示）把怪兽任意数量送去墓地才能发动。自己抽2张。
local s,id,o=GetID()
-- 创建并注册卡的第一个效果：该效果为魔法卡发动型效果，类别为抽卡，带有以玩家为对象属性，可自由时点发动；发动代价、发动目标和处理操作分别由s.cost、s.target、s.activate确定。
function s.initial_effect(c)
	-- ①：等级合计直到变成10星为止，从自己的手卡·场上（表侧表示）把怪兽任意数量送去墓地才能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义可作为代价的怪兽条件：必须是表侧表示、等级为0星以上的怪兽，并且能够作为代价从当前场所送去墓地。
function s.costfilter(c)
	return c:IsLevelAbove(0) and c:IsFaceupEx() and c:IsAbleToGraveAsCost()
end
-- 代价处理：从自己的手卡和场上表侧表示的怪兽中选出合计等级恰好为10星的任意数量怪兽，将其送入墓地作为发动代价；在检查阶段需确认是否存在这样的组合。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡和场上表侧表示怪兽区域中所有满足代价条件的怪兽，构成可选集合g，用于后续等级合计为10的选择。
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	if chk==0 then return g:CheckWithSumEqual(Card.GetLevel,10,1,#g) end
	-- 给玩家显示选择提示，让其从候选怪兽中选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,10,1,#g)
	-- 将玩家选出的合计10星的怪兽组作为发动代价送去墓地。
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 发动目标设定：确认自己可以抽2张卡后，将效果对象玩家设为自己，并登记抽卡数量和操作信息，待处理时执行。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：只有在自己能够抽2张卡时才允许发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将受到效果的玩家设为本方，即抽卡的对象是自己。
	Duel.SetTargetPlayer(tp)
	-- 将效果的参数设为2，表示本次抽卡数量为2张。
	Duel.SetTargetParam(2)
	-- 登记操作信息：本次效果属于抽卡类别，对象玩家为本方，预计抽卡张数为2，供连锁反应和相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：从连锁信息中读取之前设定的对象玩家和抽卡参数，让该玩家抽对应数量的卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家p和参数d（即2），分别作为抽卡执行者和抽卡数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p因为本卡的效果抽取d张卡，完成‘自己抽2张’的处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
