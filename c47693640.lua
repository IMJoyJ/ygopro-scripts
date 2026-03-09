--ゾンビタイガー
-- 效果：
-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「腐朽的武将」装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用时，装备怪兽的攻击力·守备力上升500点。装备怪兽每次战斗破坏对方怪兽时，对方随机丢弃1张手卡。（1只怪兽可以装备的同盟最多1张。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。）
function c47693640.initial_effect(c)
	-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「腐朽的武将」装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47693640,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c47693640.eqtg)
	e1:SetOperation(c47693640.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47693640,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c47693640.sptg)
	e2:SetOperation(c47693640.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用时，装备怪兽的攻击力·守备力上升500点
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e3:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e3)
	-- 只在这个效果当作装备卡使用时，装备怪兽的攻击力·守备力上升500点
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(500)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e4:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e4)
	-- 装备怪兽每次战斗破坏对方怪兽时，对方随机丢弃1张手卡
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(47693640,2))  --"手牌丢弃"
	e5:SetCategory(CATEGORY_HANDES)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(c47693640.hdcon)
	e5:SetTarget(c47693640.hdtg)
	e5:SetOperation(c47693640.hdop)
	c:RegisterEffect(e5)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e6:SetCondition(aux.IsUnionState)
	e6:SetValue(c47693640.repval)
	c:RegisterEffect(e6)
	-- 1只怪兽可以装备的同盟最多1张
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UNION_LIMIT)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetValue(c47693640.eqlimit)
	c:RegisterEffect(e7)
end
c47693640.old_union=true
-- 当此卡因战斗破坏时生效
function c47693640.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 只能装备给「腐朽的武将」
function c47693640.eqlimit(e,c)
	return c:IsCode(10209545)
end
-- 筛选场上正面表示的「腐朽的武将」且未被同盟装备的怪兽
function c47693640.filter(c)
	return c:IsFaceup() and c:IsCode(10209545) and c:GetUnionCount()==0
end
-- 设置装备卡效果的处理目标为符合条件的怪兽
function c47693640.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c47693640.filter(chkc) end
	-- 检查此卡是否在本回合已发动过效果
	if chk==0 then return e:GetHandler():GetFlagEffect(47693640)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在符合条件的怪兽作为装备对象
		and Duel.IsExistingTarget(c47693640.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择符合条件的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c47693640.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置连锁操作信息为装备效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(47693640,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 执行装备卡效果的操作流程
function c47693640.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c47693640.filter(tc) then
		-- 将此卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将此卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 为装备卡添加同盟怪兽属性
	aux.SetUnionState(c)
end
-- 设置特殊召唤效果的处理条件
function c47693640.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡是否在本回合已发动过效果
	if chk==0 then return e:GetHandler():GetFlagEffect(47693640)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 向对方提示发动了特殊召唤效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息为特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(47693640,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 执行特殊召唤效果的操作流程
function c47693640.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧攻击表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 判断是否为同盟状态且被战斗破坏的怪兽
function c47693640.hdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查装备怪兽是否处于同盟状态并被战斗破坏
	return aux.IsUnionState(e) and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 设置手牌丢弃效果的目标和操作信息
function c47693640.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为对方随机丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
-- 执行手牌丢弃效果的操作流程
function c47693640.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有手牌
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	-- 将随机选择的手牌送入墓地
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end
