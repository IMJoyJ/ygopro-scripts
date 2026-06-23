--優麗なる霊鏡
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只4星以下的怪兽为对象才能发动。把持有那只怪兽的等级以下的等级的1只怪兽从手卡特殊召唤。那之后，作为对象的怪兽当作装备卡使用给那只特殊召唤的怪兽装备。只要这个效果把怪兽装备中，装备怪兽的攻击力上升这个效果装备的怪兽的攻击力一半数值。这个回合，自己不能把那张装备卡以及那些同名卡的效果发动。
function c18954366.initial_effect(c)
	-- ①：以自己墓地1只4星以下的怪兽为对象才能发动。把持有那只怪兽的等级以下的等级的1只怪兽从手卡特殊召唤。那之后，作为对象的怪兽当作装备卡使用给那只特殊召唤的怪兽装备。只要这个效果把怪兽装备中，装备怪兽的攻击力上升这个效果装备的怪兽的攻击力一半数值。这个回合，自己不能把那张装备卡以及那些同名卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18954366+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c18954366.target)
	e1:SetOperation(c18954366.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡中等级不超过目标怪兽等级的怪兽，用于特殊召唤
function c18954366.spfilter(c,e,tp,lv)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤自己墓地中的4星以下怪兽，确保其手卡中有满足等级条件的怪兽可特殊召唤
function c18954366.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4)
		-- 检查自己手卡中是否存在等级不超过目标怪兽等级的怪兽
		and Duel.IsExistingMatchingCard(c18954366.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetLevel())
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 设置目标选择条件：自己墓地中的4星以下怪兽
function c18954366.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and chkc:IsType(TYPE_MONSTER) and chkc:IsLevelBelow(4) end
	local ft=1
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=2 end
	-- 检查自己场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己魔法陷阱区域是否有足够的装备区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>=ft
		-- 确认自己墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c18954366.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c18954366.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：目标怪兽离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理函数：获取目标怪兽并执行效果
function c18954366.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 检查自己场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=tc:GetLevel()
	local atk=tc:GetAttack()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择等级不超过目标怪兽等级的怪兽
	local sc=Duel.SelectMatchingCard(tp,c18954366.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,lv):GetFirst()
	-- 将选中的怪兽特殊召唤到场上
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0
		and not tc:IsForbidden() and tc:CheckUniqueOnField(tp)
		-- 将目标怪兽装备给特殊召唤的怪兽
		and Duel.Equip(tp,tc,sc) then
		if atk>0 then
			-- 装备怪兽的攻击力上升装备怪兽攻击力的一半
			local e1=Effect.CreateEffect(tc)
			e1:SetType(EFFECT_TYPE_EQUIP)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(math.ceil(atk/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 这个回合，自己不能把那张装备卡以及那些同名卡的效果发动。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(1,0)
		e2:SetValue(c18954366.aclimit)
		e2:SetLabel(tc:GetCode())
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果：禁止发动装备卡及同名卡的效果
		Duel.RegisterEffect(e2,tp)
		-- 装备卡只能装备给特定怪兽
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetLabelObject(sc)
		e3:SetValue(c18954366.eqlimit)
		tc:RegisterEffect(e3)
	end
end
-- 判断效果是否为装备卡的同名卡
function c18954366.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
-- 判断装备卡是否只能装备给特定怪兽
function c18954366.eqlimit(e,c)
	return c==e:GetLabelObject()
end
