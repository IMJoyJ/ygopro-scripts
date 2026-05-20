--フォース・リリース
-- 效果：
-- 这张卡的发动时自己场上表侧表示存在的全部二重怪兽变成再度召唤的状态。这个效果适用的怪兽在结束阶段时变成里侧守备表示。
function c73567374.initial_effect(c)
	-- 这张卡的发动时自己场上表侧表示存在的全部二重怪兽变成再度召唤的状态。这个效果适用的怪兽在结束阶段时变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c73567374.target)
	e1:SetOperation(c73567374.operation)
	c:RegisterEffect(e1)
end
c73567374.has_text_type=TYPE_DUAL
-- 过滤条件：自己场上表侧表示且未处于再度召唤状态的二重怪兽
function c73567374.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and not c:IsDualState()
end
-- 效果发动时的目标选择与确认：检查并获取自己场上所有未再度召唤的表侧表示二重怪兽，并将其设为效果处理的对象
function c73567374.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只未再度召唤的表侧表示二重怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73567374.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有未再度召唤的表侧表示二重怪兽
	local g=Duel.GetMatchingGroup(c73567374.filter,tp,LOCATION_MZONE,0,nil)
	-- 将这些怪兽设为当前效果的处理对象
	Duel.SetTargetCard(g)
end
-- 过滤条件：在效果处理时仍表侧表示存在、是二重怪兽、未处于再度召唤状态、与效果有关联且不受效果免疫的怪兽
function c73567374.filter2(c,e)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and not c:IsDualState() and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
-- 效果处理：使符合条件的二重怪兽变成再度召唤状态，并注册一个在结束阶段将这些怪兽变成里侧守备表示的延迟效果
function c73567374.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在效果处理时仍符合条件且与该效果有关联的怪兽组
	local g=Duel.GetMatchingGroup(c73567374.filter2,tp,LOCATION_MZONE,0,nil,e)
	local tc=g:GetFirst()
	local fid=c:GetFieldID()
	while tc do
		tc:EnableDualState()
		tc:RegisterFlagEffect(73567374,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		tc=g:GetNext()
	end
	g:KeepAlive()
	-- 这个效果适用的怪兽在结束阶段时变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(fid)
	e2:SetLabelObject(g)
	e2:SetCondition(c73567374.flipcon)
	e2:SetOperation(c73567374.flipop)
	-- 在全局环境中注册该延迟效果，由发动该卡片的玩家在结束阶段时执行
	Duel.RegisterEffect(e2,tp)
end
-- 过滤条件：检查怪兽是否带有与本次效果对应的标记（FieldID）
function c73567374.flipfilter(c,fid)
	return c:GetFlagEffectLabel(73567374)==fid
end
-- 结束阶段效果的发动条件：检查被标记的怪兽组中是否仍有怪兽存在，若无则清理怪兽组并重置该效果
function c73567374.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c73567374.flipfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段效果的具体操作：筛选出仍带有对应标记的怪兽，将其变成里侧守备表示，并清理怪兽组
function c73567374.flipop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local dg=g:Filter(c73567374.flipfilter,nil,e:GetLabel())
	g:DeleteGroup()
	-- 将筛选出的适用怪兽全部变成里侧守备表示
	Duel.ChangePosition(dg,POS_FACEDOWN_DEFENSE)
end
