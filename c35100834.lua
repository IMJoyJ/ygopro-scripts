--機動砲塁 パワー・ホールド
-- 效果：
-- ①：这张卡发动后变成效果怪兽（机械族·地·4星·攻0/守2000）在怪兽区域特殊召唤。那之后，可以从手卡·卡组选1只机械族·4星的「零件」怪兽当作装备卡使用给这张卡装备。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果特殊召唤的这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力2倍的数值。
function c35100834.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（机械族·地·4星·攻0/守2000）在怪兽区域特殊召唤。那之后，可以从手卡·卡组选1只机械族·4星的「零件」怪兽当作装备卡使用给这张卡装备。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c35100834.target)
	e1:SetOperation(c35100834.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果特殊召唤的这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力2倍的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c35100834.atkcon)
	e2:SetValue(c35100834.atkval)
	c:RegisterEffect(e2)
end
-- 检查是否满足特殊召唤条件，包括场地空位和是否可以特殊召唤该怪兽。
function c35100834.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上是否有足够的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤该效果怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35100834,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置效果处理时将要特殊召唤的卡片信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于筛选手卡或卡组中满足条件的机械族4星「零件」怪兽。
function c35100834.eqfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and c:IsLevel(4) and c:IsSetCard(0x51) and c:CheckUniqueOnField(tp)
end
-- 发动效果时执行的操作，包括将卡片变为效果怪兽并特殊召唤，然后判断是否进行装备。
function c35100834.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否可以特殊召唤该怪兽。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,35100834,0,TYPES_EFFECT_TRAP_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将该卡以特殊召唤方式（SUMMON_VALUE_SELF）特殊召唤到场上。
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)==0 then return end
	-- 获取满足条件的机械族4星「零件」怪兽的集合。
	local g=Duel.GetMatchingGroup(c35100834.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,tp)
	-- 判断是否有满足条件的怪兽、场上是否有装备区域、并询问玩家是否装备。
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(35100834,0)) then  --"是否装备？"
		-- 中断当前效果处理，使后续效果视为错时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要装备的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 将选中的怪兽装备给此卡。
		Duel.Equip(tp,tc,c)
		-- 设置装备限制效果，防止其他卡装备到此卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c35100834.eqlimit)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(35100834,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
-- 装备限制效果的判断函数，确保只能装备到此卡。
function c35100834.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 判断此卡是否为特殊召唤的卡片。
function c35100834.atkcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 计算此卡因装备而获得的攻击力加成。
function c35100834.atkval(e,c)
	local atk=0
	local g=c:GetEquipGroup()
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(35100834)~=0 and tc:GetAttack()>=0 then
			atk=atk+tc:GetAttack()*2
		end
		tc=g:GetNext()
	end
	return atk
end
