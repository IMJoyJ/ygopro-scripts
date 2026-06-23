--スーパービークロイド－ステルス・ユニオン
-- 效果：
-- 「卡车机人」＋「特快机人」＋「钻头机人」＋「隐形机人」
-- 1回合1次，自己的主要阶段时可以选择场上存在的1只机械族以外的怪兽，当作装备卡使用给这张卡装备。因这个效果有怪兽装备的场合，可以向对方场上的全部怪兽各作1次攻击。这张卡攻击的场合，这张卡的原本攻击力变成一半数值。这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c3897065.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为61538782,98049038,71218746,984114的4只怪兽为融合素材
	aux.AddFusionProcCode4(c,61538782,98049038,71218746,984114,true,true)
	-- 1回合1次，自己的主要阶段时可以选择场上存在的1只机械族以外的怪兽，当作装备卡使用给这张卡装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3897065,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c3897065.eqtg)
	e1:SetOperation(c3897065.eqop)
	c:RegisterEffect(e1)
	-- 因这个效果有怪兽装备的场合，可以向对方场上的全部怪兽各作1次攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetCondition(c3897065.atcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这张卡攻击的场合，这张卡的原本攻击力变成一半数值
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetOperation(c3897065.atkop)
	c:RegisterEffect(e4)
end
-- 过滤满足条件的怪兽：场上正面表示、非机械族、属于玩家或可改变控制权
function c3897065.eqfilter(c,tp)
	return c:IsFaceup() and not c:IsRace(RACE_MACHINE) and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
-- 设置效果目标：选择场上1只满足条件的怪兽作为装备对象
function c3897065.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c3897065.eqfilter(chkc,tp) end
	-- 判断是否满足发动条件：玩家魔陷区有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足发动条件：场上存在满足条件的怪兽
		and Duel.IsExistingTarget(c3897065.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler(),tp) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c3897065.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler(),tp)
end
-- 设置装备对象限制函数：只有装备者自己才能装备
function c3897065.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行装备操作：将选中的怪兽装备给此卡，并注册装备限制和装备效果
function c3897065.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and not tc:IsRace(RACE_MACHINE) and tc:IsRelateToEffect(e) then
		-- 尝试将目标怪兽装备给此卡，失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 注册装备对象限制效果：只有此卡能装备该怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c3897065.eqlimit)
		tc:RegisterEffect(e1)
		-- 注册装备效果：装备的怪兽获得此卡的特殊效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(3897065)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 判断是否装备了怪兽：此卡是否具有装备效果
function c3897065.atcon(e)
	return e:GetHandler():IsHasEffect(3897065)
end
-- 攻击宣言时执行：将此卡原本攻击力减半
function c3897065.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local atk=c:GetBaseAttack()
	-- 设置此卡攻击力为原本攻击力的一半
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
	e1:SetValue(math.ceil(atk/2))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
	c:RegisterEffect(e1)
end
