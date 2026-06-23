--影の災い
-- 效果：
-- ①：以对方场上1张表侧表示卡为对象才能发动。卡名和那张卡相同的对方墓地的卡数量的以下效果适用。
-- ●1张：作为对象的卡破坏。
-- ●2张：作为对象的卡除外。
-- ●3张以上：作为对象的卡以及那些同名卡从对方的场上·墓地全部里侧除外。
local s,id,o=GetID()
-- 创建并注册影之灾厄的发动效果，设置其为自由连锁、取对象、破坏、除外、墓地动作类别
function s.initial_effect(c)
	-- ①：以对方场上1张表侧表示卡为对象才能发动。卡名和那张卡相同的对方墓地的卡数量的以下效果适用。
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
-- 定义用于筛选同名卡的过滤函数，要求卡片为正面表示且能被除外
function s.rmfdfilter(c,code,tp)
	return c:IsCode(code) and c:IsFaceupEx() and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 定义用于筛选目标卡的过滤函数，根据目标卡在墓地中的同名卡数量决定是否可以成为效果对象
function s.rmfilter(c,tp)
	if not c:IsFaceup() then return false end
	-- 获取目标卡卡号在对方墓地中出现的次数
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_GRAVE,nil,c:GetCode())
	local ct=g:GetCount()
	if ct==0 then return false end
	if ct==1 then return true end
	if ct==2 then return c:IsAbleToRemove() end
	-- 当同名卡数量大于2时，检查对方场上或墓地中是否存在同名卡
	if ct>2 then return Duel.IsExistingMatchingCard(s.rmfdfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,c:GetCode(),tp) end
	return false
end
-- 设置效果的目标选择函数，选择对方场上的正面表示卡作为对象，并根据对象卡在墓地中的同名卡数量设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and s.rmfilter(chkc,tp) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的对方场上正面表示卡作为对象
	local sg=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil,tp)
	local sc=sg:GetFirst()
	if sc then
		-- 获取对象卡卡号在对方墓地中出现的次数
		local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,0,LOCATION_GRAVE,nil,sc:GetCode())
		if ct==1 then
			-- 设置操作信息为破坏对象卡
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
		elseif ct==2 then
			-- 设置操作信息为除外对象卡
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,1,0,0)
		elseif ct>2 then
			-- 获取对方场上或墓地中所有同名卡的集合
			local rg=Duel.GetMatchingGroup(s.rmfdfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,sc:GetCode(),tp)
			-- 设置操作信息为将所有同名卡除外
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,#rg,0,0)
		end
	end
end
-- 设置效果的发动处理函数，根据对象卡在墓地中的同名卡数量执行对应效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 获取对象卡卡号在对方墓地中出现的次数
		local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,0,LOCATION_GRAVE,nil,tc:GetCode())
		if ct==1 then
			-- 将对象卡破坏
			Duel.Destroy(tc,REASON_EFFECT)
		elseif ct==2 then
			-- 将对象卡除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		elseif ct>2 then
			-- 获取对方场上或墓地中所有同名卡的集合
			local rg=Duel.GetMatchingGroup(s.rmfdfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,tc:GetCode(),tp)
			-- 将所有同名卡除外
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
