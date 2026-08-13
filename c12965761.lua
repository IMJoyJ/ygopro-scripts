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
	-- 设置效果e2的发动条件为此卡处于同盟装备状态，即只有作为装备卡装备中才能发动解除装备并特殊召唤的效果。
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
	-- 设置效果e4的发动条件为此卡处于同盟装备状态，即仅在作为装备卡装备中才适用代替破坏效果。
	e4:SetCondition(aux.IsUnionState)
	e4:SetValue(c12965761.repval)
	c:RegisterEffect(e4)
	-- 给自己的「血兰」装备
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_UNION_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c12965761.eqlimit)
	c:RegisterEffect(e5)
end
c12965761.old_union=true
-- 代替破坏的效果值：判断破坏原因是否包含战斗破坏，只有装备怪兽被战斗破坏时才允许用此卡代替破坏。
function c12965761.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 定义同盟装备限制：此卡只能装备给卡号为46571052的「血兰」。
function c12965761.eqlimit(e,c)
	return c:IsCode(46571052)
end
-- 过滤可装备对象：需要是表侧表示的血兰，且当前没有装备着其他同盟怪兽（GetUnionCount()==0）。
function c12965761.filter(c)
	return c:IsFaceup() and c:IsCode(46571052) and c:GetUnionCount()==0
end
-- 装备效果的发动条件和对象选择：检查1回合1次标志、魔陷区空格，并在己方主要怪兽区选择满足条件的血兰作为对象；连锁选择对象时也验证对象合法性。
function c12965761.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12965761.filter(chkc) end
	-- 发动条件前半：本回合此卡尚未用flag记录发动过此装备效果（1回合1次），且自己魔陷区有可用空格。
	if chk==0 then return e:GetHandler():GetFlagEffect(12965761)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件后半：己方主要怪兽区存在1只可成为装备对象的血兰（除了自己）。
		and Duel.IsExistingTarget(c12965761.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向操作玩家显示“请选择要装备的卡”的提示消息，准备选择装备对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让操作玩家从己方主要怪兽区选择1只满足filter的血兰，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c12965761.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：本连锁将进行装备类效果，对象为选中的血兰，数量1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(12965761,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果处理：验证自身和对象仍合法；若对象或自身不合法则把自身送墓地；否则将自身装备到血兰上并标记为同盟状态。
function c12965761.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的装备对象（血兰）。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c12965761.filter(tc) then
		-- 当对象或自身不再满足条件时，把死亡石斛以效果原因送去墓地，表示装备解除失败/装备无效。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 尝试将死亡石斛作为装备卡装备给血兰；若因区域或状态等原因无法装备则中止处理。
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 为死亡石斛设定同盟装备状态标记，使aux.IsUnionState条件成立。
	aux.SetUnionState(c)
end
-- 特殊召唤效果的发动条件：本回合未发动过该效果、主要怪兽区有空位、自身可以表侧攻击表示特殊召唤；满足才可发动。
function c12965761.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件前半：本回合此卡尚未发动过该特殊召唤效果（1回合1次），且自己主要怪兽区有空位。
	if chk==0 then return e:GetHandler():GetFlagEffect(12965761)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 向对方玩家提示已选择的特殊召唤效果描述，方便对方知道发动的是哪个效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本效果将把死亡石斛特殊召唤，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(12965761,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤处理：若此卡仍与效果关联，则将其特殊召唤。
function c12965761.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以表侧攻击表示将死亡石斛特殊召唤到自己场上，忽略召唤条件且不检查苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 衍生物诱发效果的条件判定：本卡处于同盟装备状态，且战斗中被破坏并送去墓地的怪兽就是本卡装备的怪兽。
function c12965761.tkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：eg第一张（被战斗破坏的怪兽）必须等于这张卡当前装备的对象，才触发衍生物效果。
	return aux.IsUnionState(e) and eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 衍生物效果的发动不可选：只要条件满足必定发动；设置操作信息为特殊召唤1只衍生物。
function c12965761.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本效果包含生成衍生物，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本效果包含特殊召唤，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 衍生物特殊召唤处理：检查主要怪兽区空位与衍生物召唤许可，满足则生成并特殊召唤一只魔草衍生物。
function c12965761.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的主要怪兽区没有空位，无法特殊召唤衍生物，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤一只卡号12965762的魔草衍生物（植物族、地、1星、攻/守800、表侧表示）。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,12965762,0,TYPES_TOKEN_MONSTER,800,800,1,RACE_PLANT,ATTRIBUTE_EARTH) then
		-- 创建一只卡号12965762的「魔草衍生物」衍生物。
		local token=Duel.CreateToken(tp,12965762)
		-- 将生成的魔草衍生物以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
