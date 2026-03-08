--トゥーン・ディフェンス
-- 效果：
-- ①：对方怪兽向自己的4星以下的卡通怪兽攻击宣言时才能把这个效果发动。那只对方怪兽的攻击变成对自己的直接攻击。
function c43509019.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方怪兽向自己的4星以下的卡通怪兽攻击宣言时才能把这个效果发动。那只对方怪兽的攻击变成对自己的直接攻击。
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
-- 检查攻击目标是否为表侧表示、等级4以下、卡通类型且为效果持有者控制者
function c43509019.cbcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言时的攻击对象
	local bt=Duel.GetAttackTarget()
	return bt and bt:IsFaceup() and bt:IsLevelBelow(4) and bt:IsType(TYPE_TOON) and bt:GetControler()==e:GetHandlerPlayer()
end
-- 判断攻击怪兽是否能进行直接攻击
function c43509019.cbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查攻击怪兽是否受到‘不能直接攻击’效果影响
	if chk==0 then return not Duel.GetAttacker():IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK) end
end
-- 将攻击对象变为直接攻击
function c43509019.cbop(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前攻击对象设置为直接攻击（即对自己攻击）
	Duel.ChangeAttackTarget(nil)
end
