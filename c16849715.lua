--雷の天気模様
-- 效果：
-- ①：「雷之天气模样」在自己场上只能有1张表侧表示存在。
-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
-- ●这张卡和对方怪兽进行战斗的伤害步骤开始时，把这张卡除外才能发动。那只对方怪兽回到持有者手卡。
function c16849715.initial_effect(c)
	c:SetUniqueOnField(1,0,16849715)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●这张卡和对方怪兽进行战斗的伤害步骤开始时，把这张卡除外才能发动。那只对方怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16849715,0))  --"对方怪兽回到持有者手卡（雷之天气模样）"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c16849715.retcon)
	-- 指定效果的发动COST：把持有该效果的「天气」效果怪兽自身除外（对应原文“把这张卡除外才能发动”）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c16849715.rettg)
	e2:SetOperation(c16849715.retop)
	-- ②：和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c16849715.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 筛选可被授予效果的怪兽：c必须是我方主要怪兽区（seq<5）的「天气」效果怪兽，且其所在纵列与「雷之天气模样」所在纵列相同或相邻（序号差≤1）。
function c16849715.eftg(e,c)
	local seq=c:GetSequence()
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x109)
		and seq<5 and math.abs(e:GetHandler():GetSequence()-seq)<=1
end
-- e2的发动条件：持有该效果的天气怪兽正在与对方怪兽战斗，且该天气怪兽和战斗对象bc均与本次战斗保持关联（没有离场或解除关联），满足“这张卡和对方怪兽进行战斗的伤害步骤开始时”的时点。
function c16849715.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and c:IsRelateToBattle() and bc:IsRelateToBattle()
end
-- Target函数：chk==0时确认效果可以发动；之后向对方玩家提示本次发动，并将操作信息登记为“把战斗对象（对方怪兽）返回手牌”这一效果类别。
function c16849715.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家（1-tp）发送“对方选择了：...”的提示，显示本次发动的效果描述，告知对方我方发动了“对方怪兽回到持有者手卡”这一个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将当前连锁的操作信息设定为：把e:GetHandler()的战斗对象（1只对方怪兽）返回持有者手牌（CATEGORY_TOHAND），用于其他卡片的连锁响应判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler():GetBattleTarget(),1,0,0)
end
-- 效果处理时，取得与该天气怪兽战斗的对方怪兽bc；若bc仍与本次战斗关联，则执行将其返回持有者手牌的操作。
function c16849715.retop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将战斗对象bc以效果原因（REASON_EFFECT）送回到其持有者手卡，即实现“那只对方怪兽回到持有者手卡”。
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end
