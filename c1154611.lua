--バージェストマ・レアンコイリア
-- 效果：
-- ①：以除外的1张自己或者对方的卡为对象才能发动。那张卡回到墓地。
-- ②：陷阱卡发动时，连锁那个发动才能把这个效果在墓地发动。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
function c1154611.initial_effect(c)
	-- ①：以除外的1张自己或者对方的卡为对象才能发动。那张卡回到墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c1154611.target)
	e1:SetOperation(c1154611.activate)
	c:RegisterEffect(e1)
	-- ②：陷阱卡发动时，连锁那个发动才能把这个效果在墓地发动。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1154611,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c1154611.spcon)
	e2:SetTarget(c1154611.sptg)
	e2:SetOperation(c1154611.spop)
	c:RegisterEffect(e2)
end
-- 效果处理函数：处理①效果的目标选择
function c1154611.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
	-- 判断是否满足①效果的发动条件：场上存在除外区的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 提示玩家选择要送入墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择一张除外区的卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	-- 设置效果处理信息：将选中的卡送入墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果处理函数：处理①效果的发动
function c1154611.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送入墓地（原因：效果+回到墓地）
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
-- 效果处理函数：判断②效果是否可以发动
function c1154611.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 效果处理函数：处理②效果的目标选择
function c1154611.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足②效果的发动条件：场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤该怪兽：是否满足召唤条件
		and Duel.IsPlayerCanSpecialSummonMonster(tp,1154611,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置效果处理信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数：处理②效果的发动
function c1154611.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足②效果的发动条件：场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 判断是否可以发动②效果：卡在墓地且满足召唤条件
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,1154611,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		-- 设置效果：此卡不受怪兽效果影响
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(c1154611.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2,true)
		-- 设置效果：此卡离开场时被除外
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3,true)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 效果过滤函数：判断是否为怪兽效果
function c1154611.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
