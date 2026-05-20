--登竜華恐巄門
-- 效果：
-- ①：「登龙华恐巃门」在自己场上只能有1张表侧表示存在。
-- ②：只要这张卡在魔法与陷阱区域存在，自己场上的「龙华」怪兽的攻击力上升300。
-- ③：自己场上的「龙华」灵摆怪兽以及10星以上而原本种族是恐龙族的怪兽得到以下效果。
-- ●1回合1次，比这张卡攻击力低的场上的怪兽的效果发动时，让自己场上1张表侧表示的「龙华」永续魔法卡回到卡组最下面才能发动。那个发动无效。
local s,id,o=GetID()
-- 初始化函数，注册场上唯一存在限制、攻击力上升、赋予其他怪兽效果以及使被赋予效果的怪兽变为效果怪兽等效果
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己场上的「龙华」怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 过滤并确定攻击力上升效果的影响对象为自己场上的「龙华」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1c0))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- ●1回合1次，比这张卡攻击力低的场上的怪兽的效果发动时，让自己场上1张表侧表示的「龙华」永续魔法卡回到卡组最下面才能发动。那个发动无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"发动无效（「登龙华恐巃门」）"
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	-- ③：自己场上的「龙华」灵摆怪兽以及10星以上而原本种族是恐龙族的怪兽得到以下效果。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- ③：自己场上的「龙华」灵摆怪兽以及10星以上而原本种族是恐龙族的怪兽得到以下效果。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ADD_TYPE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.eftg)
	e5:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_REMOVE_TYPE)
	e6:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e6)
end
-- 检查发动无效效果的条件：发动的效果是怪兽效果、该发动可被无效、自身未被战斗破坏、效果在场上发动，且自身攻击力高于发动效果的怪兽在场上的攻击力
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的发动位置以及发动时的攻击力
	local loc,atk=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_ATTACK)
	-- 检查发动的效果是否为怪兽效果，且该发动是否可以被无效
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and (LOCATION_ONFIELD)&loc~=0
		and e:GetHandler():GetAttack()>atk
end
-- 过滤自己场上表侧表示的「龙华」永续魔法卡
function s.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1c0) and c:IsAbleToDeckAsCost()
		and bit.band(c:GetType(),TYPE_SPELL+TYPE_CONTINUOUS)==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 发动无效效果的Cost处理：选择自己场上1张表侧表示的「龙华」永续魔法卡回到卡组最下面
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少1张满足条件的「龙华」永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择1张满足条件的「龙华」永续魔法卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 为选中的卡片显示被选为对象的动画效果
	Duel.HintSelection(g)
	-- 将选中的卡作为Cost送回持有者卡组的最下面
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 发动无效效果的Target处理：设置连锁的发动无效为操作信息
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为“使该怪兽效果的发动无效”
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 发动无效效果的Operation处理：使该连锁的发动无效
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的发动无效
	Duel.NegateActivation(ev)
end
-- 过滤得到效果的对象：10星以上且原本种族是恐龙族的怪兽，或者「龙华」灵摆怪兽
function s.eftg(e,c)
	return c:IsLevelAbove(10) and c:GetOriginalRace()==RACE_DINOSAUR
		or c:IsSetCard(0x1c0) and c:IsType(TYPE_PENDULUM)
end
