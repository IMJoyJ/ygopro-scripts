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
	-- e2的发动条件为此卡处于同盟装备状态（即作为装备卡装备在怪兽身上时），满足“把装备解除”的前提。
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c19086954.sptg)
	e2:SetOperation(c19086954.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用时，装备怪兽的表示形式1回合只有1次可以变更。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19086954,2))  --"改变装备怪兽的表示形式"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	-- e3的发动条件为此卡处于同盟装备状态（作为装备卡装备在怪兽身上），才允许变更装备怪兽的表示形式。
	e3:SetCondition(aux.IsUnionState)
	e3:SetTarget(c19086954.postg)
	e3:SetOperation(c19086954.posop)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- e5的适用条件为此卡处于同盟装备状态，即只有作为装备卡时才承担代替破坏。
	e5:SetCondition(aux.IsUnionState)
	e5:SetValue(c19086954.repval)
	c:RegisterEffect(e5)
	-- 当作装备卡使用给自己的「巨大兽人」装备
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UNION_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(c19086954.eqlimit)
	c:RegisterEffect(e6)
end
c19086954.old_union=true
-- 代替破坏的值函数：判断所受破坏的原因是否为战斗破坏（REASON_BATTLE），仅战斗破坏时触发代替破坏。
function c19086954.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 同盟装备限制的值函数：只有卡号73698349（「巨大兽人」）才能作为这张卡同盟装备的对象。
function c19086954.eqlimit(e,c)
	return c:IsCode(73698349)
end
-- 装备对象过滤器：对象必须是表侧表示、卡号为73698349（「巨大兽人」）且没有装备任何同盟怪兽（对应“1只怪兽可以装备的同盟最多1张”）。
function c19086954.filter(c)
	return c:IsFaceup() and c:IsCode(73698349) and c:GetUnionCount()==0
end
-- 装备效果（e1）的目标处理函数：在发动时校验1回合1次的标志、魔陷区空位和可选对象；当连锁指定对象时，校验对象是自己场上符合条件的「巨大兽人」。
function c19086954.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19086954.filter(chkc) end
	-- 发动条件检查：此卡没有19086954标志（表示本回合尚未使用过“装备/解除装备”的1回合1次机会）且自己魔陷区有空位。
	if chk==0 then return e:GetHandler():GetFlagEffect(19086954)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 继续检查发动条件：自己怪兽区存在可以选择为装备对象的「巨大兽人」。
		and Duel.IsExistingTarget(c19086954.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 发送选择提示，让玩家知道接下来要选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己怪兽区选择1张符合条件的「巨大兽人」作为装备对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c19086954.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：本次连锁涉及装备（CATEGORY_EQUIP），对象是所选的1张怪兽，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(19086954,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果（e1）的处理函数：若本卡或对象仍关联且对象合法，则把本卡装备给对象并赋予同盟状态；若对象不合法则本卡送去墓地。
function c19086954.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的装备对象（第一目标卡）。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c19086954.filter(tc) then
		-- 当装备对象失去关联或不满足条件时，将本卡以效果原因送去墓地（装备处理失败）。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将本卡作为装备卡装备给目标「巨大兽人」；若装备失败则结束处理。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 为本卡设置同盟状态标记，使其后续可被识别为同盟装备卡。
	aux.SetUnionState(c)
end
-- 解除装备特殊召唤效果（e2）的发动条件函数：本回合未使用过“装备/解除装备”的次数、主要怪兽区有空位、且本卡可被特殊召唤为表侧攻击表示。
function c19086954.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本卡没有19086954标志（与装备效果合计1回合1次）且自己主要怪兽区有空余位置。
	if chk==0 then return e:GetHandler():GetFlagEffect(19086954)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 向对方玩家提示“对方选择了：”本效果，告知发动了解除装备并特殊召唤的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次连锁将进行特殊召唤（CATEGORY_SPECIAL_SUMMON），对象是本卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(19086954,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 解除装备特殊召唤的处理函数：若本卡仍与效果关联，则将其特殊召唤，完成“解除装备并特殊召唤”。
function c19086954.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将本卡以表侧攻击表示特殊召唤到自己场上；从魔陷区特殊召唤后不再作为装备卡，实现解除装备。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 变更表示形式效果（e3）的目标函数：发动时没有额外条件，向对方提示效果并指定装备怪兽为变更表示形式的对象。
function c19086954.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示“对方选择了：”本效果，告知发动了变更装备怪兽表示形式的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次连锁将改变表示形式（CATEGORY_POSITION），处理对象为本卡当前装备的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler():GetEquipTarget(),1,0,0)
end
-- 变更表示形式效果（e3）的处理函数：若本卡仍与效果关联，则将其装备怪兽的表示形式在表侧攻击/守备之间切换。
function c19086954.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将装备目标怪兽的表示形式改为：原表侧攻击变表侧守备，原表侧守备变表侧攻击（只切换表侧攻击与表侧守备）。
		Duel.ChangePosition(c:GetEquipTarget(),POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
