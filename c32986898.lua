--粛星の鋼機
-- 效果：
-- 连接怪兽以外的怪兽3只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升作为这张卡的连接素材的怪兽的原本的等级·阶级的合计×100。
-- ②：以持有这张卡的攻击力以下的攻击力的除连接怪兽以外的对方场上1只怪兽为对象才能发动。那只怪兽破坏。这张卡用超量怪兽为素材作连接召唤的场合，再给与对方破坏的怪兽的原本攻击力一半数值的伤害。
function c32986898.initial_effect(c)
	-- 添加连接召唤手续，要求使用非连接怪兽作为素材，数量为3只
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_LINK)),3,3)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升作为这张卡的连接素材的怪兽的原本的等级·阶级的合计×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c32986898.atkcon)
	e1:SetOperation(c32986898.atkop)
	c:RegisterEffect(e1)
	-- ②：以持有这张卡的攻击力以下的攻击力的除连接怪兽以外的对方场上1只怪兽为对象才能发动。那只怪兽破坏。这张卡用超量怪兽为素材作连接召唤的场合，再给与对方破坏的怪兽的原本攻击力一半数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32986898,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,32986898)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c32986898.destg)
	e2:SetOperation(c32986898.desop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c32986898.valcheck)
	c:RegisterEffect(e4)
	e4:SetLabelObject(e1)
end
-- 判断此卡是否为连接召唤成功
function c32986898.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 计算连接素材的等级或阶级总和，并提升自身攻击力
function c32986898.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	local atk=0
	local tc=g:GetFirst()
	while tc do
		local lk
		if tc:IsType(TYPE_XYZ) then
			lk=tc:GetOriginalRank()
		else
			lk=tc:GetOriginalLevel()
		end
		atk=atk+lk
		tc=g:GetNext()
	end
	-- 将攻击力提升效果登记到自身
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk*100)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	if e:GetLabel()==1 then
		c:RegisterFlagEffect(32986898,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 筛选对方场上攻击力低于或等于自身攻击力且非连接怪兽的怪兽
function c32986898.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and not c:IsType(TYPE_LINK)
end
-- 选择目标怪兽并设置破坏效果的操作信息
function c32986898.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c32986898.desfilter(chkc,c:GetAttack()) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c32986898.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择符合条件的对方怪兽作为目标
	local g=Duel.SelectTarget(tp,c32986898.desfilter,tp,0,LOCATION_MZONE,1,1,nil,c:GetAttack())
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理破坏效果并根据条件给予伤害
function c32986898.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 判断破坏是否成功且自身使用超量怪兽作为素材
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and e:GetHandler():GetFlagEffect(32986898)~=0 then
			local atk=tc:GetBaseAttack()
			if atk>0 then
				-- 中断当前效果处理，使后续效果视为错时处理
				Duel.BreakEffect()
				-- 给予对方破坏怪兽原本攻击力一半数值的伤害
				Duel.Damage(1-tp,math.ceil(atk/2),REASON_EFFECT)
			end
		end
	end
end
-- 检查连接素材中是否存在超量怪兽，用于标记是否使用超量怪兽作为素材
function c32986898.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkType,1,nil,TYPE_XYZ) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
