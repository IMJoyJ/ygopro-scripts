--六武衆の御霊代
-- 效果：
-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的名字带有「六武众」的怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽的攻击力·守备力上升500。装备怪兽战斗破坏对方怪兽的场合，自己从卡组抽1张卡。（1只怪兽可以装备的同盟最多1张。装备怪兽被破坏的场合，作为代替把这张卡破坏。）
function c65685470.initial_effect(c)
	-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的名字带有「六武众」的怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65685470,0))  --"变成装备卡"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c65685470.eqtg)
	e1:SetOperation(c65685470.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65685470,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 设置特殊召唤效果的触发条件为：这张卡处于同盟装备状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c65685470.sptg)
	e2:SetOperation(c65685470.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽的攻击力上升500
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	-- 设置攻击力上升效果的触发条件为：这张卡处于同盟装备状态
	e3:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e3)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽的守备力上升500
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(500)
	-- 设置守备力上升效果的触发条件为：这张卡处于同盟装备状态
	e4:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e4)
	-- 装备怪兽被破坏的场合，作为代替把这张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设置代替破坏效果的触发条件为：这张卡处于同盟装备状态
	e5:SetCondition(aux.IsUnionState)
	-- 设置代替破坏的过滤条件（战斗或效果破坏）
	e5:SetValue(aux.UnionReplaceFilter)
	c:RegisterEffect(e5)
	-- 装备怪兽战斗破坏对方怪兽的场合，自己从卡组抽1张卡。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(65685470,2))  --"抽卡"
	e6:SetCategory(CATEGORY_DRAW)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_BATTLE_DESTROYING)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c65685470.drcon)
	e6:SetTarget(c65685470.drtg)
	e6:SetOperation(c65685470.drop)
	c:RegisterEffect(e6)
	-- 1只怪兽可以装备的同盟最多1张。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UNION_LIMIT)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetValue(c65685470.eqlimit)
	c:RegisterEffect(e7)
end
c65685470.old_union=true
-- 同盟装备限制：只能装备给名字带有「六武众」的怪兽
function c65685470.eqlimit(e,c)
	return c:IsSetCard(0x103d)
end
-- 过滤条件：场上表侧表示、名字带有「六武众」且未装备同盟怪兽的怪兽
function c65685470.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and c:GetUnionCount()==0
end
-- 装备效果的目标选择与合法性检测函数
function c65685470.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c65685470.filter(chkc) end
	-- 检测本回合是否未使用过同盟效果，且魔陷区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(65685470)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检测自己场上是否存在可以装备的「六武众」怪兽
		and Duel.IsExistingTarget(c65685470.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的「六武众」怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c65685470.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置效果处理信息：装备选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(65685470,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的执行函数
function c65685470.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c65685470.filter(tc) then
		-- 若目标怪兽已不符合条件，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽，若失败则结束
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 将这张卡的状态设置为同盟装备状态
	aux.SetUnionState(c)
end
-- 特殊召唤效果的目标选择与合法性检测函数
function c65685470.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测本回合是否未使用过同盟效果，且怪兽区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(65685470)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 设置效果处理信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(65685470,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的执行函数
function c65685470.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 抽卡效果的发动条件函数
function c65685470.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测这张卡是否处于同盟装备状态，且装备怪兽是战斗破坏对方怪兽的怪兽
	return aux.IsUnionState(e) and e:GetHandler():GetEquipTarget()==eg:GetFirst()
end
-- 抽卡效果的目标选择与合法性检测函数
function c65685470.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡效果的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1张
	Duel.SetTargetParam(1)
	-- 设置效果处理信息：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的执行函数
function c65685470.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果
	Duel.Draw(p,d,REASON_EFFECT)
end
