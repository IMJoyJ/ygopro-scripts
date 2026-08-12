--アロマージ－ローズマリー
-- 效果：
-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己的植物族怪兽攻击的场合，直到伤害步骤结束时对方不能把怪兽的效果发动。
-- ②：1回合1次，自己基本分回复的场合，以场上1只表侧表示怪兽为对象发动。那只怪兽的表示形式变更。
function c58569561.initial_effect(c)
	-- ①：只要自己基本分比对方多并有这张卡在怪兽区域存在，自己的植物族怪兽攻击的场合，直到伤害步骤结束时对方不能把怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c58569561.accon)
	e1:SetValue(c58569561.actlimit)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己基本分回复的场合，以场上1只表侧表示怪兽为对象发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RECOVER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c58569561.poscon)
	e2:SetTarget(c58569561.postg)
	e2:SetOperation(c58569561.posop)
	c:RegisterEffect(e2)
end
-- 判断是否满足效果①的适用条件：自己生命值比对方多，且当前有自己的植物族怪兽进行攻击
function c58569561.accon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取当前进行攻击的怪兽
	local ac=Duel.GetAttacker()
	-- 返回是否满足“自己生命值大于对方，且存在由自己控制的植物族攻击怪兽”的条件
	return Duel.GetLP(tp)>Duel.GetLP(1-tp) and ac and ac:IsControler(tp) and ac:IsRace(RACE_PLANT)
end
-- 限制对方不能发动的卡片效果类型为怪兽的效果
function c58569561.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 判断是否为自己回复了生命值
function c58569561.poscon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 过滤场上表侧表示且可以改变表示形式的怪兽
function c58569561.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 效果②的靶向/目标选择阶段，选择场上1只表侧表示怪兽作为对象，并设置操作信息
function c58569561.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c58569561.filter(chkc) end
	if chk==0 then return true end
	-- 在客户端提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上1只符合过滤条件的表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c58569561.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果②的实际处理阶段，将作为对象的怪兽的表示形式变更
function c58569561.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 改变目标怪兽的表示形式（表侧攻击表示与表侧守备表示互相转换）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
