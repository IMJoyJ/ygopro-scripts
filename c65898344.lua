--ゴーティス・フューリー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只鱼族怪兽和对方场上1只怪兽为对象才能发动。那2只怪兽直到下次的自己准备阶段除外。
-- ②：除外状态的卡存在，自己场上有鱼族怪兽特殊召唤的场合，把魔法与陷阱区域（表侧表示）·墓地的这张卡除外才能发动。自己场上的全部鱼族怪兽的攻击力直到回合结束时上升除外状态的卡数量×100。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：以自己场上1只鱼族怪兽和对方场上1只怪兽为对象才能发动。那2只怪兽直到下次的自己准备阶段除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"双方怪兽除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：除外状态的卡存在，自己场上有鱼族怪兽特殊召唤的场合，把魔法与陷阱区域（表侧表示）·墓地的这张卡除外才能发动。自己场上的全部鱼族怪兽的攻击力直到回合结束时上升除外状态的卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE+LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.atkcon)
	-- 把魔法与陷阱区域（表侧表示）·墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示且可以除外的鱼族怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsAbleToRemove()
end
-- 效果①的发动准备：检查并选择合适的对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在满足条件的鱼族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可以除外的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只表侧表示的鱼族怪兽作为对象
	local g1=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只怪兽作为对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息：除外2张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,0,0)
end
-- 效果①的效果处理：将对象怪兽暂时除外，并注册在准备阶段返回场上的效果
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中仍能被除外的对象怪兽
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsAbleToRemove,nil)
	-- 如果2只怪兽都存在，则将它们暂时除外
	if #g==2 and Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local resetv=1
		-- 判断是否在自己的准备阶段或之前发动，以确定回归的准备阶段
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()<=PHASE_STANDBY then
			resetv=2
		end
		-- 获取本次操作实际除外的卡片组
		local og=Duel.GetOperatedGroup()
		local oc=og:GetFirst()
		while oc do
			oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,resetv)
			oc=og:GetNext()
		end
		og:KeepAlive()
		-- 那2只怪兽直到下次的自己准备阶段除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,resetv)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		-- 记录当前回合数，防止在发动回合的准备阶段直接返回
		e1:SetValue(Duel.GetTurnCount())
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		-- 注册用于在准备阶段将怪兽返回场上的全局时点效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤条件：带有本卡效果标记的卡
function s.retfilter(c)
	return c:GetFlagEffect(id)>0
end
-- 判断是否满足返回场上的条件（必须是自己的准备阶段，且不是除外当回合）
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 如果不是自己的回合，或者是除外当回合，则不处理返回
	if Duel.GetTurnPlayer()~=tp or Duel.GetTurnCount()==e:GetValue() then return false end
	local g=e:GetLabelObject()
	return g:IsExists(s.retfilter,1,nil)
end
-- 在准备阶段将除外的怪兽返回场上的具体处理（处理格子不足等特殊情况）
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local sg=g:Filter(s.retfilter,nil)
	if sg:GetCount()>1 and sg:GetClassCount(Card.GetPreviousControler)==1 then
		-- 获取怪兽原本持有者场上的可用怪兽区域数量
		local ft=Duel.GetLocationCount(sg:GetFirst():GetPreviousControler(),LOCATION_MZONE)
		if ft==1 then
			-- 提示玩家选择要返回场上的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			local tc=sg:Select(tp,1,1,nil):GetFirst()
			-- 将选择的怪兽返回场上
			Duel.ReturnToField(tc)
			sg:RemoveCard(tc)
		end
	end
	-- 将剩余的怪兽全部返回场上
	for tc in aux.Next(sg) do Duel.ReturnToField(tc) end
end
-- 过滤条件：自己场上表侧表示的鱼族怪兽
function s.filter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_FISH) and c:IsControler(tp)
end
-- 效果②的发动条件判断
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有自己的鱼族怪兽特殊召唤，且双方除外状态的卡数量大于0
	return eg:IsExists(s.filter,1,nil,tp) and Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,LOCATION_REMOVED)>0
end
-- 效果②的发动准备：检查是否存在可适用的怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的鱼族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
end
-- 效果②的效果处理：计算除外卡数量并提升自己场上全部鱼族怪兽的攻击力
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算双方除外状态的卡片总数
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,LOCATION_REMOVED)
	-- 获取自己场上所有表侧表示的鱼族怪兽
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,tp)
	-- 遍历自己场上所有的鱼族怪兽
	for tc in aux.Next(g) do
		-- 自己场上的全部鱼族怪兽的攻击力直到回合结束时上升除外状态的卡数量×100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*100)
		tc:RegisterEffect(e1)
	end
end
