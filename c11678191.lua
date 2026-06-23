--守護霊アイリン
-- 效果：
-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「不屈斗士 磊磊」装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用时，装备怪兽的表示形式1回合可以改变1次。（1只怪兽可以装备的同盟最多1张。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。）
function c11678191.initial_effect(c)
	-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「不屈斗士 磊磊」装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11678191,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c11678191.eqtg)
	e1:SetOperation(c11678191.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11678191,1))  --"解除装备状态表侧攻击表示特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 检查当前效果是否处于同盟装备状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c11678191.sptg)
	e2:SetOperation(c11678191.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用时，装备怪兽的表示形式1回合可以改变1次
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11678191,2))  --"改变装备怪兽的表示形式"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	-- 检查当前效果是否处于同盟装备状态
	e3:SetCondition(aux.IsUnionState)
	e3:SetTarget(c11678191.postg)
	e3:SetOperation(c11678191.posop)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 检查当前效果是否处于同盟装备状态
	e5:SetCondition(aux.IsUnionState)
	e5:SetValue(c11678191.repval)
	c:RegisterEffect(e5)
	-- 1只怪兽可以装备的同盟最多1张
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UNION_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(c11678191.eqlimit)
	c:RegisterEffect(e6)
end
c11678191.old_union=true
-- 判断是否为战斗破坏
function c11678191.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 限制只能装备到「不屈斗士 磊磊」
function c11678191.eqlimit(e,c)
	return c:IsCode(84173492)
end
-- 筛选符合条件的装备目标怪兽
function c11678191.filter(c)
	return c:IsFaceup() and c:IsCode(84173492) and c:GetUnionCount()==0
end
-- 装备效果的处理函数
function c11678191.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c11678191.filter(chkc) end
	-- 判断是否满足装备条件
	if chk==0 then return e:GetHandler():GetFlagEffect(11678191)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断场上是否存在可装备的目标怪兽
		and Duel.IsExistingTarget(c11678191.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择装备目标怪兽
	local g=Duel.SelectTarget(tp,c11678191.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(11678191,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的发动处理函数
function c11678191.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c11678191.filter(tc) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将装备卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 为装备卡设置同盟状态
	aux.SetUnionState(c)
end
-- 特殊召唤效果的处理函数
function c11678191.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件
	if chk==0 then return e:GetHandler():GetFlagEffect(11678191)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(11678191,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的发动处理函数
function c11678191.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将装备卡以表侧攻击表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 改变表示形式效果的处理函数
function c11678191.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置改变表示形式效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler():GetEquipTarget(),1,0,0)
end
-- 改变表示形式效果的发动处理函数
function c11678191.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将装备怪兽的表示形式改变
		Duel.ChangePosition(c:GetEquipTarget(),POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
