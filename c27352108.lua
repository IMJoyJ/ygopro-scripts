--チョバムアーマー・ドラゴン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡攻击表示特殊召唤。这个回合，这个效果特殊召唤的这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成一半。
-- ②：这张卡作为连接素材送去墓地的场合，以这张卡以外的自己墓地1只暗属性怪兽为对象才能发动。那只怪兽加入手卡。对方可以选自身墓地1只怪兽加入手卡。
function c27352108.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡攻击表示特殊召唤。这个回合，这个效果特殊召唤的这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c27352108.spcon)
	e1:SetTarget(c27352108.sptg)
	e1:SetOperation(c27352108.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为连接素材送去墓地的场合，以这张卡以外的自己墓地1只暗属性怪兽为对象才能发动。那只怪兽加入手卡。对方可以选自身墓地1只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,27352108)
	e2:SetCondition(c27352108.thcon)
	e2:SetTarget(c27352108.thtg)
	e2:SetOperation(c27352108.thop)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：对方怪兽进行直接攻击宣言时
function c27352108.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽的攻击方不是自己且没有攻击目标
	return Duel.GetAttacker():GetControler()~=tp and Duel.GetAttackTarget()==nil
end
-- 效果的发动条件判断：手卡有空位且自身可以特殊召唤
function c27352108.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置效果处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身从手卡攻击表示特殊召唤，且获得不会被战斗破坏和战斗伤害减半的效果
function c27352108.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤步骤
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		-- 给特殊召唤的怪兽添加效果：不会被战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 给特殊召唤的怪兽添加效果：战斗发生的对自己的战斗伤害变成一半
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置战斗伤害减半效果的数值
		e2:SetValue(aux.ChangeBattleDamage(0,HALF_DAMAGE))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 效果发动的条件：作为连接素材送去墓地时
function c27352108.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- 过滤函数：筛选暗属性且能加入手牌的怪兽
function c27352108.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果处理：选择墓地一只暗属性怪兽加入手牌
function c27352108.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c27352108.thfilter(chkc) and chkc~=e:GetHandler() end
	-- 判断是否有满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c27352108.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标：墓地一只暗属性怪兽
	local g=Duel.SelectTarget(tp,c27352108.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置效果处理信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤函数：筛选能加入手牌的怪兽
function c27352108.thfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理：将目标怪兽加入手牌，对方可选择墓地一只怪兽加入手牌
function c27352108.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 获取对方墓地所有能加入手牌的怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c27352108.thfilter2),1-tp,LOCATION_GRAVE,0,nil)
		-- 判断对方是否有可选的墓地怪兽且对方选择发动效果
		if g:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(27352108,0)) then  --"是否选墓地怪兽加入手卡？"
			-- 提示对方选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 将对方选择的怪兽加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
