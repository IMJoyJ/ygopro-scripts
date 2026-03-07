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
	-- 检查当前效果是否处于同盟装备状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c31768112.sptg)
	e2:SetOperation(c31768112.spop)
	c:RegisterEffect(e2)
	-- 装备怪兽被破坏的场合，作为代替把这张卡破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 检查当前效果是否处于同盟装备状态
	e3:SetCondition(aux.IsUnionState)
	-- 设置装备卡被破坏时的代替处理过滤器
	e3:SetValue(aux.UnionReplaceFilter)
	c:RegisterEffect(e3)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，从卡组抽1张卡
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
	-- 1只怪兽可以装备的同盟最多1张
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UNION_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c31768112.eqlimit)
	c:RegisterEffect(e5)
end
c31768112.old_union=true
-- 限制装备怪兽必须为机械族
function c31768112.eqlimit(e,c)
	return c:IsRace(RACE_MACHINE)
end
-- 筛选场上正面表示的机械族怪兽且未被同盟装备的怪兽
function c31768112.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:GetUnionCount()==0
end
-- 设置装备效果的筛选条件，选择场上正面表示的机械族怪兽
function c31768112.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31768112.filter(chkc) end
	-- 检查是否已使用过此效果且场上存在装备区域
	if chk==0 then return e:GetHandler():GetFlagEffect(31768112)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在符合条件的机械族怪兽
		and Duel.IsExistingTarget(c31768112.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c31768112.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(31768112,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 执行装备操作，若失败则将装备卡送入墓地
function c31768112.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c31768112.filter(tc) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将装备卡装备给目标怪兽
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 为装备卡设置同盟状态
	aux.SetUnionState(c)
end
-- 设置特殊召唤效果的筛选条件
function c31768112.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已使用过此效果且场上存在召唤区域
	if chk==0 then return e:GetHandler():GetFlagEffect(31768112)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(31768112,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 执行特殊召唤操作
function c31768112.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将装备卡以表侧攻击表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 设置抽卡效果的触发条件
function c31768112.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前效果是否处于同盟装备状态且装备怪兽为战斗破坏对象
	return aux.IsUnionState(e) and e:GetHandler():GetEquipTarget()==eg:GetFirst()
end
-- 设置抽卡效果的操作信息
function c31768112.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的抽卡数量
	Duel.SetTargetParam(1)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作
function c31768112.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
