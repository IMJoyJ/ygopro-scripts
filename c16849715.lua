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
	-- 和这张卡相同纵列的自己的主要怪兽区域以及那些两邻的自己的主要怪兽区域存在的「天气」效果怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16849715,0))  --"对方怪兽回到持有者手卡（雷之天气模样）"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c16849715.retcon)
	-- 把这张卡除外才能发动
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c16849715.rettg)
	e2:SetOperation(c16849715.retop)
	-- 使其他卡片获得效果的效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c16849715.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 效果适用的怪兽必须是效果怪兽且属于天气卡组，且所在区域与场地卡的纵列相差不超过1
function c16849715.eftg(e,c)
	local seq=c:GetSequence()
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(0x109)
		and seq<5 and math.abs(e:GetHandler():GetSequence()-seq)<=1
end
-- 战斗开始时，己方怪兽与对方怪兽正在战斗且双方怪兽都存在于战场上
function c16849715.retcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and c:IsRelateToBattle() and bc:IsRelateToBattle()
end
-- 设置连锁操作信息，确定将对方怪兽送回手牌
function c16849715.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息，指定将对方怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler():GetBattleTarget(),1,0,0)
end
-- 将对方怪兽送回持有者手卡
function c16849715.retop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将目标怪兽送回手卡
		Duel.SendtoHand(bc,nil,REASON_EFFECT)
	end
end
