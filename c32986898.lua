--粛星の鋼機
-- 效果：
-- 连接怪兽以外的怪兽3只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升作为这张卡的连接素材的怪兽的原本的等级·阶级的合计×100。
-- ②：以持有这张卡的攻击力以下的攻击力的除连接怪兽以外的对方场上1只怪兽为对象才能发动。那只怪兽破坏。这张卡用超量怪兽为素材作连接召唤的场合，再给与对方破坏的怪兽的原本攻击力一半数值的伤害。
function c32986898.initial_effect(c)
	-- 为这张卡添加连接召唤手续，要求使用3只（且仅3只）满足“连接怪兽以外”条件的怪兽作为连接素材。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：以持有这张卡的攻击力以下的攻击力的除连接怪兽以外的对方场上1只怪兽为对象才能发动。那只怪兽破坏。这张卡用超量怪兽为素材作连接召唤的场合，再给与对方破坏的怪兽的原本攻击力一半数值的伤害。
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
	-- 这张卡用超量怪兽为素材作连接召唤的场合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(c32986898.valcheck)
	c:RegisterEffect(e4)
	e4:SetLabelObject(e1)
end
-- 条件函数：判断这张卡是否以连接召唤的方式特殊召唤成功，仅当召唤类型为连接召唤时允许①效果发动处理。
function c32986898.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果处理：取这张卡的连接素材，遍历素材，若为超量怪兽则取其原本阶级，否则取原本等级，累加得到等级·阶级合计；随后给这张卡注册一个永续效果，使其攻击力上升合计数值×100。若e的Label为1（素材中包含超量怪兽），再为这张卡注册flag效果32986898，以标记②效果可造成追加伤害。
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
	-- ①：这张卡的攻击力上升作为这张卡的连接素材的怪兽的原本的等级·阶级的合计×100。
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
-- ②效果的目标筛选条件：对象必须是表侧表示、攻击力不高于这张卡当前攻击力、且不是连接怪兽的怪兽。
function c32986898.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk) and not c:IsType(TYPE_LINK)
end
-- ②效果的发动条件和取对象处理：在发动时检查是否存在合法目标；若存在则要求玩家从对方场上选择1只满足条件的表侧表示怪兽（非连接、攻击力不高于本卡攻击力）作为对象，并将破坏类别的操作信息写入连锁，供后续处理使用。
function c32986898.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c32986898.desfilter(chkc,c:GetAttack()) end
	-- 发动条件检查：若对方场上不存在满足条件的表侧表示非连接怪兽且攻击力不高于本卡攻击力的怪兽，则不能发动该效果。
	if chk==0 then return Duel.IsExistingTarget(c32986898.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end
	-- 向当前玩家显示目标选择提示信息“请选择要破坏的卡”，供卡片选择界面使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让当前玩家从对方场上选择1只满足②效果条件的怪兽作为效果对象，并自动将该对象关联到当前连锁。
	local g=Duel.SelectTarget(tp,c32986898.desfilter,tp,0,LOCATION_MZONE,1,1,nil,c:GetAttack())
	-- 设置当前连锁的操作信息：即将执行破坏效果，破坏对象为已选择的1只怪兽，分类为CATEGORY_DESTROY。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得对象怪兽，若对象仍与效果关联则将其破坏；若破坏成功且这张卡带有flag 32986898（以超量怪兽为素材连接召唤过），则以破坏怪兽的原本攻击力的一半数值给予对方效果伤害（伤害前用Duel.BreakEffect分断时点）。
function c32986898.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一张对象卡，即②效果选定的对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏对象怪兽，若破坏处理成功（返回非0），且这张卡拥有flag 32986898（满足“用超量怪兽为素材作连接召唤”的条件），则继续执行追加伤害。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and e:GetHandler():GetFlagEffect(32986898)~=0 then
			local atk=tc:GetBaseAttack()
			if atk>0 then
				-- 中断当前效果处理，使后续的伤害不与破坏处理视为同时处理，避免错过时点。
				Duel.BreakEffect()
				-- 给予对方玩家效果伤害，数值为被破坏怪兽的原本攻击力的一半，小数向上取整（math.ceil）。
				Duel.Damage(1-tp,math.ceil(atk/2),REASON_EFFECT)
			end
		end
	end
end
-- EFFECT_MATERIAL_CHECK的值函数：检查这张卡的连接素材中是否有超量怪兽；若有，将e1的Label设为1（表示②效果可以追加伤害），否则设为0。
function c32986898.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLinkType,1,nil,TYPE_XYZ) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
