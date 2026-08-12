--アーマー・ブレイカー
-- 效果：
-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己场上的战士族怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽给与对方基本分战斗伤害时，场上存在的1张卡破坏。（1只怪兽可以装备的同盟最多1张。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。）
function c87798440.initial_effect(c)
	-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己场上的战士族怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87798440,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c87798440.eqtg)
	e1:SetOperation(c87798440.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87798440,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 设置特殊召唤效果的发动条件为：此卡处于同盟装备状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c87798440.sptg)
	e2:SetOperation(c87798440.spop)
	c:RegisterEffect(e2)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设置代替破坏效果的适用条件为：此卡处于同盟装备状态
	e3:SetCondition(aux.IsUnionState)
	e3:SetValue(c87798440.repval)
	c:RegisterEffect(e3)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽给与对方基本分战斗伤害时，场上存在的1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(87798440,2))  --"破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c87798440.descon)
	e4:SetTarget(c87798440.destg)
	e4:SetOperation(c87798440.desop)
	c:RegisterEffect(e4)
	-- 1只怪兽可以装备的同盟最多1张。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UNION_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c87798440.eqlimit)
	c:RegisterEffect(e5)
end
c87798440.old_union=true
-- 代替破坏的价值函数：判定导致破坏的原因是否为战斗
function c87798440.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 同盟装备限制函数：限制只能装备给战士族怪兽
function c87798440.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤函数：检索场上表侧表示、未装备同盟怪兽的战士族怪兽
function c87798440.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:GetUnionCount()==0
end
-- 装备效果的目标选择与发动条件判定函数
function c87798440.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c87798440.filter(chkc) end
	-- 判定本回合是否未发动过同盟效果，且自己魔陷区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(87798440)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且自己场上存在可以装备的战士族怪兽
		and Duel.IsExistingTarget(c87798440.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的战士族怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c87798440.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：装备分类，对象为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(87798440,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的执行函数
function c87798440.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c87798440.filter(tc) then
		-- 若自身或目标怪兽不合法，则将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将自身作为装备卡装备给目标怪兽，若装备失败则结束
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 设置此卡处于同盟装备状态
	aux.SetUnionState(c)
end
-- 特殊召唤效果的目标选择与发动条件判定函数
function c87798440.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定本回合是否未发动过同盟效果，且自己怪兽区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(87798440)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 设置操作信息：特殊召唤分类，对象为自身，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(87798440,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的执行函数
function c87798440.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧攻击表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 破坏效果的发动条件函数
function c87798440.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否为装备怪兽给与对方战斗伤害，且此卡处于同盟装备状态
	return ep~=tp and e:GetHandler():GetEquipTarget()==eg:GetFirst() and aux.IsUnionState(e)
end
-- 破坏效果的目标选择与发动条件判定函数
function c87798440.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上任意1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏分类，对象为选择的卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行函数
function c87798440.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要破坏的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
