--死霊の盾
-- 效果：
-- ①：对方怪兽的攻击宣言时1次，从自己墓地把1只恶魔族·不死族怪兽除外才能发动。那次攻击无效。
-- ②：1回合1次，要让卡破坏的效果由对方发动时，从自己墓地把1只恶魔族·不死族怪兽除外才能发动。那个发动无效。
-- ③：自己·对方的结束阶段，恶魔族·不死族怪兽不在自己场上存在的场合发动。这张卡送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方怪兽的攻击宣言时1次，从自己墓地把1只恶魔族·不死族怪兽除外才能发动。那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"攻击无效"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(s.condition)
	e2:SetCost(s.cost)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	-- ②：1回合1次，要让卡破坏的效果由对方发动时，从自己墓地把1只恶魔族·不死族怪兽除外才能发动。那个发动无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.cost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	-- ③：自己·对方的结束阶段，恶魔族·不死族怪兽不在自己场上存在的场合发动。这张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件判断函数
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否由对方控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤自己墓地中可以作为Cost除外的恶魔族或不死族怪兽
function s.cfilter(c)
	return c:IsRace(RACE_FIEND+RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
end
-- 效果①和效果②的发动Cost处理函数
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足条件的恶魔族或不死族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的恶魔族或不死族怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的效果处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使那次攻击无效
	Duel.NegateAttack()
end
-- 效果②的发动条件判断函数
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的效果是否包含破坏卡片的操作
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and rp==1-tp
end
-- 效果②的发动准备与目标确认函数
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将要使发动无效的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 向对方玩家提示本卡发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②的效果处理函数
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该效果的发动无效
	Duel.NegateActivation(ev)
end
-- 效果③的发动条件判断函数
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的恶魔族或不死族怪兽，若不存在则返回真
	return not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsRace),tp,LOCATION_MZONE,0,1,nil,RACE_FIEND+RACE_ZOMBIE)
end
-- 效果③的发动准备与目标确认函数
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将这张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 向对方玩家提示本卡发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果③的效果处理函数
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
