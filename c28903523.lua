--エターナル・サンシャイン
-- 效果：
-- 这个卡名的②的效果在1回合中可以使用最多有自己场上的「古代妖精龙」以及有那个卡名记述的怪兽数量的次数。
-- ①：自己场上的怪兽的守备力上升自己场上的「古代妖精龙」以及有那个卡名记述的怪兽数量×500。
-- ②：以对方场上1只表侧表示怪兽为对象才能发动（同一连锁上最多1次）。那只怪兽直到回合结束时攻击力·守备力变成一半，效果无效化。
local s,id,o=GetID()
-- 注册该卡发动所需的永续魔陷标准空效果（允许在伤害步骤发动）、①的守备力提升场地永续效果、以及②的速攻诱发即时效果（取对象、同连锁限1、卡名②次数限制）
function s.initial_effect(c)
	-- 将古代妖精龙（25862681）登记为本卡效果文本中记载的卡名，供后续判断‘有那个卡名记述的怪兽’使用。
	aux.AddCodeList(c,25862681)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	c:RegisterEffect(e1)
	-- 对应①效果：只要这张卡在魔法与陷阱区域存在，自己场上的怪兽的守备力上升自己场上的「古代妖精龙」以及有那个卡名记述的怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	-- 对应②效果：以对方场上1只表侧表示怪兽为对象才能发动（同一连锁上最多1次），那只怪兽直到回合结束时攻击力·守备力变成一半，效果无效化；此处设置其作为快速效果的属性、取对象、伤害步骤可发、同一连锁限1等。
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
-- 定义atkfilter过滤条件：表侧表示且是「古代妖精龙」本身，或是卡名记述了「古代妖精龙」的怪兽。
function s.atkfilter(c)
	-- 具体的过滤逻辑：表侧表示，并且（卡号是25862681，或者卡名记述了25862681且是怪兽卡）。
	return c:IsFaceup() and (c:IsCode(25862681) or aux.IsCodeListed(c,25862681) and c:IsType(TYPE_MONSTER))
end
-- 定义永续效果的数值函数s.val：统计符合条件的己方场上怪兽数量并乘以500，作为守备力上升值。
function s.val(e,c)
	-- 统计自己场上表侧表示的「古代妖精龙」以及卡名记述了「古代妖精龙」的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(s.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)
	return ct*500
end
-- 定义②的取对象过滤器：只选择对方场上表侧表示怪兽。
function s.disfilter(c)
	return c:IsFaceup()
end
-- ②的发动条件与发动时处理：计算可发动次数，若指定对象则进行对象合法性判断，若为发动检查则确认存在表侧表示对象且本回合已发动次数未达到上限。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计己方场上符合条件的怪兽数量，作为本卡名②效果每回合可用次数上限。
	local ct=Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_ONFIELD,0,nil)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc) end
	-- 发动条件检查：对方场上有表侧表示怪兽可以成为对象。
	if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 并且本回合已经发动的次数（通过FlagEffect记录）小于ct，满足‘1回合可以使用最多有自己场上的……数量的次数’的限制。
		and Duel.GetFlagEffect(tp,id)<ct end
	-- 发动时给己方玩家注册一个标识，用于累计本回合这个卡名的②效果发动次数，并在回合结束时重置。
	Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	-- 显示选择提示，让玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从对方场上选择1只表侧表示怪兽作为效果对象，同时将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次处理包含无效效果（CATEGORY_DISABLE），对象为选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ②的效果处理：获取对象后，若对象仍表侧表示且与效果关联，则将其攻击力变为原攻击力的一半，守备力变为原守备力的一半，并使其效果无效化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 对应‘攻击力变成一半’：将对象怪兽的攻击力暂时改为当前攻击力除以2（向上取整），直到回合结束时适用。
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
		-- 使对象怪兽场上发动的效果连锁以及相关效果连锁无效化（对应效果无效化的处理方式之一，防止其效果继续适用）。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对应‘效果无效化’：为对象怪兽附加效果无效（EFFECT_DISABLE），使其作为卡的效果无效，直到回合结束时。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		-- 对应‘效果无效化’的补充处理：使对象怪兽的所有效果无效化（EFFECT_DISABLE_EFFECT），效果持续到回合结束时。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetValue(RESET_TURN_SET)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
	end
end
