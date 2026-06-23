--セコンド・ゴブリン
-- 效果：
-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「巨大兽人」装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用时，装备怪兽的表示形式1回合只有1次可以变更。（1只怪兽可以装备的同盟最多1张。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。）
function c19086954.initial_effect(c)
	-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「巨大兽人」装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19086954,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c19086954.eqtg)
	e1:SetOperation(c19086954.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19086954,1))  --"解除装备状态表侧攻击表示特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c19086954.sptg)
	e2:SetOperation(c19086954.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用时，装备怪兽的表示形式1回合只有1次可以变更
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19086954,2))  --"改变装备怪兽的表示形式"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e3:SetCondition(aux.IsUnionState)
	e3:SetTarget(c19086954.postg)
	e3:SetOperation(c19086954.posop)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e5:SetCondition(aux.IsUnionState)
	e5:SetValue(c19086954.repval)
	c:RegisterEffect(e5)
	-- 1只怪兽可以装备的同盟最多1张
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UNION_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(c19086954.eqlimit)
	c:RegisterEffect(e6)
end
c19086954.old_union=true
-- 当装备怪兽因战斗破坏时，此卡代替破坏
function c19086954.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 此卡只能装备给「巨大兽人」
function c19086954.eqlimit(e,c)
	return c:IsCode(73698349)
end
-- 筛选满足条件的「巨大兽人」怪兽（表侧表示、卡号为73698349、未被同盟装备）
function c19086954.filter(c)
	return c:IsFaceup() and c:IsCode(73698349) and c:GetUnionCount()==0
end
-- 设置装备效果的筛选条件，选择己方场上满足条件的「巨大兽人」怪兽
function c19086954.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19086954.filter(chkc) end
	-- 检查此卡是否在本回合已发动过效果
	if chk==0 then return e:GetHandler():GetFlagEffect(19086954)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查己方场上是否存在满足条件的「巨大兽人」怪兽
		and Duel.IsExistingTarget(c19086954.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的「巨大兽人」怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c19086954.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(19086954,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 执行装备操作，将此卡装备给目标怪兽
function c19086954.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c19086954.filter(tc) then
		-- 若装备失败则将此卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将此卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 为装备卡添加同盟怪兽属性
	aux.SetUnionState(c)
end
-- 设置特殊召唤效果的筛选条件
function c19086954.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡是否在本回合已发动过效果
	if chk==0 then return e:GetHandler():GetFlagEffect(19086954)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 提示对方玩家此卡发动了特殊召唤效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(19086954,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 执行特殊召唤操作，将此卡以表侧攻击表示特殊召唤
function c19086954.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧攻击表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 设置改变表示形式效果的筛选条件
function c19086954.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方玩家此卡发动了改变表示形式效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置改变表示形式效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler():GetEquipTarget(),1,0,0)
end
-- 执行改变表示形式操作，将装备怪兽变为守备表示
function c19086954.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将装备怪兽变为守备表示
		Duel.ChangePosition(c:GetEquipTarget(),POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
