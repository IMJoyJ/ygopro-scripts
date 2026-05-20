--D-HERO ディスクガイ
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。这张卡在送去墓地的回合不能作从墓地的特殊召唤。
-- ①：这张卡从墓地的特殊召唤成功的场合才能发动。自己从卡组抽2张。
function c56570271.initial_effect(c)
	-- 这个卡名的效果在决斗中只能使用1次。①：这张卡从墓地的特殊召唤成功的场合才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56570271,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,56570271+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c56570271.condition)
	e1:SetTarget(c56570271.target)
	e1:SetOperation(c56570271.operation)
	c:RegisterEffect(e1)
	-- 这张卡在送去墓地的回合不能作从墓地的特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c56570271.splimit)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤限制的条件函数，用于限制这张卡在送去墓地的回合不能从墓地特殊召唤
function c56570271.splimit(e,se,sp,st)
	local c=e:GetHandler()
	-- 若该卡不在墓地，或当前回合不是该卡送去墓地的回合，或因回到墓地等特殊原因，则允许特殊召唤
	return not c:IsLocation(LOCATION_GRAVE) or Duel.GetTurnCount()~=c:GetTurnID() or c:IsReason(REASON_RETURN)
end
-- 确认这张卡是从墓地特殊召唤成功的发动条件
function c56570271.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- 定义效果发动的目标确认与操作信息设置函数
function c56570271.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查玩家是否具有抽2张卡的能力
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的目标玩家设置为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 向系统宣告此效果包含抽卡分类，预计由玩家tp抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 定义效果处理的执行函数
function c56570271.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在target阶段锁定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果，让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
