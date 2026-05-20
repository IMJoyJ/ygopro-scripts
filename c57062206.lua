--ドイツ
-- 效果：
-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「他者」装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用时，装备怪兽的攻击力上升2500点。（1只怪兽可以装备的同盟最多1张。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。）
function c57062206.initial_effect(c)
	-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「他者」装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57062206,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c57062206.eqtg)
	e1:SetOperation(c57062206.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57062206,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 设置特殊召唤效果的发动条件为：此卡处于同盟装备状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c57062206.sptg)
	e2:SetOperation(c57062206.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用时，装备怪兽的攻击力上升2500点。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(2500)
	-- 设置攻击力上升效果的适用条件为：此卡处于同盟装备状态
	e3:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设置代替破坏效果的适用条件为：此卡处于同盟装备状态
	e5:SetCondition(aux.IsUnionState)
	e5:SetValue(c57062206.repval)
	c:RegisterEffect(e5)
	-- 1只怪兽可以装备的同盟最多1张。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_UNION_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(c57062206.eqlimit)
	c:RegisterEffect(e6)
end
c57062206.old_union=true
-- 代替破坏的判定函数：如果是战斗破坏则可以代替
function c57062206.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 同盟装备限制函数：只能装备给「他者」
function c57062206.eqlimit(e,c)
	return c:IsCode(60246171)
end
-- 过滤函数：选择场上表侧表示、卡名为「他者」且未装备同盟怪兽的怪兽
function c57062206.filter(c)
	return c:IsFaceup() and c:IsCode(60246171) and c:GetUnionCount()==0
end
-- 装备效果的目标选择与发动准备函数
function c57062206.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c57062206.filter(chkc) end
	-- 检查本回合是否未使用过同盟效果，且魔法与陷阱区域有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(57062206)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以装备的「他者」
		and Duel.IsExistingTarget(c57062206.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只自己场上的「他者」作为装备对象
	local g=Duel.SelectTarget(tp,c57062206.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置效果处理信息：装备选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(57062206,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的执行函数
function c57062206.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为装备对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c57062206.filter(tc) then
		-- 若装备对象不合法，则将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将自身作为装备卡装备给目标怪兽，若失败则结束处理
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 设置此卡处于同盟装备状态
	aux.SetUnionState(c)
end
-- 特殊召唤效果的发动准备与合法性检查函数
function c57062206.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未使用过同盟效果，且主要怪兽区域有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(57062206)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 设置效果处理信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(57062206,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的执行函数
function c57062206.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧攻击表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
