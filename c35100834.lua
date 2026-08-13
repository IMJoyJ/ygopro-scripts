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
-- 发动条件判定：确认此卡发动时不处于被cost检查限制的状态、自己主要怪兽区有空位，且自己能够把此卡作为机械族·地·4星·攻0/守2000的效果陷阱怪兽特殊召唤。
function c35100834.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己主要怪兽区是否有可用空格，用于此卡通过①效果特殊召唤到怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己能否将此卡作为机械族·地·4星·攻0/守2000的效果陷阱怪兽特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35100834,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 设置本次效果处理将进行的特殊召唤操作信息，使其他卡能正确连锁和检测此次特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义可装备的「零件」怪兽的筛选条件：机械族、4星、卡名包含「零件」字段，且场上不能已有同名卡导致无法配置。
function c35100834.eqfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and c:IsLevel(4) and c:IsSetCard(0x51) and c:CheckUniqueOnField(tp)
end
-- ①效果处理：将此卡特殊召唤为效果陷阱怪兽，然后从手卡·卡组选出符合条件的「零件」怪兽装备给它；若装备成功，为该装备怪兽设置仅限装备于此卡的装备限制及标记。
function c35100834.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认此卡仍可被特殊召唤为效果陷阱怪兽，若因其他效果导致无法特招则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,35100834,0,TYPES_EFFECT_TRAP_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将此卡以自身效果（SUMMON_VALUE_SELF）表侧表示特殊召唤到怪兽区，只有成功特殊召唤才继续后续装备处理。
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)==0 then return end
	-- 从手卡和卡组中检索所有符合 eqfilter 条件的机械族·4星「零件」怪兽。
	local g=Duel.GetMatchingGroup(c35100834.eqfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,tp)
	-- 若存在可装备的「零件」怪兽、自己魔陷区有空位，且玩家选择发动后续装备效果，则继续执行装备操作。
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(35100834,0)) then  --"是否装备？"
		-- 中断当前效果处理，使后续装备操作视为在不同时点处理，避免错过时点。
		Duel.BreakEffect()
		-- 向玩家显示“请选择要装备的卡”的提示，并准备进入装备卡选择界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 将选中的「零件」怪兽作为装备卡装备给这张卡。
		Duel.Equip(tp,tc,c)
		-- 为装备怪兽设置“只能装备给此卡”的装备限制（对应①中“当作装备卡使用给这张卡装备”），并通过 atkcon/atkval 实现②中“这张卡的效果特殊召唤的这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力2倍的数值”。
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
-- 定义装备限制条件：该装备卡仅允许装备给效果的持有者，即「机动炮垒 强力堡垒」自身。
function c35100834.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 攻击力上升效果的适用条件：此卡必须是通过①效果（自身效果）特殊召唤成功后才适用。
function c35100834.atkcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 计算攻击力上升值：遍历此卡的装备怪兽，对带有此卡效果标记的装备怪兽，将其攻击力×2累加，作为攻击力上升数值。
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
