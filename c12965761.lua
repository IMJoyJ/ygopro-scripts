--デス・デンドル
-- 效果：
-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「血兰」装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用时，装备怪兽每次战斗破坏怪兽时把1只「魔草衍生物」（植物族·地·1星·攻/守800）特殊召唤。（1只怪兽可以装备的同盟最多1张。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。）
function c12965761.initial_effect(c)
	-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「血兰」装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12965761,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c12965761.eqtg)
	e1:SetOperation(c12965761.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12965761,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c12965761.sptg)
	e2:SetOperation(c12965761.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用时，装备怪兽每次战斗破坏怪兽时把1只「魔草衍生物」（植物族·地·1星·攻/守800）特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(12965761,2))  --"特殊召唤衍生物"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c12965761.tkcon)
	e3:SetTarget(c12965761.tktg)
	e3:SetOperation(c12965761.tkop)
	c:RegisterEffect(e3)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 检查同盟怪兽是否处于同盟装备的状态
	e4:SetCondition(aux.IsUnionState)
	e4:SetValue(c12965761.repval)
	c:RegisterEffect(e4)
	-- 1只怪兽可以装备的同盟最多1张
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UNION_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c12965761.eqlimit)
	c:RegisterEffect(e5)
end
c12965761.old_union=true
-- 判断是否为战斗破坏的破坏原因
function c12965761.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 判断装备怪兽是否为「血兰」
function c12965761.eqlimit(e,c)
	return c:IsCode(46571052)
end
-- 筛选满足条件的「血兰」怪兽
function c12965761.filter(c)
	return c:IsFaceup() and c:IsCode(46571052) and c:GetUnionCount()==0
end
-- 设置装备卡效果的发动条件和处理函数
function c12965761.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12965761.filter(chkc) end
	-- 判断是否已发动过效果
	if chk==0 then return e:GetHandler():GetFlagEffect(12965761)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断场上是否有满足条件的「血兰」怪兽
		and Duel.IsExistingTarget(c12965761.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择装备对象
	local g=Duel.SelectTarget(tp,c12965761.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(12965761,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 设置装备卡效果的发动条件和处理函数
function c12965761.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备对象
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c12965761.filter(tc) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 为装备卡添加同盟怪兽属性
	aux.SetUnionState(c)
end
-- 设置特殊召唤效果的发动条件和处理函数
function c12965761.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否已发动过效果
	if chk==0 then return e:GetHandler():GetFlagEffect(12965761)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 提示对方玩家选择发动了什么效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(12965761,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 设置特殊召唤效果的发动条件和处理函数
function c12965761.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将装备卡特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 设置战斗破坏时的触发效果条件
function c12965761.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为同盟状态且被战斗破坏的怪兽为装备对象
	return aux.IsUnionState(e) and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 设置战斗破坏时的触发效果处理函数
function c12965761.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置衍生物的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤衍生物的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 设置战斗破坏时的触发效果处理函数
function c12965761.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断是否可以特殊召唤衍生物
	if Duel.IsPlayerCanSpecialSummonMonster(tp,12965762,0,TYPES_TOKEN_MONSTER,800,800,1,RACE_PLANT,ATTRIBUTE_EARTH) then
		-- 创建衍生物
		local token=Duel.CreateToken(tp,12965762)
		-- 将衍生物特殊召唤
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
