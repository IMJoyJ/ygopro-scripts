--反逆の罪宝－スネークアイ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 创建效果对象并设置其描述、类型、时点、发动限制、对象属性和处理函数
function s.initial_effect(c)
	-- ①：以场上1只表侧表示怪兽为对象才能发动。那只怪兽当作永续魔法卡使用在原本持有者的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断目标怪兽是否满足成为对象的条件（包括是否表侧表示、是否能移动到魔法区域等）
function s.filter(c,tp,ft)
	if c:IsFacedown() then return false end
	local p=c:GetOwner()
	if p~=tp then ft=0 end
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(p) then
		if not c:IsAbleToChangeControler() then return false end
		r=LOCATION_REASON_CONTROL
	end
	-- 判断目标怪兽是否满足移动到魔法区域的条件
	return Duel.GetLocationCount(p,LOCATION_SZONE,tp,r)>ft
end
-- 处理效果的发动目标选择阶段，判断是否满足发动条件并选择目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp,0) end
	if chk==0 then
		local ft=e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND) and 1 or 0
		-- 判断是否存在满足条件的目标怪兽
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,ft)
	end
	-- 向玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽作为效果的对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,0)
end
-- 处理效果的发动执行阶段，将目标怪兽移动到魔法区域并改变其类型
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)
		-- 将目标怪兽移动到魔法区域并设置其为表侧表示
		and Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,true) then
		-- 那只怪兽当作永续魔法卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
