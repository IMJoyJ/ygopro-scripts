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
	-- 设置解除装备特殊召唤效果的发动条件为这张卡当前处于同盟装备状态
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
	-- 设置改变装备怪兽表示形式的效果仅在同盟装备状态下可以发动
	e3:SetCondition(aux.IsUnionState)
	e3:SetTarget(c11678191.postg)
	e3:SetOperation(c11678191.posop)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设置代替破坏效果仅在同盟装备状态下适用
	e5:SetCondition(aux.IsUnionState)
	e5:SetValue(c11678191.repval)
	c:RegisterEffect(e5)
	-- 给自己的「不屈斗士 磊磊」装备
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UNION_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(c11678191.eqlimit)
	c:RegisterEffect(e6)
end
c11678191.old_union=true
-- 代替破坏判定：当装备怪兽将要被战斗破坏时返回真，表示由这张卡代替破坏
function c11678191.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 限制同盟装备对象：只有卡号为84173492的「不屈斗士 磊磊」才能被这张卡装备
function c11678191.eqlimit(e,c)
	return c:IsCode(84173492)
end
-- 装备对象过滤条件：表侧表示、是「不屈斗士 磊磊」、且未装备其他同盟卡（保证1只怪兽最多装备1张同盟）
function c11678191.filter(c)
	return c:IsFaceup() and c:IsCode(84173492) and c:GetUnionCount()==0
end
-- 装备效果的发动条件与取对象处理：确认本回合未用过该效果、魔陷区有空位、存在符合条件的装备对象；若满足则选择对象
function c11678191.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c11678191.filter(chkc) end
	-- 检查发动条件前半：通过flag标记保证该效果1回合只能发动1次，且我方魔陷区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(11678191)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查存在表侧表示且未装备同盟的「不屈斗士 磊磊」可以作为装备对象
		and Duel.IsExistingTarget(c11678191.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 给玩家显示“请选择要装备的卡”的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只符合条件的「不屈斗士 磊磊」作为装备对象，并将其锁定为效果对象
	local g=Duel.SelectTarget(tp,c11678191.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：本次连锁为装备效果，对象为选定的怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(11678191,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果处理：若这张卡或对象失去关联/不合法则送墓；否则将这张卡装备给对象并标记为同盟状态
function c11678191.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时锁定的装备对象（目标怪兽）
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c11678191.filter(tc) then
		-- 当装备目标不再合法或与效果失去关联时，将这张卡送去墓地（装备失败）
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给对象且不改变其表示形式；装备失败则中止处理
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 将这张卡标记为同盟装备状态，使其后的同盟相关效果（解除特殊召唤、变表示、代替破坏）生效
	aux.SetUnionState(c)
end
-- 解除装备特殊召唤效果的发动条件：本回合未用过该效果、主怪兽区有空位、自身可以表侧攻击表示特殊召唤
function c11678191.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件检查前半：本回合效果未被使用过，且我方主怪兽区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(11678191)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 向对方玩家提示选择了“解除装备状态表侧攻击表示特殊召唤”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次连锁为特殊召唤效果，目标为这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(11678191,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤处理：若效果仍与这张卡关联，则将其特殊召唤
function c11678191.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤（无视召唤条件，保留苏生限制）
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 改变装备怪兽表示形式效果的发动条件与处理设定：无条件可发动，发动时提示对方并设置改变表示形式的操作信息
function c11678191.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示选择了“改变装备怪兽的表示形式”的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：改变表示形式，对象为装备了这张卡的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler():GetEquipTarget(),1,0,0)
end
-- 改变表示形式的处理：若效果仍关联，则变更装备怪兽的表示形式
function c11678191.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将装备怪兽的表示形式在表侧攻击与表侧守备之间切换（表攻变表守，表守变表攻）
		Duel.ChangePosition(c:GetEquipTarget(),POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
