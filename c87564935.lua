--メタル化寄生生物－ソルタイト
-- 效果：
-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽不会成为对方的效果怪兽的效果的对象，不会被对方的效果怪兽的效果破坏。（1只怪兽可以装备的同盟最多1张。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。）
function c87564935.initial_effect(c)
	-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87564935,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c87564935.eqtg)
	e1:SetOperation(c87564935.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87564935,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 限制该效果只能在自身作为同盟装备卡状态下发动。
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c87564935.sptg)
	e2:SetOperation(c87564935.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽不会成为对方的效果怪兽的效果的对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 限制该效果只能在自身作为同盟装备卡状态下适用。
	e3:SetCondition(aux.IsUnionState)
	e3:SetValue(c87564935.efilter1)
	c:RegisterEffect(e3)
	-- 不会被对方的效果怪兽的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 限制该效果只能在自身作为同盟装备卡状态下适用。
	e4:SetCondition(aux.IsUnionState)
	e4:SetValue(c87564935.efilter2)
	c:RegisterEffect(e4)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 限制该代替破坏效果只能在自身作为同盟装备卡状态下适用。
	e5:SetCondition(aux.IsUnionState)
	e5:SetValue(c87564935.repval)
	c:RegisterEffect(e5)
	-- 1只怪兽可以装备的同盟最多1张。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UNION_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
c87564935.old_union=true
-- 判定代替破坏的动因是否为战斗破坏。
function c87564935.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 过滤出场上表侧表示且未装备同盟怪兽的怪兽。
function c87564935.filter(c)
	return c:IsFaceup() and c:GetUnionCount()==0
end
-- 装备效果的发动条件判定与目标选择。
function c87564935.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c87564935.filter(chkc) end
	-- 检查本回合是否尚未发动过同盟效果，且魔法与陷阱区域有空位。
	if chk==0 then return e:GetHandler():GetFlagEffect(87564935)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以装备同盟怪兽的合法怪兽。
		and Duel.IsExistingTarget(c87564935.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的怪兽作为装备对象。
	local g=Duel.SelectTarget(tp,c87564935.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置效果处理信息为：将选中的1张卡进行装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(87564935,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的处理：将自身作为装备卡装备给目标怪兽。
function c87564935.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c87564935.filter(tc) then
		-- 若目标怪兽已不合法，则将自身送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将自身作为装备卡装备给目标怪兽，若装备失败则结束处理。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 将自身的状态设置为同盟装备状态。
	aux.SetUnionState(c)
end
-- 特殊召唤效果的发动条件判定与操作信息设置。
function c87564935.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否尚未发动过同盟效果，且主要怪兽区域有空位。
	if chk==0 then return e:GetHandler():GetFlagEffect(87564935)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 设置效果处理信息为：将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(87564935,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的处理：解除装备状态并将自身特殊召唤。
function c87564935.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 过滤出由对方玩家发动的怪兽效果。
function c87564935.efilter1(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤出由对方玩家拥有的怪兽效果。
function c87564935.efilter2(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER)
end
