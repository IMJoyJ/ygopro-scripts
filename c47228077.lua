--ヴァイロン・ペンタクロ
-- 效果：
-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的名字带有「大日」的怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，可以选择对方场上1张卡破坏。（1只怪兽可以装备的同盟最多1张。装备怪兽被破坏的场合，作为代替把这张卡破坏。）
function c47228077.initial_effect(c)
	-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的名字带有「大日」的怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47228077,0))  --"变成装备卡"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c47228077.eqtg)
	e1:SetOperation(c47228077.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47228077,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c47228077.sptg)
	e2:SetOperation(c47228077.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，可以选择对方场上1张卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e3:SetCondition(aux.IsUnionState)
	-- 设置替代破坏的过滤条件为由战斗或效果引起的事件
	e3:SetValue(aux.UnionReplaceFilter)
	c:RegisterEffect(e3)
	-- 1只怪兽可以装备的同盟最多1张。装备怪兽被破坏的场合，作为代替把这张卡破坏
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47228077,2))  --"对方场上的1张卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c47228077.descon)
	e4:SetTarget(c47228077.destg)
	e4:SetOperation(c47228077.desop)
	c:RegisterEffect(e4)
	-- 同盟怪兽的限制
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UNION_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c47228077.eqlimit)
	c:RegisterEffect(e5)
end
c47228077.old_union=true
-- 限制只能装备到名字带有「大日」的怪兽上
function c47228077.eqlimit(e,c)
	return c:IsSetCard(0x30)
end
-- 过滤满足条件的怪兽：表侧表示、名字带有「大日」、未被同盟装备
function c47228077.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x30) and c:GetUnionCount()==0
end
-- 设置装备效果的发动条件和目标选择逻辑
function c47228077.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c47228077.filter(chkc) end
	-- 检查是否已使用过此效果且场上存在可用区域
	if chk==0 then return e:GetHandler():GetFlagEffect(47228077)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认场上是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c47228077.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c47228077.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息，记录将要进行的装备动作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(47228077,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 执行装备效果的操作流程
function c47228077.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c47228077.filter(tc) then
		-- 若装备失败则将自身送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将装备卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 为装备卡添加同盟怪兽属性
	aux.SetUnionState(c)
end
-- 设置特殊召唤效果的发动条件和目标选择逻辑
function c47228077.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已使用过此效果且场上存在可用区域
	if chk==0 then return e:GetHandler():GetFlagEffect(47228077)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置操作信息，记录将要进行的特殊召唤动作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(47228077,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 执行特殊召唤效果的操作流程
function c47228077.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧攻击表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 设置触发条件：装备怪兽战斗破坏对方怪兽且自身处于同盟状态
function c47228077.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为同盟状态并确认被破坏的怪兽是否为当前装备对象
	return aux.IsUnionState(e) and e:GetHandler():GetEquipTarget()==eg:GetFirst()
end
-- 设置破坏效果的目标选择逻辑
function c47228077.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 确认对方场上是否存在可破坏的卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标卡片进行破坏
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，记录将要进行的破坏动作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果的操作流程
function c47228077.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选中的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
