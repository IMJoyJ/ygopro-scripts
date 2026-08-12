--ビッグ・インフレート・ドラゴン
-- 效果：
-- ①：这张卡召唤的场合，从自己卡组上面把50张卡里侧除外才能发动。这张卡的攻击力直到回合结束时变成10000。
local s,id,o=GetID()
-- 注册该卡召唤成功时发动的诱发效果
function s.initial_effect(c)
	-- ①：这张卡召唤的场合，从自己卡组上面把50张卡里侧除外才能发动。这张卡的攻击力直到回合结束时变成10000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"改变攻击力"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 检查并执行发动代价：从自己卡组最上方将50张卡里侧表示除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家卡组最上方的50张卡
	local g=Duel.GetDecktopGroup(tp,50)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==50 end
	-- 使接下来的操作不触发洗牌检测
	Duel.DisableShuffleCheck()
	-- 将这50张卡作为发动代价里侧表示除外
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 检查效果发动目标，确认这张卡的攻击力当前不为10000
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsAttack(10000) end
end
-- 执行效果处理，使这张卡的攻击力直到回合结束时变成10000
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力直到回合结束时变成10000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(10000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
