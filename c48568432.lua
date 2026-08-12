--トライゴン
-- 效果：
-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的机械族怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，从自己墓地选择1只机械族·光属性·4星以下的怪兽特殊召唤。（1只怪兽可以装备的同盟最多1张。装备怪兽被破坏的场合，作为代替把这张卡破坏。）
function c48568432.initial_effect(c)
	-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的机械族怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48568432,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c48568432.eqtg)
	e1:SetOperation(c48568432.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48568432,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c48568432.sptg)
	e2:SetOperation(c48568432.spop)
	c:RegisterEffect(e2)
	-- 装备怪兽战斗破坏对方怪兽的场合，从自己墓地选择1只机械族·光属性·4星以下的怪兽特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e3:SetCondition(aux.IsUnionState)
	-- 设置替代破坏时的过滤条件为由战斗或效果引起的事件
	e3:SetValue(aux.UnionReplaceFilter)
	c:RegisterEffect(e3)
	-- 1只怪兽可以装备的同盟最多1张
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UNION_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c48568432.eqlimit)
	c:RegisterEffect(e4)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，从自己墓地选择1只机械族·光属性·4星以下的怪兽特殊召唤
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(48568432,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(c48568432.spcon2)
	e5:SetTarget(c48568432.sptg2)
	e5:SetOperation(c48568432.spop2)
	c:RegisterEffect(e5)
end
c48568432.old_union=true
-- 限制装备怪兽必须为机械族
function c48568432.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE)
end
-- 筛选场上正面表示的机械族且未装备的怪兽作为目标
function c48568432.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:GetUnionCount()==0
end
-- 设置装备效果的目标条件为己方场上的机械族怪兽
function c48568432.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c48568432.filter(chkc) end
	-- 确认此效果是否已在本回合发动过
	if chk==0 then return e:GetHandler():GetFlagEffect(48568432)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查己方是否有足够的魔法陷阱区域来装备此卡
		and Duel.IsExistingTarget(c48568432.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择符合条件的场上机械族怪兽作为装备目标
	local g=Duel.SelectTarget(tp,c48568432.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(48568432,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 执行装备操作，若失败则将自身送入墓地
function c48568432.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c48568432.filter(tc) then
		-- 将自身送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将此卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 为装备卡添加同盟怪兽属性
	aux.SetUnionState(c)
end
-- 设置特殊召唤效果的目标条件
function c48568432.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认此效果是否已在本回合发动过
	if chk==0 then return e:GetHandler():GetFlagEffect(48568432)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(48568432,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 执行特殊召唤操作
function c48568432.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧攻击表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 判断是否为同盟状态且被破坏的怪兽是装备目标
function c48568432.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为同盟状态且被破坏的怪兽是装备目标
	return aux.IsUnionState(e) and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 筛选墓地中满足条件的机械族·光属性·4星以下怪兽
function c48568432.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置战斗破坏后特殊召唤效果的目标条件
function c48568432.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c48568432.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方墓地选择符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c48568432.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c48568432.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
