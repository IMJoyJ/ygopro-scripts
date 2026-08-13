--影の災い
-- 效果：
-- ①：以对方场上1张表侧表示卡为对象才能发动。卡名和那张卡相同的对方墓地的卡数量的以下效果适用。
-- ●1张：作为对象的卡破坏。
-- ●2张：作为对象的卡除外。
-- ●3张以上：作为对象的卡以及那些同名卡从对方的场上·墓地全部里侧除外。
local s,id,o=GetID()
-- 定义『影之灾厄』的初始化函数，创建并注册其①效果：设置效果类别为破坏/除外/涉及墓地移动，类型为魔法卡发动，取对象属性，自由时点发动，设定提示时点，并绑定目标选择与效果处理函数。
function s.initial_effect(c)
	-- ①：以对方场上1张表侧表示卡为对象才能发动。卡名和那张卡相同的对方墓地的卡数量的以下效果适用。●1张：作为对象的卡破坏。●2张：作为对象的卡除外。●3张以上：作为对象的卡以及那些同名卡从对方的场上·墓地全部里侧除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_REMOVE|CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤器s.rmfdfilter，用于筛选“里侧除外”的候选卡：要求卡名与指定卡一致、处于表侧表示（或公开状态）且能够被玩家tp以里侧表示除外。
function s.rmfdfilter(c,code,tp)
	return c:IsCode(code) and c:IsFaceupEx() and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 定义过滤器s.rmfilter，判断一张表侧表示卡能否成为此效果的对象：根据对方墓地中与该卡同名的卡数量决定——0张不可选；1张可选；2张还需该卡自身能被除外；3张以上还需场上或墓地存在至少1张可里侧除外的同名卡。
function s.rmfilter(c,tp)
	if not c:IsFaceup() then return false end
	-- 获取对方墓地中与指定卡同名的所有卡并组成组，用于统计数量。
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_GRAVE,nil,c:GetCode())
	local ct=g:GetCount()
	if ct==0 then return false end
	if ct==1 then return true end
	if ct==2 then return c:IsAbleToRemove() end
	-- 当同名卡数量大于2时，额外检查对方场上或墓地是否存在至少1张可被里侧除外的同名卡，以保证后续能执行“全部里侧除外”的处理。
	if ct>2 then return Duel.IsExistingMatchingCard(s.rmfdfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,c:GetCode(),tp) end
	return false
end
-- 目标选择函数：处理取对象选择。若为连锁确认则校验对象合法性；若为发动确认则检查是否存在合法目标；确定发动后提示玩家选择对象，选择1张对方场上表侧表示且满足条件的卡，并根据对象在对方墓地的同名卡数量设置对应的操作信息（破坏/除外/里侧除外及目标）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.rmfilter(chkc,tp) end
	-- 发动合法性检查：效果发动时确认对方场上是否存在至少1张满足s.rmfilter条件且可作为对象的表侧表示卡。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	-- 弹出系统选择提示，告知玩家“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家从对方场上选择1张满足条件的表侧表示卡作为效果对象，并通过Duel.SelectTarget自动将其与当前连锁建立关联。
	local sg=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	local sc=sg:GetFirst()
	if sc then
		-- 计算所选对象在对方墓地中的同名卡数量，用于决定适用哪个分支效果。
		local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,0,LOCATION_GRAVE,nil,sc:GetCode())
		if ct==1 then
			-- 同名卡数量为1时，设置操作信息为“破坏”，目标为所选对象。
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
		elseif ct==2 then
			-- 同名卡数量为2时，设置操作信息为“除外”，目标为所选对象（以正面表示除外）。
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,1,0,0)
		elseif ct>2 then
			-- 同名卡数量大于2时，获取对方场上及墓地中所有满足里侧除外条件的同名卡，组成处理组。
			local rg=Duel.GetMatchingGroup(s.rmfdfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,sc:GetCode(),tp)
			-- 设置操作信息为“除外”，目标为rg，数量为rg中的卡片数，表示要将这些卡全部里侧除外。
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,#rg,0,0)
		end
	end
end
-- 效果处理函数：取得效果对象，若对象仍表侧表示且与效果关联，则根据对方墓地中同名卡数量执行对应处理——1张时破坏；2张时正面除外；3张以上时，将对方场上·墓地中所有符合条件的同名卡里侧除外。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中效果选择的唯一对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 再次计算对象卡在对方墓地中的同名卡数量，用于决定处理分支。
		local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,0,LOCATION_GRAVE,nil,tc:GetCode())
		if ct==1 then
			-- 同名卡数量为1时，将对象卡破坏（送入墓地）。
			Duel.Destroy(tc,REASON_EFFECT)
		elseif ct==2 then
			-- 同名卡数量为2时，将对象卡正面表示除外。
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		elseif ct>2 then
			-- 同名卡数量大于2时，获取对方场上及墓地中所有可里侧除外的同名卡（含对象卡自身）组成处理组。
			local rg=Duel.GetMatchingGroup(s.rmfdfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,tc:GetCode(),tp)
			-- 将rg中的所有卡以里侧表示除外。
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
