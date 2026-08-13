--EXTINGUISH！
-- 效果：
-- 这个卡名在规则上也当作「救援ACE队」卡使用。
-- ①：自己场上有「救援ACE队」怪兽存在的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽破坏。自己场上有「救援ACE队 消防栓」存在的场合，再在这个回合让对方不能把这个效果破坏的怪兽以及原本卡名和那只怪兽相同的怪兽的效果发动。
local s,id,o=GetID()
-- 创建并注册本卡的发动效果：设置效果分类为破坏、类型为发动（魔法卡发动）、自由时点发动、取对象，并绑定发动条件、发动时选对象、效果处理三个函数。
function s.initial_effect(c)
	-- ①：自己场上有「救援ACE队」怪兽存在的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽破坏。自己场上有「救援ACE队 消防栓」存在的场合，再在这个回合让对方不能把这个效果破坏的怪兽以及原本卡名和那只怪兽相同的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- s.cfilter：判定怪兽是否表侧表示且属于「救援ACE队」系列（SetCard 0x18b），用于检索自己场上的救援ACE队怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x18b)
end
-- s.condition：发动条件——自己场上存在至少1只表侧表示的「救援ACE队」怪兽时才可发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.IsExistingMatchingCard检查自己主要怪兽区是否存在1只满足s.cfilter的怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- s.mfilter：判定对方场上怪兽是否为表侧表示的效果怪兽，用于选择取对象目标。
function s.mfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 发动时选择目标的流程：先处理连锁对象合法性；若为发动确认（chk==0）则检查是否存在可选的表侧效果怪兽；然后给出选择提示，由玩家选择对方场上的1只表侧效果怪兽，并设置操作信息为破坏。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.mfilter(chkc) end
	-- 发动时点检查是否存在满足条件的对象（对方场上表侧效果怪兽），存在则效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(s.mfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家弹出选择提示，提示信息为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 调用SelectTarget让玩家从对方场上选择1只表侧效果怪兽，并将其设为这张卡效果的对象。
	local g=Duel.SelectTarget(tp,s.mfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 记录本次连锁操作将破坏的对象g及数量1，以便后续诱发相关效果（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- s.checkfilter：判定场上是否存在表侧表示的「救援ACE队 消防栓」（卡号37617348），用于决定是否追加封锁效果。
function s.checkfilter(c)
	return c:IsCode(37617348) and c:IsFaceup()
end
-- 效果处理：取出效果持有者和对象；检查自己场上是否有「救援ACE队 消防栓」；若对象仍关联此效果则先破坏对象；若破坏成功且场上有消防栓，则中断连锁创建封锁效果，使对方本回合不能发动被破坏怪兽及其同名怪兽的怪兽效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中这张卡选择的对象（对方场上1只表侧效果怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查自己场上（主要怪兽区和魔法陷阱区）是否存在表侧表示的「救援ACE队 消防栓」。
	local check=Duel.IsExistingMatchingCard(s.checkfilter,tp,LOCATION_ONFIELD,0,1,nil)
	if tc:IsRelateToEffect(e) then
		-- 如果对象被效果成功破坏（返回破坏数非0），且自己场上有「救援ACE队 消防栓」，则执行后续追加效果。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and check then
			-- 调用BreakEffect使后续追加处理作为独立时点，避免错过时点。
			Duel.BreakEffect()
			-- 自己场上有「救援ACE队 消防栓」存在的场合，再在这个回合让对方不能把这个效果破坏的怪兽以及原本卡名和那只怪兽相同的怪兽的效果发动。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(0,1)
			e1:SetValue(s.aclimit)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将上述封锁效果e1以tp玩家的身份注册到全局环境中，持续到本回合结束阶段。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- s.aclimit：封锁判定条件——对方发动的效果必须是怪兽效果，且发动卡的原本卡名与被破坏对象tc的原本卡名相同，满足则禁止发动。
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	local tc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
