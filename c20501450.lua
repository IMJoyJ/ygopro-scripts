--コンセントレイト
-- 效果：
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那个守备力数值。这张卡发动的回合，作为对象的怪兽以外的自己怪兽不能攻击。
function c20501450.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升那个守备力数值。这张卡发动的回合，作为对象的怪兽以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c20501450.cost)
	e1:SetTarget(c20501450.target)
	e1:SetOperation(c20501450.activate)
	c:RegisterEffect(e1)
	if not c20501450.global_check then
		c20501450.global_check=true
		c20501450[0]=0
		c20501450[1]=0
		-- 攻击宣言时，记录攻击怪兽的flag
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c20501450.checkop)
		-- 将效果注册给全局环境
		Duel.RegisterEffect(ge1,0)
		-- 抽卡阶段开始时，重置全局变量
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c20501450.clear)
		-- 将效果注册给全局环境
		Duel.RegisterEffect(ge2,0)
	end
end
-- 记录攻击怪兽的flag，防止重复计算
function c20501450.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:GetFlagEffect(20501450)==0 then
		c20501450[ep]=c20501450[ep]+1
		tc:RegisterFlagEffect(20501450,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 重置全局变量，用于回合结束时清空记录
function c20501450.clear(e,tp,eg,ep,ev,re,r,rp)
	c20501450[0]=0
	c20501450[1]=0
end
-- 检查是否已发动过效果，防止重复发动
function c20501450.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return c20501450[tp]<2 end
end
-- 筛选满足条件的表侧表示怪兽，即守备力大于等于1且未被标记
function c20501450.filter(c,tp)
	return c:IsFaceup() and c:IsDefenseAbove(1) and (c20501450[tp]==0 or c:GetFlagEffect(20501450)~=0)
end
-- 选择满足条件的怪兽作为效果对象
function c20501450.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and c20501450.filter(chkc,tp) end
	-- 判断是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c20501450.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c20501450.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 创建不能攻击的效果，限制除目标怪兽外的其他怪兽攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c20501450.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能攻击效果的目标条件，排除目标怪兽
function c20501450.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 使目标怪兽的攻击力上升其守备力数值
function c20501450.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建攻击力变更效果，使目标怪兽攻击力上升其守备力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetDefense())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
