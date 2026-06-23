--ガードペナルティ
-- 效果：
-- 选择场上1只怪兽。这个回合选择的怪兽变成守备表示的场合，从自己卡组抽1张卡。
function c48653261.initial_effect(c)
	-- 创建效果，设置为发动时点，具有取对象属性，抽卡类别，触发条件为自由连锁
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c48653261.target)
	e1:SetOperation(c48653261.activate)
	c:RegisterEffect(e1)
end
-- 选择场上1只怪兽作为效果对象
function c48653261.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查是否满足选择场上的怪兽作为对象的条件
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只怪兽作为效果对象
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理效果发动后，注册一个持续到结束阶段的效果，用于检测目标怪兽是否变为守备表示
function c48653261.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 创建一个场地区域的永续效果，用于监听表示形式变更事件
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHANGE_POS)
		e1:SetCountLimit(1)
		e1:SetCondition(c48653261.drcon)
		e1:SetOperation(c48653261.drop)
		e1:SetLabel(tc:GetRealFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将该效果注册给玩家，使其生效
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤函数：判断目标怪兽是否为指定ID且当前处于守备表示且之前为攻击表示
function c48653261.filter(c,fid)
	return c:GetRealFieldID()==fid and c:IsDefensePos() and c:IsPreviousPosition(POS_ATTACK)
end
-- 条件函数：检查是否有满足过滤条件的怪兽被触发了表示形式变更事件
function c48653261.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c48653261.filter,1,nil,e:GetLabel())
end
-- 操作函数：当满足条件时，让玩家从卡组抽一张卡
function c48653261.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家从卡组抽一张卡，原因来自效果
	Duel.Draw(tp,1,REASON_EFFECT)
	e:Reset()
end
