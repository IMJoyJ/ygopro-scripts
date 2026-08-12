--DDD怒濤壊薙王カエサル・ラグナロク
-- 效果：
-- 「DDD」怪兽×2
-- ①：1回合1次，这张卡进行战斗的攻击宣言时，以自己场上的其他的1张「DD」卡或「契约书」卡为对象才能发动。那张卡回到手卡，和这张卡进行战斗的怪兽以外的对方场上1只表侧表示怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
function c27873305.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用2个满足「DDD」系列的融合素材进行融合召唤
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
-- 判断是否满足效果发动条件，即此卡是否正在攻击或被攻击
function c27873305.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 此卡是否正在攻击或被攻击
	return (Duel.GetAttacker()==c or Duel.GetAttackTarget()==c)
end
-- 过滤满足条件的「DD」卡或「契约书」卡，用于选择返回手卡的卡
function c27873305.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf,0xae) and c:IsAbleToHand()
end
-- 过滤满足条件的对方场上表侧表示怪兽，用于选择装备的卡
function c27873305.eqfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 设置效果目标选择逻辑，检查是否能选择满足条件的卡
function c27873305.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c27873305.thfilter(chkc) and chkc~=c end
	-- 检查是否满足选择返回手卡的卡的条件
	if chk==0 then return Duel.IsExistingTarget(c27873305.thfilter,tp,LOCATION_ONFIELD,0,1,c)
		-- 检查是否满足选择对方场上表侧表示怪兽进行装备的条件
		and Duel.IsExistingMatchingCard(c27873305.eqfilter,tp,0,LOCATION_MZONE,1,c:GetBattleTarget()) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的卡返回手牌
	local g1=Duel.SelectTarget(tp,c27873305.thfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置效果操作信息，指定将卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,1,0,0)
end
-- 效果处理函数，执行装备和攻击力提升操作
function c27873305.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效并将其送入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		local bc=c:GetBattleTarget()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 提示玩家选择要装备的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 选择满足条件的对方场上表侧表示怪兽进行装备
			local g=Duel.SelectMatchingCard(tp,c27873305.eqfilter,tp,0,LOCATION_MZONE,1,1,bc)
			local ec=g:GetFirst()
			if not ec then return end
			local atk=ec:GetTextAttack()
			if atk<0 then atk=0 end
			-- 执行装备操作，将选中的怪兽装备给此卡
			if not Duel.Equip(tp,ec,c,false) then return end
			-- 装备对象限制效果，确保只有此卡能装备该怪兽
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c27873305.eqlimit)
			ec:RegisterEffect(e1)
			if atk>0 then
				-- 装备后提升此卡攻击力的效果，提升值为装备怪兽的攻击力
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
-- 装备对象限制函数，确保只有此卡能装备该怪兽
function c27873305.eqlimit(e,c)
	return e:GetOwner()==c
end
