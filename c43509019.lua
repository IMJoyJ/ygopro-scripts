--トゥーン・ディフェンス
-- 效果：
-- ①：对方怪兽向自己的4星以下的卡通怪兽攻击宣言时才能把这个效果发动。那只对方怪兽的攻击变成对自己的直接攻击。
function c43509019.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 对应效果原文：①：对方怪兽向自己的4星以下的卡通怪兽攻击宣言时才能把这个效果发动。那只对方怪兽的攻击变成对自己的直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43509019,0))  --"改变攻击对象"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c43509019.cbcon)
	e2:SetTarget(c43509019.cbtg)
	e2:SetOperation(c43509019.cbop)
	c:RegisterEffect(e2)
end
-- 效果发动条件判断：确认当前被攻击的怪兽存在，且是己方场上表侧表示、等级4以下、持有卡通类型的怪兽，满足这些条件时本效果才能发动。
function c43509019.cbcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击的怪兽对象，用于后续判断其是否满足卡通怪兽、等级等条件。
	local bt=Duel.GetAttackTarget()
	return bt and bt:IsFaceup() and bt:IsLevelBelow(4) and bt:IsType(TYPE_TOON) and bt:GetControler()==e:GetHandlerPlayer()
end
-- 目标合法性与可发动性检查：在效果发动时确认攻击怪兽不具有“不能直接攻击”的效果，从而保证将攻击对象改为直接攻击是可行的；若攻击怪兽不能直接攻击，则本效果不能发动。
function c43509019.cbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时点（chk==0）判断攻击怪兽是否没有“不能直接攻击”的效果，若有该效果则返回false阻止本次发动。
	if chk==0 then return not Duel.GetAttacker():IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK) end
end
-- 效果处理阶段的操作：把当前攻击对象更改为直接攻击，实现“对方怪兽的攻击变成对自己的直接攻击”。
function c43509019.cbop(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.ChangeAttackTarget(nil)将攻击目标设为nil，即让攻击怪兽改为对控制者直接攻击。
	Duel.ChangeAttackTarget(nil)
end
