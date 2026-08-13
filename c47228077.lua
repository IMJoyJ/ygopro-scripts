--ヴァイロン・ペンタクロ
-- 效果：
-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的名字带有「大日」的怪兽装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，可以选择对方场上1张卡破坏。（1只怪兽可以装备的同盟最多1张。装备怪兽被破坏的场合，作为代替把这张卡破坏。）
function c47228077.initial_effect(c)
	-- 1回合1次，自己的主要阶段时可以当作装备卡使用给自己场上的名字带有「大日」的怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47228077,0))  --"变成装备卡"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c47228077.eqtg)
	e1:SetOperation(c47228077.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47228077,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 设定解除装备效果仅在自身处于同盟装备状态（作为装备卡）时才能发动
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c47228077.sptg)
	e2:SetOperation(c47228077.spop)
	c:RegisterEffect(e2)
	-- 装备怪兽被破坏的场合，作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设定代替破坏效果仅当这张卡处于同盟装备状态时才适用
	e3:SetCondition(aux.IsUnionState)
	-- 设置代替破坏的条件：装备怪兽因战斗或效果被破坏时，由这张卡代替破坏
	e3:SetValue(aux.UnionReplaceFilter)
	c:RegisterEffect(e3)
	-- 只在这个效果当作装备卡使用的场合，装备怪兽战斗破坏对方怪兽的场合，可以选择对方场上1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(47228077,2))  --"对方场上的1张卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c47228077.descon)
	e4:SetTarget(c47228077.destg)
	e4:SetOperation(c47228077.desop)
	c:RegisterEffect(e4)
	-- 1只怪兽可以装备的同盟最多1张。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UNION_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c47228077.eqlimit)
	c:RegisterEffect(e5)
end
c47228077.old_union=true
-- 判定可装备的怪兽必须是名字带有「大日」的怪兽，即同盟装备限制只允许装备给「大日」怪兽
function c47228077.eqlimit(e,c)
	return c:IsSetCard(0x30)
end
-- 筛选装备对象：表侧表示、名字带有「大日」、且该怪兽当前没有装备任何同盟怪兽
function c47228077.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x30) and c:GetUnionCount()==0
end
-- 装备效果的发动条件与取对象处理：确认有可装备的「大日」怪兽，且本回合未发动过该效果；若指定对象则进一步验证该对象是否合法
function c47228077.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c47228077.filter(chkc) end
	-- 发动条件确认：这张卡本回合尚未使用过该效果（1回合1次限制），且自己魔陷区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(47228077)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且自己场上存在至少1只满足条件（表侧表示·「大日」·无同盟装备）的「大日」怪兽，可以作为装备对象
		and Duel.IsExistingTarget(c47228077.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡，显示“请选择要装备的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上的符合条件的「大日」怪兽中选择1只，并将其设为效果对象
	local g=Duel.SelectTarget(tp,c47228077.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 将本次操作信息标记为装备（CATEGORY_EQUIP），处理时将选择的怪兽作为装备对象
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(47228077,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的处理：将这张卡装备给目标「大日」怪兽；若自身或目标变得不合法，则将这张卡送去墓地；成功装备后设置同盟装备状态
function c47228077.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果选择的目标「大日」怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c47228077.filter(tc) then
		-- 当这张卡不再与效果关联、变成里侧表示，或目标不合法时，将这张卡以效果原因送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将这张卡作为装备卡装备给目标怪兽；若装备失败（例如没有可用魔陷区）则直接结束处理
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 装备成功后，为这张卡添加同盟装备状态标记（使其作为装备卡时获得同盟属性）
	aux.SetUnionState(c)
end
-- 特殊召唤效果的发动条件：确认本回合未发动过该效果、自己场上有空余怪兽区，且这张卡能以表侧攻击表示特殊召唤
function c47228077.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件确认：这张卡没有使用过本回合的1回合1次效果机会，且自己场上有可用的怪兽区空格
	if chk==0 then return e:GetHandler():GetFlagEffect(47228077)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 将本次操作信息标记为特殊召唤（CATEGORY_SPECIAL_SUMMON），预定特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(47228077,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的处理：将这张卡从魔陷区以表侧攻击表示特殊召唤到场上
function c47228077.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 实际执行特殊召唤：无视召唤条件与苏生限制，以表侧攻击表示将这张卡特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 战斗破坏诱发效果的发动条件：这张卡处于同盟装备状态，且装备怪兽战斗破坏了对方怪兽
function c47228077.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断满足同盟装备状态，并且当前战斗破坏对方怪兽的怪兽正是这张卡装备的怪兽（eg:GetFirst()）
	return aux.IsUnionState(e) and e:GetHandler():GetEquipTarget()==eg:GetFirst()
end
-- 破坏效果的发动条件与取对象选择：选择对方场上1张卡作为破坏对象，并设置操作信息
function c47228077.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动条件确认：对方场上有至少1张卡可以成为效果对象
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡，显示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为破坏对象，并设为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 将本次操作信息标记为破坏（CATEGORY_DESTROY），对象为选择的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理：若选择的对象仍与效果关联，则将其破坏
function c47228077.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要破坏的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
