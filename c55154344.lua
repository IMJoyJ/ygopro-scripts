--登竜華幻朧門
-- 效果：
-- ①：「登龙华幻胧门」在自己场上只能有1张表侧表示存在。
-- ②：只要这张卡在魔法与陷阱区域存在，对方回合从双方场上送去墓地的怪兽不去墓地而除外。
-- ③：自己场上的「龙华」灵摆怪兽以及10星以上而原本种族是幻龙族的怪兽得到以下效果。
-- ●对方回合1次，让自己场上1张表侧表示的「龙华」永续魔法卡回到卡组最下面，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
local s,id,o=GetID()
-- 初始化卡片效果，注册场上唯一存在限制、发动效果、送墓除外效果、赋予其他怪兽效果以及改变怪兽种类的效果
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，对方回合从双方场上送去墓地的怪兽不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtarget)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	-- ●对方回合1次，让自己场上1张表侧表示的「龙华」永续魔法卡回到卡组最下面，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"改变怪兽攻击力（「登龙华幻胧门」）"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atkcon)
	e3:SetCost(s.atkcost)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	-- ③：自己场上的「龙华」灵摆怪兽以及10星以上而原本种族是幻龙族的怪兽得到以下效果。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- ③：自己场上的「龙华」灵摆怪兽以及10星以上而原本种族是幻龙族的怪兽得到以下效果。
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
-- 判断是否为对方回合，作为送墓除外效果的适用条件
function s.rmcon(e)
	local tp=e:GetHandlerPlayer()
	-- 判断当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤出从双方场上送去墓地的怪兽卡，作为送墓除外效果的适用对象
function s.rmtarget(e,c)
	return c:IsLocation(LOCATION_MZONE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 判断是否为对方回合，作为赋予效果的发动条件
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤自己场上表侧表示的「龙华」永续魔法卡，作为发动赋予效果的Cost
function s.costfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1c0) and c:IsAbleToDeckAsCost()
		and bit.band(c:GetType(),TYPE_SPELL+TYPE_CONTINUOUS)==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 执行赋予效果的发动代价，即让自己场上1张表侧表示的「龙华」永续魔法卡回到卡组最下面
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动效果时，检查自己场上是否存在至少1张满足条件的「龙华」永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己场上1张表侧表示的「龙华」永续魔法卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 为选择的卡片显示被选为对象的动画效果
	Duel.HintSelection(g)
	-- 将选择的卡作为Cost送回持有者卡组最下面
	Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_COST)
end
-- 赋予效果的靶向处理，确认场上是否存在攻击力不为0的表侧表示怪兽并将其选择为效果对象
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在效果处理时，检查已选择的对象是否仍在怪兽区且攻击力不为0
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.nzatk(chkc) end
	-- 在发动效果时，检查场上是否存在至少1只攻击力不为0的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只攻击力不为0的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,aux.nzatk,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 赋予效果的运行处理，使作为对象的怪兽攻击力变成0
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤自己场上的「龙华」灵摆怪兽以及10星以上且原本种族是幻龙族的怪兽，作为赋予效果的对象
function s.eftg(e,c)
	return c:IsLevelAbove(10) and c:GetOriginalRace()==RACE_WYRM
		or c:IsSetCard(0x1c0) and c:IsType(TYPE_PENDULUM)
end
