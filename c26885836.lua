--H・C ウォー・ハンマー
-- 效果：
-- 这张卡战斗破坏对方怪兽送去墓地时，可以把破坏的怪兽当作装备卡使用只有1只给这张卡装备。这张卡的攻击力上升这个效果装备的怪兽的攻击力数值。
function c26885836.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽送去墓地时，可以把破坏的怪兽当作装备卡使用只有1只给这张卡装备。这张卡的攻击力上升这个效果装备的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26885836,0))  --"装备"
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCondition(c26885836.eqcon)
	e1:SetTarget(c26885836.eqtg)
	e1:SetOperation(c26885836.eqop)
	c:RegisterEffect(e1)
end
-- 定义‘战斗破坏对方怪兽送去墓地时’的诱发选发效果：获取被本卡战斗破坏的对方怪兽，将其暂时记录为效果对象，并判断基本诱发条件是否成立。
function c26885836.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(tc)
	-- 判定条件：本卡与对方怪兽战斗并将其战斗破坏送去墓地，且该怪兽没有被宣言为禁止装备卡，此时条件成立。
	return aux.bdogcon(e,tp,eg,ep,ev,re,r,rp) and not tc:IsForbidden()
end
-- 发动目标条件：本卡上没有‘已由本效果装备过’的标记（即尚未用此效果装备过怪兽），且我方魔陷区有空位可以放置装备卡。
function c26885836.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsHasEffect(26885836)
		-- 检查我方魔陷区是否有可用的空格，用于把被破坏的怪兽作为装备卡装备。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local tc=e:GetLabelObject()
	-- 将被战斗破坏的怪兽设定为当前效果的对象，建立效果关联，便于后续处理。
	Duel.SetTargetCard(tc)
	-- 声明本次操作涉及使对象怪兽离开墓地，用于使相关卡牌（如王家长眠之谷等）能正确连锁或无效。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- 效果处理：取回对象怪兽，若能装备则将其作为装备卡装备给本卡，并附加装备限制、攻击力提升和‘已装备标记’三个效果。
function c26885836.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出发动时保存的对象，即被战斗破坏并要装备的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 尝试将对象怪兽作为装备卡装备给本卡；若因故装备失败则直接终止后续处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 对应‘只有1只给这张卡装备’：给被装备的怪兽赋予装备对象限制，使其只能装备给原来的‘英豪挑战者 战锤兵’。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c26885836.eqlimit)
		tc:RegisterEffect(e1)
		if atk>0 then
			-- 对应‘这张卡的攻击力上升这个效果装备的怪兽的攻击力数值’：为装备后的怪兽赋予上升攻击力的装备效果，上升数值为该怪兽的原本攻击力。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
		-- 对应‘只有1只’：在该装备卡上设置一个‘已被此效果装备过’的标记，防止同一张战锤兵重复装备多只怪兽。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(26885836)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
-- 装备对象限制的判定函数：只有当前装备卡的持有者（原战锤兵）才能装备该卡，确保装备对象正确。
function c26885836.eqlimit(e,c)
	return e:GetOwner()==c
end
