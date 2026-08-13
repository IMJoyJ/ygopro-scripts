--機動要塞 メタル・ホールド
-- 效果：
-- ①：以自己场上的机械族·4星怪兽任意数量为对象才能发动。这张卡发动后变成效果怪兽（机械族·地·4星·攻/守0）在怪兽区域特殊召唤。那之后，作为对象的表侧表示怪兽当作装备卡使用给这张卡装备。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果特殊召唤的这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力的合计数值，对方不能把其他的自己场上的怪兽作为攻击对象，也不能作为效果的对象。
function c42237854.initial_effect(c)
	-- ①：以自己场上的机械族·4星怪兽任意数量为对象才能发动。这张卡发动后变成效果怪兽（机械族·地·4星·攻/守0）在怪兽区域特殊召唤。那之后，作为对象的表侧表示怪兽当作装备卡使用给这张卡装备。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c42237854.target)
	e1:SetOperation(c42237854.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果特殊召唤的这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力的合计数值
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(c42237854.condition)
	e0:SetValue(c42237854.atkval)
	c:RegisterEffect(e0)
	-- 对方不能把其他的自己场上的怪兽作为攻击对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c42237854.condition)
	e2:SetValue(c42237854.atlimit)
	c:RegisterEffect(e2)
	-- 也不能作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c42237854.condition)
	e3:SetTarget(c42237854.tgtg)
	-- 将“不能成为效果对象”的判定值设为aux.tgoval，即：只有这张卡的控制者自己的效果可以选择其为对象，对方的效果不能选择其为对象，从而实现“对方不能作为效果的对象”。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
-- 对象筛选函数：选择表侧表示且为机械族·4星的怪兽。
function c42237854.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevel(4)
end
-- 该效果的发动条件与取对象处理：检查场上是否存在符合条件的机械族4星怪兽、怪兽区和魔陷区是否有空位、以及能否将这张卡特殊召唤为陷阱怪兽；满足后选择对象并设置特殊召唤与装备的操作信息。
function c42237854.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42237854.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在至少1只表侧表示机械族·4星怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c42237854.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己的主要怪兽区域是否有空位，用于让这张卡特殊召唤到怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的魔陷区域是否有空位，用于后续把对象怪兽当作装备卡装备给这张卡。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家能否把这张卡作为机械族·地·4星·攻/守0的效果怪兽特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,42237854,0,TYPES_EFFECT_TRAP_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 取得自己魔陷区的可用空格数，作为可以选择的对象怪兽数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 弹出选择提示，提示文字为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1到ft张自己场上表侧表示且为机械族·4星的怪兽作为效果对象，最多不超过魔陷区空位数。
	local g=Duel.SelectTarget(tp,c42237854.filter,tp,LOCATION_MZONE,0,1,ft,nil)
	-- 设置操作信息：记录这张卡自身将作为1只怪兽被特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：记录选择的对象怪兽将作为装备卡装备给这张卡，数量为对象怪兽的数量。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,g:GetCount(),0,0)
end
-- 效果处理时筛选对象：对象仍然表侧表示且与发动时的效果相关联，排除中途离场或变成里侧的卡。
function c42237854.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果处理流程：将这张卡特殊召唤为效果怪兽；若成功，从对象中筛选仍合法且相关的怪兽，根据魔陷区空位数量决定实际装备的怪兽，并将这些表侧表示怪兽分别作为装备卡装备给这张卡。
function c42237854.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次确认玩家仍能把这ga这张卡特殊召唤为效果怪兽，若不能则效果不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,42237854,0,TYPES_EFFECT_TRAP_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将这张卡以自身效果特殊召唤到怪兽区域；若特殊召唤失败则终止后续处理。SUMMON_VALUE_SELF表示这是由这张卡自身效果进行的特殊召唤。
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)==0 then return end
	-- 从连锁信息中取出发动时选择的对象，并筛选出仍然表侧表示且与该效果相关的怪兽作为待装备候补。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c42237854.tgfilter,nil,e)
	-- 取得魔陷区可用空格数，决定实际可以装备的对象数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if g:GetCount()<=0 or ft<=0 then return end
	local tg=nil
	if ft<g:GetCount() then
		-- 弹出装备选择提示，提示文字为“请选择要装备的卡”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		tg=g:FilterSelect(tp,c42237854.filter,ft,ft,nil)
	else
		tg=g:Clone()
	end
	if tg:GetCount()>0 then
		-- 中断当前效果处理，使后续装备处理与之前的特殊召唤不视为同一时点处理，避免连锁时点上的误判。
		Duel.BreakEffect()
		local tc=tg:GetFirst()
		while tc do
			-- 将选中的对象怪兽tc作为装备卡装备给铁堡垒c；up=false表示保持其原表示形式，is_step=true表示作为装备过程的一步，稍后由EquipComplete统一完成。
			Duel.Equip(tp,tc,c,false,true)
			tc:RegisterFlagEffect(42237854,RESET_EVENT+RESETS_STANDARD,0,0)
			-- 那之后，作为对象的表侧表示怪兽当作装备卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c42237854.eqlimit)
			tc:RegisterEffect(e1,true)
			tc=tg:GetNext()
		end
		-- 结束装备过程的逐步处理，统一触发装备成功的时点。
		Duel.EquipComplete()
	end
end
-- ②效果适用条件：这张卡必须是由自身效果特殊召唤的怪兽，即召唤类型为特殊召唤加自身效果时才适用后续效果。
function c42237854.condition(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 攻击力上升数值的计算函数：遍历这张卡的装备卡，累加由①效果装备并带有42237854标记的怪兽卡攻击力，合计作为攻击力上升值。
function c42237854.atkval(e,c)
	local atk=0
	local g=c:GetEquipGroup()
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(42237854)~=0 and tc:GetAttack()>=0 then
			atk=atk+tc:GetAttack()
		end
		tc=g:GetNext()
	end
	return atk
end
-- 装备限制函数：被装备的怪兽卡只能装备给效果的所有者（即铁堡垒本身），不能装备到其他怪兽身上。
function c42237854.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 攻击对象限制的判定函数：对除铁堡垒以外的自己场上其他怪兽返回真，使对方不能选择它们作为攻击对象。
function c42237854.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 效果对象限制的判定函数：对除铁堡垒以外的自己场上其他怪兽返回真，使对方不能以它们作为效果对象。
function c42237854.tgtg(e,c)
	return c~=e:GetHandler()
end
