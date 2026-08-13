--DDD怒濤壊薙王カエサル・ラグナロク
-- 效果：
-- 「DDD」怪兽×2
-- ①：1回合1次，这张卡进行战斗的攻击宣言时，以自己场上的其他的1张「DD」卡或「契约书」卡为对象才能发动。那张卡回到手卡，和这张卡进行战斗的怪兽以外的对方场上1只表侧表示怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
function c27873305.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以任意2只「DDD」怪兽（字段代码0x10af）作为融合素材进行融合召唤。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x10af),2,true)
	-- ①：1回合1次，这张卡进行战斗的攻击宣言时，以自己场上的其他的1张「DD」卡或「契约书」卡为对象才能发动。那张卡回到手卡，和这张卡进行战斗的怪兽以外的对方场上1只表侧表示怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c27873305.condition)
	e1:SetTarget(c27873305.target)
	e1:SetOperation(c27873305.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：当攻击宣言中的攻击者或攻击对象为本卡，即本卡参与战斗的攻击宣言时，该效果满足发动条件。
function c27873305.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回真当且仅当本卡是这次攻击宣言的攻击者或被攻击目标，表示这张卡正在进行战斗的攻击宣言。
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
-- 定义返回手牌的对象筛选：需要是表侧表示、属于「DD」或「契约书」字段、并且可以被送回手牌的卡。
function c27873305.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf,0xae) and c:IsAbleToHand()
end
-- 定义可装备的对方怪兽筛选：需要是表侧表示，且可以变更控制权（能被装备到我方场上）。
function c27873305.eqfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 效果目标合法性判定：锁定本卡为效果持有者；连锁处理时验证指定对象是我方场上、非本卡且满足回手条件；发动时确认自己场上有满足条件的对象卡，且对方场上有可装备的怪兽。
function c27873305.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c27873305.thfilter(chkc) and chkc~=c end
	-- 发动合法性检查：确认自己场上存在1张除本卡外、表侧表示且属于「DD」/「契约书」、可返回手牌的对象卡。
	if chk==0 then return Duel.IsExistingTarget(c27873305.thfilter,tp,LOCATION_ONFIELD,0,1,c)
		-- 发动合法性检查：确认对方主要怪兽区存在1张除这张卡的战斗对象外、表侧表示且可变更控制权的怪兽，以保证后续可以装备。
		and Duel.IsExistingMatchingCard(c27873305.eqfilter,tp,0,LOCATION_MZONE,1,c:GetBattleTarget()) end
	-- 向操作者显示选择提示：请选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从我方场上选择1张除本卡外的「DD」/「契约书」卡作为效果对象，并登记为当前连锁的对象。
	local g1=Duel.SelectTarget(tp,c27873305.thfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 登记操作信息：效果处理时会将所选对象卡返回持有者手牌（分类为回手牌），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,1,0,0)
end
-- 效果处理：先使对象卡返回手牌；确认成功后，选择对方场上1只除战斗对象外的表侧表示且可变更控制权的怪兽，将其作为装备魔法卡装备给本卡，并为该装备卡附加只能装备给本卡的限制及攻击力上升效果。
function c27873305.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时连锁对象中的第一张卡，即被选择返回手牌的那张「DD」/「契约书」卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果关联，则将其返回持有者手牌；只有返回成功且该卡确实位于手牌时才继续执行后续的装备处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		local bc=c:GetBattleTarget()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 向操作者显示选择提示：请选择要装备的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 选择对方场上1只除战斗对象外、表侧表示且可变更控制权的怪兽，作为要装备给本卡的卡。
			local g=Duel.SelectMatchingCard(tp,c27873305.eqfilter,tp,0,LOCATION_MZONE,1,1,bc)
			local ec=g:GetFirst()
			if not ec then return end
			local atk=ec:GetTextAttack()
			if atk<0 then atk=0 end
			-- 将选中的怪兽作为装备魔法卡装备给本卡；若装备失败则立即结束效果处理。
			if not Duel.Equip(tp,ec,c,false) then return end
			-- 当作装备魔法卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c27873305.eqlimit)
			ec:RegisterEffect(e1)
			if atk>0 then
				-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(atk)
				ec:RegisterEffect(e2)
			end
		end
	end
end
-- 装备限制判定函数：只有当目标卡是效果持有者自身（即本卡）时才允许该装备卡存在，使其只能装备给本卡。
function c27873305.eqlimit(e,c)
	return e:GetOwner()==c
end
