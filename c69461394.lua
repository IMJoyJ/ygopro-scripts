--A・O・J フィールド・マーシャル
-- 效果：
-- 调整＋调整以外的怪兽2只以上
-- 这张卡不用同调召唤不能特殊召唤。这张卡的攻击破坏里侧守备表示怪兽送去墓地时，从卡组抽1张卡。
function c69461394.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽2只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- 这张卡不用同调召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡的攻击破坏里侧守备表示怪兽送去墓地时，从卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69461394,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c69461394.condition)
	e2:SetTarget(c69461394.target)
	e2:SetOperation(c69461394.operation)
	c:RegisterEffect(e2)
end
-- 触发条件：仅有1只怪兽因战斗破坏送去墓地，且该怪兽在场上时为里侧守备表示，并且是被这张卡攻击破坏
function c69461394.condition(e,tp,eg,ep,ev,re,r,rp)
	local dg=eg:GetFirst()
	return eg:GetCount()==1 and dg:IsLocation(LOCATION_GRAVE) and dg:IsReason(REASON_BATTLE)
		and dg:GetBattlePosition()==POS_FACEDOWN_DEFENSE and dg:GetReasonCard()==e:GetHandler()
end
-- 发动阶段：检查玩家是否可以抽卡，并设置效果的对象玩家、抽卡数量及操作信息
function c69461394.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家是否可以从卡组抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前连锁的对象玩家设置为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数（抽卡数量）设置为1
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：获取目标玩家和抽卡数量，执行抽卡操作
function c69461394.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
