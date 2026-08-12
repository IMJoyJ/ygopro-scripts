--天空の宝札
-- 效果：
-- 这张卡发动的回合，自己不能把怪兽特殊召唤，不能进行战斗阶段。
-- ①：从手卡把1只天使族·光属性怪兽除外，自己从卡组抽2张。
function c54977057.initial_effect(c)
	-- 这张卡发动的回合，自己不能把怪兽特殊召唤，不能进行战斗阶段。①：从手卡把1只天使族·光属性怪兽除外，自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c54977057.cost)
	e1:SetTarget(c54977057.target)
	e1:SetOperation(c54977057.activate)
	c:RegisterEffect(e1)
end
-- 检查本回合是否进行过特殊召唤和战斗阶段，并注册发动的回合自己不能特殊召唤、不能进行战斗阶段的誓约效果
function c54977057.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合发动前自己是否进行过特殊召唤或进入过战斗阶段
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 and Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 这张卡发动的回合，自己不能把怪兽特殊召唤，不能进行战斗阶段。①：从手卡把1只天使族·光属性怪兽除外，自己从卡组抽2张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册“不能特殊召唤怪兽”的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BP)
	-- 给玩家注册“不能进行战斗阶段”的效果
	Duel.RegisterEffect(e2,tp)
end
-- 过滤手卡中可以除外的天使族·光属性怪兽
function c54977057.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsAbleToRemove()
end
-- 效果发动的合法性检测，确认玩家是否能抽卡且手卡有可除外的怪兽
function c54977057.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查手卡中是否存在至少1只满足过滤条件的天使族·光属性怪兽
		and Duel.IsExistingMatchingCard(c54977057.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息，表明该效果包含抽2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置操作信息，表明该效果包含将手卡中1张卡除外的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手卡将1只天使族·光属性怪兽除外，并从卡组抽2张卡
function c54977057.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡选择1只满足过滤条件的天使族·光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c54977057.filter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	-- 让玩家从卡组抽2张卡
	Duel.Draw(tp,2,REASON_EFFECT)
end
