--ゴーストリックの妖精
-- 效果：
-- 自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转时，以自己墓地1张「鬼计」卡为对象才能发动。那张卡在自己场上盖放。那张卡从场上离开的场合除外。那之后，可以选最多有自己场上盖放的卡数量的对方场上的表侧表示怪兽变成里侧守备表示。
function c36239585.initial_effect(c)
	-- 效果原文：自己场上有「鬼计」怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c36239585.sumcon)
	c:RegisterEffect(e1)
	-- 效果原文：①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36239585,0))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c36239585.postg)
	e2:SetOperation(c36239585.posop)
	c:RegisterEffect(e2)
	-- 效果原文：②：这张卡反转时，以自己墓地1张「鬼计」卡为对象才能发动。那张卡在自己场上盖放。那张卡从场上离开的场合除外。那之后，可以选最多有自己场上盖放的卡数量的对方场上的表侧表示怪兽变成里侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36239585,1))
	e3:SetCategory(CATEGORY_MSET+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_FLIP)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c36239585.settg)
	e3:SetOperation(c36239585.setop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「鬼计」怪兽
function c36239585.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 判断自己场上是否存在「鬼计」怪兽
function c36239585.sumcon(e)
	-- 判断自己场上是否存在「鬼计」怪兽
	return not Duel.IsExistingMatchingCard(c36239585.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 判断是否可以将此卡变为里侧守备表示且该效果在本回合未发动过
function c36239585.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(36239585)==0 end
	c:RegisterFlagEffect(36239585,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息为将此卡变为里侧守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 将此卡变为里侧守备表示
function c36239585.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将此卡变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 检索满足条件的「鬼计」卡（可特殊召唤或盖放）
function c36239585.setfilter(c,e,tp)
	if not c:IsSetCard(0x8d) then return false end
	if c:IsType(TYPE_MONSTER) then
		-- 判断是否有足够的怪兽区域进行特殊召唤
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	else return c:IsSSetable() end
end
-- 检索满足条件的表侧表示怪兽
function c36239585.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 设置选择目标为墓地中的「鬼计」卡
function c36239585.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36239585.setfilter(chkc,e,tp) end
	-- 判断是否存在满足条件的墓地中的「鬼计」卡
	if chk==0 then return Duel.IsExistingTarget(c36239585.setfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择目标为墓地中的「鬼计」卡
	local g=Duel.SelectTarget(tp,c36239585.setfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
		-- 设置操作信息为特殊召唤该卡
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	else
		e:SetCategory(CATEGORY_POSITION+CATEGORY_SSET+CATEGORY_MSET)
		-- 设置操作信息为将该卡盖放
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 处理反转效果的发动与后续操作
function c36239585.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local res=0
	if tc:IsType(TYPE_MONSTER) then
		-- 将目标卡特殊召唤到场上
		res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 确认对方查看该特殊召唤的卡
		if res~=0 then Duel.ConfirmCards(1-tp,tc) end
	else
		-- 将目标卡盖放到场上
		res=Duel.SSet(tp,tc)
	end
	if res~=0 then
		-- 设置该卡离开场上时被移除的处理
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
		-- 计算自己场上盖放的卡的数量
		local ct=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil)
		-- 判断自己场上存在盖放的卡且对方场上存在表侧表示怪兽
		if ct>0 and Duel.IsExistingMatchingCard(c36239585.posfilter,tp,0,LOCATION_MZONE,1,nil)
			-- 询问玩家是否选择对方怪兽变为里侧守备表示
			and Duel.SelectYesNo(tp,aux.Stringid(36239585,2)) then  --"是否选对方怪兽变成里侧守备表示？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要改变表示形式的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			-- 选择对方场上的表侧表示怪兽
			local g=Duel.SelectMatchingCard(tp,c36239585.posfilter,tp,0,LOCATION_MZONE,1,ct,nil)
			-- 显示所选怪兽被选为对象的动画
			Duel.HintSelection(g)
			-- 将所选怪兽变为里侧守备表示
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
