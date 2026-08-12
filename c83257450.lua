--幻の召喚神エクゾディア
-- 效果：
-- 「被封印」怪兽×5
-- ①：场上的这张卡不会被对方的效果破坏。
-- ②：1回合1次，这张卡进行战斗的伤害计算时才能发动。这张卡的攻击力上升自己基本分数值。
-- ③：1回合1次，魔法·陷阱卡的效果发动时才能发动。那个发动无效。
-- ④：自己·对方的结束阶段才能发动。从卡组把1张「艾格佐德」魔法·陷阱卡在自己场上盖放。
-- ⑤：自己准备阶段发动。自己失去1000基本分。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续，需要5只满足过滤条件s.matfilter的怪兽作为素材
	aux.AddFusionProcFunRep(c,s.matfilter,5,true)
	-- ①：场上的这张卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	-- 设置不会被对方的效果破坏
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡进行战斗的伤害计算时才能发动。这张卡的攻击力上升自己基本分数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"上升攻击力"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，魔法·陷阱卡的效果发动时才能发动。那个发动无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	-- ④：自己·对方的结束阶段才能发动。从卡组把1张「艾格佐德」魔法·陷阱卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"盖放魔陷"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
	-- ⑤：自己准备阶段发动。自己失去1000基本分。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))  --"失去基本分"
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetCountLimit(1)
	e5:SetCondition(s.damcon)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
end
-- 融合素材过滤条件：属于「被封印」系列（0x40）的怪兽
function s.matfilter(c)
	return c:IsFusionSetCard(0x40)
end
-- 攻击力上升效果的发动条件判定函数
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡是否是本次战斗的攻击怪兽或被攻击怪兽
	return c==Duel.GetAttacker() or c==Duel.GetAttackTarget()
end
-- 攻击力上升效果的执行函数
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升自己基本分数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		-- 设置攻击力上升数值为当前回合玩家的基本分
		e1:SetValue(Duel.GetLP(tp))
		c:RegisterEffect(e1)
	end
end
-- 魔法·陷阱效果发动无效效果的发动条件判定函数
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定发动的效果是否为魔法·陷阱卡的效果，且该发动可以被无效
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 魔法·陷阱效果发动无效效果的目标过滤与效果分类注册函数
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息，表示该效果的处理包含“使发动无效”的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 魔法·陷阱效果发动无效效果的执行函数
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效
	Duel.NegateActivation(ev)
end
-- 过滤条件：卡组中属于「艾格佐德」系列（0x1af）的魔法·陷阱卡，且可以盖放在场上
function s.filter(c)
	return c:IsSetCard(0x1af) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 盖放「艾格佐德」魔陷效果的目标过滤与可行性检查函数
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「艾格佐德」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放「艾格佐德」魔陷效果的执行函数
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「艾格佐德」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 失去基本分效果的发动条件判定函数
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 失去基本分效果的执行函数
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己的基本分减少1000点
	Duel.SetLP(tp,Duel.GetLP(tp)-1000)
end
