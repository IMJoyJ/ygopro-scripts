--機動要塞 メタル・ホールド
-- 效果：
-- ①：以自己场上的机械族·4星怪兽任意数量为对象才能发动。这张卡发动后变成效果怪兽（机械族·地·4星·攻/守0）在怪兽区域特殊召唤。那之后，作为对象的表侧表示怪兽当作装备卡使用给这张卡装备。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果特殊召唤的这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力的合计数值，对方不能把其他的自己场上的怪兽作为攻击对象，也不能作为效果的对象。
function c42237854.initial_effect(c)
	-- 效果原文：①：以自己场上的机械族·4星怪兽任意数量为对象才能发动。这张卡发动后变成效果怪兽（机械族·地·4星·攻/守0）在怪兽区域特殊召唤。那之后，作为对象的表侧表示怪兽当作装备卡使用给这张卡装备。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c42237854.target)
	e1:SetOperation(c42237854.activate)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡的效果特殊召唤的这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力的合计数值，对方不能把其他的自己场上的怪兽作为攻击对象，也不能作为效果的对象。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(c42237854.condition)
	e0:SetValue(c42237854.atkval)
	c:RegisterEffect(e0)
	-- 效果原文：②：这张卡的效果特殊召唤的这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力的合计数值，对方不能把其他的自己场上的怪兽作为攻击对象，也不能作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c42237854.condition)
	e2:SetValue(c42237854.atlimit)
	c:RegisterEffect(e2)
	-- 效果原文：②：这张卡的效果特殊召唤的这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力的合计数值，对方不能把其他的自己场上的怪兽作为攻击对象，也不能作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c42237854.condition)
	e3:SetTarget(c42237854.tgtg)
	-- 设置效果值为aux.tgoval函数，用于判断是否成为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
-- 过滤函数：选择场上表侧表示的机械族4星怪兽
function c42237854.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevel(4)
end
-- 判断是否满足发动条件：确认是否有满足条件的怪兽可作为对象，是否有足够的怪兽区域和魔法陷阱区域，是否可以特殊召唤此卡
function c42237854.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c42237854.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 判断是否有满足条件的怪兽可作为对象
		and Duel.IsExistingTarget(c42237854.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否有足够的魔法陷阱区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否可以特殊召唤此卡
		and Duel.IsPlayerCanSpecialSummonMonster(tp,42237854,0,TYPES_EFFECT_TRAP_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_EARTH) end
	-- 获取玩家魔法陷阱区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c42237854.filter,tp,LOCATION_MZONE,0,1,ft,nil)
	-- 设置操作信息：特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：装备怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,g:GetCount(),0,0)
end
-- 过滤函数：选择与效果相关的表侧表示怪兽
function c42237854.tgfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 发动效果：将此卡变为效果怪兽并特殊召唤，然后将对象怪兽装备给此卡
function c42237854.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否可以特殊召唤此卡
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,42237854,0,TYPES_EFFECT_TRAP_MONSTER,0,0,4,RACE_MACHINE,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将此卡特殊召唤到场上
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)==0 then return end
	-- 获取连锁中设定的对象怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c42237854.tgfilter,nil,e)
	-- 获取玩家魔法陷阱区域的可用空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if g:GetCount()<=0 or ft<=0 then return end
	local tg=nil
	if ft<g:GetCount() then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		tg=g:FilterSelect(tp,c42237854.filter,ft,ft,nil)
	else
		tg=g:Clone()
	end
	if tg:GetCount()>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		local tc=tg:GetFirst()
		while tc do
			-- 将对象怪兽装备给此卡
			Duel.Equip(tp,tc,c,false,true)
			tc:RegisterFlagEffect(42237854,RESET_EVENT+RESETS_STANDARD,0,0)
			-- 设置装备限制效果，防止被其他卡装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c42237854.eqlimit)
			tc:RegisterEffect(e1,true)
			tc=tg:GetNext()
		end
		-- 完成装备过程
		Duel.EquipComplete()
	end
end
-- 判断此卡是否为特殊召唤的卡
function c42237854.condition(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 计算此卡装备怪兽的攻击力总和
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
-- 设置装备限制效果的判断函数
function c42237854.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 设置不能被攻击对象的判断函数
function c42237854.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 设置不能成为效果对象的判断函数
function c42237854.tgtg(e,c)
	return c~=e:GetHandler()
end
