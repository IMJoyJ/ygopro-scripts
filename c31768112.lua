--オイルメン
-- 效果：
-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的机械族怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，从卡组抽1张卡。（1只怪兽可以装备的同盟最多1张。装备怪兽被破坏的场合，作为代替把这张卡破坏。）
function c31768112.initial_effect(c)
	-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的机械族怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31768112,0))  --"破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c31768112.eqtg)
	e1:SetOperation(c31768112.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31768112,1))  --"抽卡"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 设置效果发动条件：这张卡必须处于同盟装备状态（即作为装备卡装备中），才能发动解除装备并特殊召唤的效果。
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c31768112.sptg)
	e2:SetOperation(c31768112.spop)
	c:RegisterEffect(e2)
	-- 装备怪兽被破坏的场合，作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设置代替破坏效果的条件：这张卡必须处于同盟装备状态（作为装备卡），才适用代替装备怪兽破坏的效果。
	e3:SetCondition(aux.IsUnionState)
	-- 设置代替破坏的判定函数：当装备怪兽将要被战斗或效果破坏时，用此过滤器判定是否为可代替的破坏（即由这张卡代替破坏）。
	e3:SetValue(aux.UnionReplaceFilter)
	c:RegisterEffect(e3)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，从卡组抽1张卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31768112,2))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c31768112.drcon)
	e4:SetTarget(c31768112.drtg)
	e4:SetOperation(c31768112.drop)
	c:RegisterEffect(e4)
	-- （1只怪兽可以装备的同盟最多1张。）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UNION_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c31768112.eqlimit)
	c:RegisterEffect(e5)
end
c31768112.old_union=true
-- 同盟怪兽的装备限制函数：判断目标怪兽是否为机械族，只有机械族怪兽才能装备此同盟怪兽（对应效果原文‘给自己场上的机械族怪兽装备’）。
function c31768112.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE)
end
-- 选择可装备的机械族怪兽：必须表侧表示、机械族，且该怪兽尚未装备任何同盟怪兽（保证1只怪兽最多装备1张同盟）。
function c31768112.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:GetUnionCount()==0
end
-- 装备效果的发动时处理：确认发动合法性（本回合未使用过该效果、自己魔陷区有空位、场上存在可装备的机械族怪兽），然后选择1只符合条件的机械族怪兽作为装备对象，并设置操作信息。
function c31768112.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31768112.filter(chkc) end
	-- 发动条件检查：这张卡本回合尚未使用过该效果（1回合1次），且自己的魔陷区有空位可供装备。
	if chk==0 then return e:GetHandler():GetFlagEffect(31768112)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己的怪兽区是否存在至少1只满足装备条件的机械族怪兽（排除本卡自身），作为装备对象。
		and Duel.IsExistingTarget(c31768112.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家发送选择提示：请选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只自己场上满足条件的机械族怪兽作为装备对象，并登记为效果对象。
	local g=Duel.SelectTarget(tp,c31768112.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：本次效果处理涉及装备分类（CATEGORY_EQUIP），对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(31768112,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果处理：确认自身和装备对象仍合法后，将这张卡作为装备卡装备给对象怪兽；若对象已不合法或自身离场，则这张卡送去墓地；装备成功后标记为同盟装备状态。
function c31768112.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的对象卡，即之前选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c31768112.filter(tc) then
		-- 若自身或装备对象已经不再适合装备（如对象变化或自身离场），则这张卡因效果处理失败送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作：将这张卡作为装备卡装备给目标怪兽；若装备失败（如被卡片效果限制），则终止处理。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 将这张卡标记为同盟装备状态，使其具备同盟怪兽作为装备卡时的相关属性，后续条件/效果可通过 aux.IsUnionState 识别。
	aux.SetUnionState(c)
end
-- 解除装备特殊召唤效果的发动时处理：确认本回合未使用过该效果、自己怪兽区有空位、自身能够特殊召唤，并设置操作信息。
function c31768112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：这张卡本回合尚未使用过该效果（与装备效果共用1回合1次），且自己的怪兽区有空位可供特殊召唤。
	if chk==0 then return e:GetHandler():GetFlagEffect(31768112)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 设置操作信息：本次效果处理涉及特殊召唤分类（CATEGORY_SPECIAL_SUMMON），对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(31768112,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 解除装备并特殊召唤的处理：确认这张卡仍在魔陷区且效果未被中断后，将其以表侧攻击表示特殊召唤到自己的怪兽区。
function c31768112.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤给自己（忽略召唤条件，但仍遵守苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 抽卡效果的发动条件：这张卡处于同盟装备状态，且以战斗破坏对方怪兽的怪兽正是装备着这张卡的怪兽。
function c31768112.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断：这张卡必须作为装备卡存在，且其装备对象（被装备的怪兽）正是本次战斗破坏对方怪兽的那只怪兽。
	return aux.IsUnionState(e) and e:GetHandler():GetEquipTarget()==eg:GetFirst()
end
-- 抽卡效果的发动时设定：无条件通过合法性检查；设置抽卡玩家为自己、抽卡数量为1，并登记操作信息。
function c31768112.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定本连锁的对象玩家为自己（tp），即由自己抽卡。
	Duel.SetTargetPlayer(tp)
	-- 设定本连锁的对象参数为1，即抽1张卡。
	Duel.SetTargetParam(1)
	-- 设置操作信息：效果分类为抽卡（CATEGORY_DRAW），抽卡玩家为自己，抽卡数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果处理：从连锁信息中取得抽卡玩家和抽卡数量，执行抽卡。
function c31768112.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家（p）和抽卡数量参数（d）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
