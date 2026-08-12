--エターナル・サンシャイン
-- 效果：
-- 这个卡名的②的效果在1回合中可以使用最多有自己场上的「古代妖精龙」以及有那个卡名记述的怪兽数量的次数。
-- ①：自己场上的怪兽的守备力上升自己场上的「古代妖精龙」以及有那个卡名记述的怪兽数量×500。
-- ②：以对方场上1只表侧表示怪兽为对象才能发动（同一连锁上最多1次）。那只怪兽直到回合结束时攻击力·守备力变成一半，效果无效化。
local s,id,o=GetID()
-- 初始化效果函数，注册场地魔法卡的激活、守备力提升和无效化效果
function s.initial_effect(c)
	-- 记录该卡效果文本中记载了25862681（古代妖精龙）这张卡
	aux.AddCodeList(c,25862681)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	c:RegisterEffect(e1)
	-- 自己场上的怪兽的守备力上升自己场上的「古代妖精龙」以及有那个卡名记述的怪兽数量×500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	-- 以对方场上1只表侧表示怪兽为对象才能发动（同一连锁上最多1次）。那只怪兽直到回合结束时攻击力·守备力变成一半，效果无效化
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为表侧表示的古代妖精龙或记载有古代妖精龙的怪兽
function s.atkfilter(c)
	-- 判断怪兽是否为表侧表示且为古代妖精龙或记载有古代妖精龙
	return c:IsFaceup() and (c:IsCode(25862681) or aux.IsCodeListed(c,25862681) and c:IsType(TYPE_MONSTER))
end
-- 守备力提升效果的计算函数，根据场上古代妖精龙及记载其名的怪兽数量计算提升值
function s.val(e,c)
	-- 获取场上满足条件的古代妖精龙或记载其名的怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)
	return ct*500
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示
function s.disfilter(c)
	return c:IsFaceup()
end
-- 无效化效果的目标选择函数，检查是否满足发动条件并注册标志效果
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取场上满足条件的古代妖精龙或记载其名的怪兽数量
	local ct=Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_ONFIELD,0,nil)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc) end
	-- 检查是否存在满足条件的对方怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查该卡在本回合中是否已使用次数未达到上限
		and Duel.GetFlagEffect(tp,id)<ct end
	-- 注册一个标志效果，用于记录该卡在本回合中已使用的次数
	Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	-- 提示玩家选择一张表侧表示的对方怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一张表侧表示的对方怪兽作为目标
	local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，表明将要使目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 无效化效果的处理函数，对目标怪兽进行攻击力、守备力减半并使其效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 将目标怪兽的攻击力减半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(math.ceil(tc:GetDefense()/2))
		tc:RegisterEffect(e2)
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽的效果无效
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		-- 使目标怪兽的效果在回合结束时无效化
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetValue(RESET_TURN_SET)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
	end
end
