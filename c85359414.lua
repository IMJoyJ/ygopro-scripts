--氷岩魔獣
-- 效果：
-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「灼岩魔兽」装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用时，装备怪兽对对方造成战斗伤害的场合，破坏场上1张里侧表示的魔法或者陷阱卡。（1只怪兽可以装备的同盟最多1张。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。）
function c85359414.initial_effect(c)
	-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「灼岩魔兽」装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85359414,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c85359414.eqtg)
	e1:SetOperation(c85359414.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85359414,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 设置特殊召唤效果的发动条件为：此卡处于同盟装备状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c85359414.sptg)
	e2:SetOperation(c85359414.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用时，装备怪兽对对方造成战斗伤害的场合，破坏场上1张里侧表示的魔法或者陷阱卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85359414,2))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c85359414.descon)
	e3:SetTarget(c85359414.destg)
	e3:SetOperation(c85359414.desop)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设置代替破坏效果的适用条件为：此卡处于同盟装备状态
	e4:SetCondition(aux.IsUnionState)
	e4:SetValue(c85359414.repval)
	c:RegisterEffect(e4)
	-- （1只怪兽可以装备的同盟最多1张。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UNION_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c85359414.eqlimit)
	c:RegisterEffect(e5)
end
c85359414.old_union=true
-- 代替破坏的判定：如果是战斗破坏则可以代替
function c85359414.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 同盟装备限制：只能装备给「灼岩魔兽」（卡号59364406）
function c85359414.eqlimit(e,c)
	return c:IsCode(59364406)
end
-- 过滤条件：场上表侧表示、卡名为「灼岩魔兽」且未装备同盟怪兽的怪兽
function c85359414.filter(c)
	return c:IsFaceup() and c:IsCode(59364406) and c:GetUnionCount()==0
end
-- 装备效果的靶向与发动准备函数
function c85359414.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c85359414.filter(chkc) end
	-- 若为检查阶段：检查本回合是否尚未发动过同盟效果，且魔陷区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(85359414)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且自己场上存在可以装备的「灼岩魔兽」
		and Duel.IsExistingTarget(c85359414.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的「灼岩魔兽」作为效果对象
	local g=Duel.SelectTarget(tp,c85359414.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：分类为装备，操作对象为选择的怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(85359414,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的执行函数
function c85359414.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c85359414.filter(tc) then
		-- 若目标怪兽已不符合条件，则将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将自身作为装备卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 设置此卡处于同盟装备状态
	aux.SetUnionState(c)
end
-- 特殊召唤效果的发动准备函数
function c85359414.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检查阶段：检查本回合是否尚未发动过同盟效果，且怪兽区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(85359414)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 向对方玩家提示发动了特殊召唤效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：分类为特殊召唤，操作对象为自身，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(85359414,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的执行函数
function c85359414.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧攻击表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 破坏效果的发动条件检查函数
function c85359414.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回：此卡处于同盟装备状态，且装备怪兽对对方造成了战斗伤害
	return aux.IsUnionState(e) and ep~=tp and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 过滤条件：里侧表示的卡
function c85359414.desfilter(c)
	return c:IsFacedown()
end
-- 破坏效果的靶向与发动准备函数
function c85359414.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c85359414.desfilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张里侧表示的魔法或陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c85359414.desfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	-- 设置操作信息：分类为破坏，操作对象为选择的卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行函数
function c85359414.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要破坏的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 破坏目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
