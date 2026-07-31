--Angelechy Bastion
local s,id,o=GetID()
-- 初始化卡片效果，注册5个效果：起动除外的效果、场上有怪兽不被破坏的永续效果、卡片移动时标记的效果、连锁解决后触发效果、触发放置额外卡组卡片的效果。
function s.initial_effect(c)
	-- 记录该卡记载的卡片代码42410161（通常为另一张卡名）
	aux.AddCodeList(c,42410161)
	-- 设置该卡的同调召唤手续，需要1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，可以除外场上的1张卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- 只要这张卡在魔陷区存在，场上的天使族怪兽不会被效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.indtg)
	-- 设置不会被效果破坏的判定函数
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- 如果这张卡从场上离开
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_MOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetOperation(s.flagop)
	c:RegisterEffect(e3)
	-- 连锁解决后
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(s.raiseop)
	c:RegisterEffect(e4)
	-- 可以从额外卡组将1只天使族怪兽放置到自己的魔陷区作为永续魔法
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_CUSTOM+id)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCountLimit(1,id+o)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.setcon)
	e5:SetTarget(s.settg)
	e5:SetOperation(s.setop)
	c:RegisterEffect(e5)
end
-- 定义过滤器，用于筛选可以除外且在指定列的卡片
function s.rmfilter(c,g)
	return c:IsAbleToRemove() and g:IsContains(c)
end
-- 设置除外效果的目标选择，获取该卡所在列的卡片并让玩家选择要除外的卡
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=c:GetColumnGroup()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.rmfilter(chkc,g) and chkc~=c end
	-- 检测是否存在满足条件的卡片以选择为目标
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,g) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择目标卡
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,g)
	-- 设置操作信息，声明即将执行除外操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外操作，将目标卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 当卡片移动时或连锁结束时，设置标记或触发自定义事件
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) or c:GetType()~=TYPE_SPELL+TYPE_CONTINUOUS then return end
	-- 如果当前有连锁处理，则注册标记
	if Duel.GetCurrentChain()>0 then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	else
		-- 触发自定义事件
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- 连锁解决后，如果标记存在，则触发自定义事件
function s.raiseop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetType()~=TYPE_SPELL+TYPE_CONTINUOUS then return end
	if c:GetFlagEffect(id)~=0 then
		-- 触发自定义事件以启动放置效果
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
-- 条件函数，判断该卡是否为永续魔法
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 定义过滤器，筛选额外卡组中记载的卡且未被禁止放置的卡
function s.setfilter(c)
	return c:IsCode(42410161) and not c:IsForbidden()
end
-- 设置放置效果的目标检测，确认额外卡组有卡且魔陷区有空位
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测额外卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_EXTRA,0,1,nil)
		-- 检测魔陷区是否有空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS end
end
-- 执行放置操作，将额外卡组的卡放置到魔陷区并变为永续魔法
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果魔陷区没有空位则返回
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家选择要放置的卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡移动到魔陷区
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 放置到场上的卡当作永续魔法
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 定义不会被效果破坏的过滤条件，要求是正面表示的天使族怪兽且不是自身
function s.indtg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x1e2) and c~=e:GetHandler()
end
