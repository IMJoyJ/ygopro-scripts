--暗黒の魔再生
-- 效果：
-- ①：对方怪兽的攻击宣言时，以对方墓地1张魔法卡为对象才能发动。那张卡在自己场上盖放。
-- ②：把墓地的这张卡除外，从手卡以及自己场上盖放的卡之中把1张「死者苏生」送去墓地才能发动。从自己墓地选1只「太阳神之翼神龙」无视召唤条件特殊召唤。那之后，可以选对方场上1只怪兽送去墓地。这个效果特殊召唤的怪兽在结束阶段送去墓地。
function c12930501.initial_effect(c)
	-- 为卡片注册与「太阳神之翼神龙」相关的代码列表，用于效果文本中提及该卡的判断
	aux.AddCodeList(c,10000010)
	-- ①：对方怪兽的攻击宣言时，以对方墓地1张魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12930501,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c12930501.condition)
	e1:SetTarget(c12930501.target)
	e1:SetOperation(c12930501.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，从手卡以及自己场上盖放的卡之中把1张「死者苏生」送去墓地才能发动。从自己墓地选1只「太阳神之翼神龙」无视召唤条件特殊召唤。那之后，可以选对方场上1只怪兽送去墓地。这个效果特殊召唤的怪兽在结束阶段送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12930501,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(c12930501.spcost)
	e2:SetTarget(c12930501.sptg)
	e2:SetOperation(c12930501.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为对方攻击宣言时触发的效果
function c12930501.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为攻击方
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤函数，用于筛选可盖放的魔法卡
function c12930501.filter(c,ft)
	return c:IsType(TYPE_SPELL) and c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or ft>0)
end
-- 设置效果目标，选择对方墓地的魔法卡作为对象
function c12930501.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前玩家场上可用的魔法卡区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c12930501.filter(chkc,ft) end
	-- 检查是否存在满足条件的对方墓地魔法卡
	if chk==0 then return Duel.IsExistingTarget(c12930501.filter,tp,0,LOCATION_GRAVE,1,nil,ft) end
	-- 提示玩家选择要盖放的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	-- 选择对方墓地的一张魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c12930501.filter,tp,0,LOCATION_GRAVE,1,1,nil,ft)
	-- 设置效果操作信息，记录将要盖放的魔法卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end
-- 执行效果操作，将选中的魔法卡盖放到场上
function c12930501.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标魔法卡盖放到场上
		Duel.SSet(tp,tc,tp)
	end
end
-- 过滤函数，用于筛选可作为cost的「死者苏生」
function c12930501.spcfilter(c)
	return c:IsCode(83764718) and c:IsAbleToGraveAsCost()
		and (c:IsFacedown() or c:IsLocation(LOCATION_HAND))
end
-- 设置效果cost，需要除外自身并支付「死者苏生」
function c12930501.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查是否存在满足条件的「死者苏生」
		and Duel.IsExistingMatchingCard(c12930501.spcfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
	-- 将自身从墓地除外作为cost
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 提示玩家选择要送去墓地的「死者苏生」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择一张「死者苏生」作为cost
	local g=Duel.SelectMatchingCard(tp,c12930501.spcfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil)
	-- 将选中的「死者苏生」送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于筛选可特殊召唤的「太阳神之翼神龙」
function c12930501.sptgfilter(c,e,tp)
	return c:IsCode(10000010) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 设置特殊召唤效果的目标
function c12930501.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「太阳神之翼神龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c12930501.sptgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp)>0 end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 过滤函数，用于筛选可送去墓地的对方怪兽
function c12930501.tgfilter(c)
	return c:IsAbleToGrave()
end
-- 执行特殊召唤效果的操作
function c12930501.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有可用的怪兽区域
	if Duel.GetMZoneCount(tp)<=0 then return end
	-- 提示玩家选择要特殊召唤的「太阳神之翼神龙」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择一张「太阳神之翼神龙」进行特殊召唤
	local tc=Duel.SelectMatchingCard(tp,c12930501.sptgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	-- 执行特殊召唤操作，将「太阳神之翼神龙」特殊召唤到场上
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(12930501,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 注册结束阶段将特殊召唤的怪兽送回墓地的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c12930501.tgcon)
		e1:SetOperation(c12930501.tgop)
		-- 将结束阶段效果注册到场上
		Duel.RegisterEffect(e1,tp)
		-- 检查对方场上是否存在可送去墓地的怪兽
		if Duel.IsExistingMatchingCard(c12930501.tgfilter,tp,0,LOCATION_MZONE,1,nil)
			-- 询问玩家是否选择对方怪兽送去墓地
			and Duel.SelectYesNo(tp,aux.Stringid(12930501,2)) then  --"是否选对方怪兽送去墓地？"
			-- 中断当前效果处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要送去墓地的对方怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			-- 选择对方场上的一个怪兽作为对象
			local g=Duel.SelectMatchingCard(tp,c12930501.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
			-- 显示选中怪兽被选为对象的动画
			Duel.HintSelection(g)
			-- 将选中的对方怪兽送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 判断特殊召唤的怪兽是否在场上的条件函数
function c12930501.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(12930501)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行将特殊召唤怪兽送回墓地的操作
function c12930501.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的怪兽送回墓地
	Duel.SendtoGrave(e:GetLabelObject(),REASON_EFFECT)
end
