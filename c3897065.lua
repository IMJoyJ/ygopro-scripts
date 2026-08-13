--スーパービークロイド－ステルス・ユニオン
-- 效果：
-- 「卡车机人」＋「特快机人」＋「钻头机人」＋「隐形机人」
-- 1回合1次，自己的主要阶段时可以选择场上存在的1只机械族以外的怪兽，当作装备卡使用给这张卡装备。因这个效果有怪兽装备的场合，可以向对方场上的全部怪兽各作1次攻击。这张卡攻击的场合，这张卡的原本攻击力变成一半数值。这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c3897065.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，素材为「卡车机人」「特快机人」「钻头机人」「隐形机人」，允许使用融合素材代用品等规则。
	aux.AddFusionProcCode4(c,61538782,98049038,71218746,984114,true,true)
	-- 1回合1次，自己的主要阶段时可以选择场上存在的1只机械族以外的怪兽，当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3897065,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c3897065.eqtg)
	e1:SetOperation(c3897065.eqop)
	c:RegisterEffect(e1)
	-- 因这个效果有怪兽装备的场合，可以向对方场上的全部怪兽各作1次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetCondition(c3897065.atcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- 这张卡攻击的场合，这张卡的原本攻击力变成一半数值。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetOperation(c3897065.atkop)
	c:RegisterEffect(e4)
end
-- 筛选可作为装备对象的怪兽：表侧表示、机械族以外，且为我方场上怪兽或可以变更控制权的对方场上怪兽。
function c3897065.eqfilter(c,tp)
	return c:IsFaceup() and not c:IsRace(RACE_MACHINE) and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
-- 效果发动时的目标处理：若指定卡片则检查其位于怪兽区且满足装备条件；若为发动时点检查，则确认魔陷区有空位且存在合法目标。
function c3897065.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c3897065.eqfilter(chkc,tp) end
	-- 发动条件检查：我方魔陷区必须至少有1个空位，用于放置要装备的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：场上必须存在至少1只满足装备条件的机械族以外怪兽，且排除发动效果的本卡。
		and Duel.IsExistingTarget(c3897065.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) end
	-- 向操作玩家显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区选择1只满足条件的机械族以外怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c3897065.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),tp)
end
-- 装备限制函数：作为装备卡的怪兽只能装备给该效果的持有者，即本卡。
function c3897065.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：将目标怪兽装备给本卡；装备失败则终止；成功后给该装备怪兽注册装备限制和特殊标记，用于后续攻击判定。
function c3897065.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and not tc:IsRace(RACE_MACHINE) and tc:IsRelateToEffect(e) then
		-- 尝试将目标怪兽当作装备卡装备给本卡，如果装备失败则直接结束效果处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c3897065.eqlimit)
		tc:RegisterEffect(e1)
		-- 因这个效果有怪兽装备的场合。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(3897065)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 追加全体攻击的条件：本卡当前有通过自身效果装备的怪兽，即存在标记效果3897065。
function c3897065.atcon(e)
	return e:GetHandler():IsHasEffect(3897065)
end
-- 攻击宣言时的处理：将本卡原本攻击力变更为当前原本攻击力的一半（向上取整），并持续到伤害阶段结束。
function c3897065.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=c:GetBaseAttack()
	-- 这张卡攻击的场合，这张卡的原本攻击力变成一半数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
	e1:SetValue(math.ceil(atk/2))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	c:RegisterEffect(e1)
end
