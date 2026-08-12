--人攻智能ME－PSY－YA
-- 效果：
-- ←0 【灵摆】 0→
-- ①：只要这张卡在灵摆区域存在，怪兽卡以外的被送去双方墓地的卡不去墓地而除外。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。选这张卡以外的手卡1只灵摆怪兽或者自己的灵摆区域1张卡表侧表示加入持有者的额外卡组，这张卡特殊召唤。
-- ②：这张卡已在怪兽区域存在的状态，其他怪兽召唤·特殊召唤的场合发动。那些怪兽在这个回合的结束阶段送去墓地。
function c58844135.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在灵摆区域存在，怪兽卡以外的被送去双方墓地的卡不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e1:SetTarget(c58844135.rmtarget)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在灵摆区域存在，怪兽卡以外的被送去双方墓地的卡不去墓地而除外。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(81674782)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_PZONE)
	e0:SetTargetRange(0xff,0xff)
	-- 设置过滤条件为始终成立（影响所有卡片）。
	e0:SetTarget(aux.TRUE)
	c:RegisterEffect(e0)
	-- ①：把手卡的这张卡给对方观看才能发动。选这张卡以外的手卡1只灵摆怪兽或者自己的灵摆区域1张卡表侧表示加入持有者的额外卡组，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58844135,0))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,58844135)
	e2:SetCost(c58844135.spcost)
	e2:SetTarget(c58844135.sptg)
	e2:SetOperation(c58844135.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡已在怪兽区域存在的状态，其他怪兽召唤·特殊召唤的场合发动。那些怪兽在这个回合的结束阶段送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58844135,1))  --"召唤的怪兽在结束阶段送去墓地"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c58844135.tgcon)
	e3:SetTarget(c58844135.tgtg)
	e3:SetOperation(c58844135.tgop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 过滤非怪兽卡（原本卡片类型不含怪兽的卡）。
function c58844135.rmtarget(e,c)
	return c:GetOriginalType()&TYPE_MONSTER==0
end
-- 检查手卡的这张卡是否未给对方观看，作为发动的Cost。
function c58844135.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤手卡或灵摆区域的灵摆怪兽，且该卡能表侧表示加入额外卡组。
function c58844135.tefilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToExtra()
end
-- 检查自己场上是否有怪兽区域空位、手卡或灵摆区是否有其他灵摆卡，以及自身能否特殊召唤，并设置操作信息。
function c58844135.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡或灵摆区域是否存在至少1张这张卡以外的灵摆卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c58844135.tefilter,tp,LOCATION_HAND+LOCATION_PZONE,0,1,c)
		-- 检查自己的主要怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息为：将手卡或灵摆区域的1张卡加入额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_HAND+LOCATION_PZONE)
	-- 设置连锁的操作信息为：将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：让玩家选择手卡或灵摆区的一张灵摆卡表侧表示送去额外卡组，若成功则特殊召唤这张卡。
function c58844135.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要加入额外卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(58844135,2))  --"请选择要加入额外卡组的卡"
	-- 玩家选择手卡或灵摆区域的1张这张卡以外的灵摆卡。
	local g=Duel.SelectMatchingCard(tp,c58844135.tefilter,tp,LOCATION_HAND+LOCATION_PZONE,0,1,1,c)
	local tc=g:GetFirst()
	-- 检查选择的卡是否成功表侧表示送去额外卡组，且这张卡仍存在于手卡。
	if tc and Duel.SendtoExtraP(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检查召唤·特殊召唤的怪兽中是否不包含这张卡自身。
function c58844135.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end
-- 过滤出召唤·特殊召唤成功且目前仍在怪兽区域的怪兽，并将其设为效果处理的目标。
function c58844135.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 将这些召唤·特殊召唤的怪兽保存为当前连锁的目标。
	Duel.SetTargetCard(g)
end
-- 过滤出仍与效果相关且不受该效果免疫的怪兽。
function c58844135.tgfilter(c,e)
	return c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
-- 效果处理：给目标怪兽添加标记，并注册一个在回合结束阶段将这些怪兽送去墓地的延迟效果。
function c58844135.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽中，仍与效果相关且未免疫该效果的怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c58844135.tgfilter,nil,e)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			tc:RegisterFlagEffect(58844135,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			tc=g:GetNext()
		end
		g:KeepAlive()
		-- 那些怪兽在这个回合的结束阶段送去墓地。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabelObject(g)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(c58844135.descon)
		e1:SetOperation(c58844135.desop)
		-- 注册在回合结束阶段触发的全局时点效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤出带有该效果标记的怪兽。
function c58844135.desfilter(c)
	return c:GetFlagEffect(58844135)~=0
end
-- 检查是否存在带有该效果标记的怪兽，作为结束阶段效果触发的条件。
function c58844135.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():IsExists(c58844135.desfilter,1,nil)
end
-- 结束阶段效果处理：将所有带有标记的怪兽送去墓地，并清理卡片组。
function c58844135.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c58844135.desfilter,nil)
	-- 因效果将目标怪兽送去墓地。
	Duel.SendtoGrave(tg,REASON_EFFECT)
	g:DeleteGroup()
end
