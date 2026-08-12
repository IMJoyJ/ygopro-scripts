--デーモンの光来
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上有「光之黄金柜」存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果的发动时自己场上没有「光之黄金柜」存在的场合，这个效果得到控制权的怪兽不能攻击。
-- ③：自己场上的其他怪兽的攻击力在自己回合内上升500。
local s,id,o=GetID()
-- 初始化卡片效果，注册召唤条件、控制权变更和攻击力提升效果
function s.initial_effect(c)
	-- 记录该卡与「光之黄金柜」的关联
	aux.AddCodeList(c,79791878)
	-- 设置①效果：自己场上有「光之黄金柜」存在时可不用解放作召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- 设置②效果：召唤成功时可以将对方怪兽的控制权转移给自己的效果，且该效果1回合只能发动1次
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"得到控制权"
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 设置③效果：自己场上的其他怪兽在自己回合内攻击力上升500
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.atkcon)
	e4:SetTarget(s.atktg)
	e4:SetValue(500)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在「光之黄金柜」
function s.ntfilter(c)
	return c:IsFaceup() and c:IsCode(79791878)
end
-- 召唤条件函数，判断是否满足不需解放的召唤条件
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断召唤时是否满足等级要求和场地空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断自己场上是否存在「光之黄金柜」
		and Duel.IsExistingMatchingCard(s.ntfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil)
end
-- 控制权变更效果的目标选择函数，用于选择对方场上的怪兽
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	-- 检查是否有满足条件的对方怪兽可被改变控制权
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上一只可以改变控制权的怪兽作为目标
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表明将要改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 判断自己场上是否存在「光之黄金柜」以决定是否禁止攻击
	if Duel.IsExistingMatchingCard(s.ntfilter,tp,LOCATION_ONFIELD,0,1,nil) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 控制权变更效果的处理函数，执行控制权转移并根据条件禁止攻击
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍然在场且成功获得控制权
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)~=0
		and e:GetLabel()~=1 then
		-- 创建禁止目标怪兽攻击的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否为己方回合的条件函数
function s.atkcon(e)
	-- 返回当前回合玩家是否为该卡持有者
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 攻击力提升效果的目标过滤函数，排除自身
function s.atktg(e,c)
	return c~=e:GetHandler()
end
