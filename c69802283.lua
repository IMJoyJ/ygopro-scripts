--集いし光
-- 效果：
-- ①：把自己场上1只怪兽和自己墓地1只「动力工具」同调怪兽或者7·8星的龙族同调怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：自己场上的7星以上的同调怪兽的攻击力上升自己的除外状态的7星以上的同调怪兽数量×400。
-- ③：1回合1次，自己的除外状态的同调怪兽存在的场合，对方怪兽的攻击宣言时才能发动。那次攻击无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含魔陷发动、①效果（起动效果破坏卡片）、②效果（永续升攻）、③效果（攻击无效）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：把自己场上1只怪兽和自己墓地1只「动力工具」同调怪兽或者7·8星的龙族同调怪兽除外，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ②：自己场上的7星以上的同调怪兽的攻击力上升自己的除外状态的7星以上的同调怪兽数量×400。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置永续效果的影响对象为满足过滤条件（自己场上7星以上的同调怪兽）的怪兽。
	e3:SetTarget(aux.TargetBoolFunction(s.filter))
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己的除外状态的同调怪兽存在的场合，对方怪兽的攻击宣言时才能发动。那次攻击无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.negcon)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
-- 过滤墓地中作为Cost除外的卡：必须是「动力工具」同调怪兽，或者是7·8星的龙族同调怪兽。
function s.cfilter(c)
	return (c:IsSetCard(0xc2) or c:IsLevel(7,8) and c:IsRace(RACE_DRAGON))
		and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ①效果的发动代价（Cost）处理函数：检查并除外自己场上1只怪兽和自己墓地1只满足条件的同调怪兽。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否存在至少1只可以作为Cost除外的怪兽。
		return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,1,nil)
			-- 检查自己墓地是否存在至少1只满足条件的同调怪兽可以作为Cost除外。
			and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	-- 给发动效果的玩家发送提示信息，提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己场上1只可以作为Cost除外的怪兽。
	local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,1,1,nil)
	-- 让玩家选择自己墓地1只满足条件的同调怪兽。
	local g2=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	g1:Merge(g2)
	-- 将选中的卡片（场上的怪兽和墓地的同调怪兽）表侧表示除外作为发动代价。
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
-- ①效果的发动目标（Target）处理函数：检查并选择对方场上1张卡作为对象，并设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为效果对象的目标卡片。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给发动效果的玩家发送提示信息，提示选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为“破坏选中的1张卡”。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的效果处理（Operation）函数：破坏选中的对象卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤场上或除外状态中满足条件的卡：表侧表示的7星以上的同调怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(7)
end
-- 计算攻击力上升值的函数：获取自己除外状态的7星以上同调怪兽数量并乘以400。
function s.val(e,c)
	-- 计算并返回自己除外状态中满足条件的同调怪兽数量乘以400的数值。
	return Duel.GetMatchingGroupCount(s.filter,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)*400
end
-- 过滤除外状态中满足条件的卡：表侧表示的同调怪兽。
function s.negfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_MONSTER)
end
-- ③效果的发动条件（Condition）函数：必须是对方怪兽攻击宣言时，且自己除外状态有同调怪兽存在。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击宣言的怪兽是否由对方控制，且自己除外状态是否存在至少1只同调怪兽。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_REMOVED,0,1,nil)
end
-- ③效果的效果处理（Operation）函数：使那次攻击无效。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前的攻击。
	Duel.NegateAttack()
end
