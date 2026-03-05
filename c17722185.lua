--インヴィンシブル・ヘイロー
-- 效果：
-- ①：1回合1次，把自己场上1只表侧表示的仪式·融合·同调·超量·灵摆·连接怪兽除外才能发动。这个回合，这张卡在魔法与陷阱区域存在期间，和除外的怪兽相同种类（仪式·融合·同调·超量·灵摆·连接）的怪兽的效果无效化。
function c17722185.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，把自己场上1只表侧表示的仪式·融合·同调·超量·灵摆·连接怪兽除外才能发动。这个回合，这张卡在魔法与陷阱区域存在期间，和除外的怪兽相同种类（仪式·融合·同调·超量·灵摆·连接）的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	e2:SetCost(c17722185.cost)
	e2:SetOperation(c17722185.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查场上是否存在满足条件的怪兽（正面表示、类型为仪式/融合/同调/超量/灵摆/连接、可以作为除外的代价）
function c17722185.cfilter(c)
	return c:IsFaceup() and c:IsType(0x58020C0) and c:IsAbleToRemoveAsCost()
end
-- 效果的发动费用处理，检查场上是否存在满足条件的怪兽并选择除外，同时记录除外怪兽的类型标记
function c17722185.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即场上存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17722185.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只符合条件的怪兽并获取该怪兽对象
	local tc=Duel.SelectMatchingCard(tp,c17722185.cfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	-- 将选中的怪兽以正面表示形式除外作为发动代价
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	local flag=0
	if tc:IsType(TYPE_RITUAL) then flag=bit.bor(flag,TYPE_RITUAL) end
	if tc:IsType(TYPE_FUSION) then flag=bit.bor(flag,TYPE_FUSION) end
	if tc:IsType(TYPE_SYNCHRO) then flag=bit.bor(flag,TYPE_SYNCHRO) end
	if tc:IsType(TYPE_XYZ) then flag=bit.bor(flag,TYPE_XYZ) end
	if tc:IsType(TYPE_PENDULUM) then flag=bit.bor(flag,TYPE_PENDULUM) end
	if tc:IsType(TYPE_LINK) then flag=bit.bor(flag,TYPE_LINK) end
	e:SetLabel(flag)
end
-- 效果发动后的处理，注册一个永续效果使相同种类的怪兽效果无效
function c17722185.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(17722185,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	local flag=e:GetLabel()
	-- 创建一个使怪兽效果无效的永续效果，该效果在结束阶段重置
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c17722185.distg)
	e1:SetCondition(c17722185.discon)
	e1:SetLabel(flag)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的效果注册到游戏环境，使该效果生效
	Duel.RegisterEffect(e1,tp)
end
-- 目标过滤函数，判断目标怪兽是否为指定类型的怪兽
function c17722185.distg(e,c)
	return c:IsType(e:GetLabel())
end
-- 条件函数，判断当前卡是否处于有效期内（即是否还在魔法与陷阱区域）
function c17722185.discon(e)
	return e:GetHandler():GetFlagEffect(17722185)~=0
end
