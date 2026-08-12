--メタル化寄生生物－ルナタイト
-- 效果：
-- 1回合只有1次，在自己的主要阶段，场上的这张卡可以当作装备卡使用给自己场上的表侧表示怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。装备怪兽不受对方所控制的魔法卡效果的影响。（1只怪兽可以装备的同盟最多1张，装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。）
function c7369217.initial_effect(c)
	-- 1回合只有1次，在自己的主要阶段，场上的这张卡可以当作装备卡使用给自己场上的表侧表示怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7369217,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c7369217.eqtg)
	e1:SetOperation(c7369217.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7369217,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 设置效果发动条件为：这张卡处于同盟装备状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c7369217.sptg)
	e2:SetOperation(c7369217.spop)
	c:RegisterEffect(e2)
	-- 装备怪兽不受对方所控制的魔法卡效果的影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	-- 设置效果发动条件为：这张卡处于同盟装备状态
	e3:SetCondition(aux.IsUnionState)
	e3:SetValue(c7369217.efilter)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设置效果发动条件为：这张卡处于同盟装备状态
	e5:SetCondition(aux.IsUnionState)
	e5:SetValue(c7369217.repval)
	c:RegisterEffect(e5)
	-- 1只怪兽可以装备的同盟最多1张
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UNION_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
c7369217.old_union=true
-- 代替破坏的判定：如果是因战斗破坏，则可以代替
function c7369217.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 过滤条件：选择自己场上表侧表示且未装备同盟怪兽的怪兽
function c7369217.filter(c)
	return c:IsFaceup() and c:GetUnionCount()==0
end
-- 装备效果的Target函数：进行效果发动的合法性检测并选择装备对象
function c7369217.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7369217.filter(chkc) end
	-- 检测本回合是否未使用过同盟效果，且自己魔陷区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(7369217)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检测自己场上是否存在可以装备同盟的合法怪兽
		and Duel.IsExistingTarget(c7369217.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c7369217.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(7369217,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的Operation函数：执行装备处理
function c7369217.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c7369217.filter(tc) then
		-- 如果装备对象已不合法，则将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将自身作为装备卡装备给目标怪兽，若失败则结束
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 设置同盟装备状态
	aux.SetUnionState(c)
end
-- 特殊召唤效果的Target函数：进行效果发动的合法性检测
function c7369217.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测本回合是否未使用过同盟效果，且自己怪兽区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(7369217)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(7369217,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的Operation函数：执行特殊召唤处理
function c7369217.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧攻击表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 免疫效果过滤器：不受对方控制的魔法卡效果影响
function c7369217.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL)
end
