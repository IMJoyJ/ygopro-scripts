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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡作为连接素材送去墓地的场合，以这张卡以外的自己墓地1只暗属性怪兽为对象才能发动。那只怪兽加入手卡。对方可以选自身墓地1只怪兽加入手卡。
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
-- ①效果的发动条件判定函数：检测是否满足对方怪兽直接攻击宣言时才能发动的条件，若满足则允许发动。
function c27352108.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽的控制者不是自己，且攻击对象不存在，即对方怪兽对己方发动直接攻击。
	return Duel.GetAttacker():GetControler()~=tp and Duel.GetAttackTarget()==nil
end
-- ①效果的发动目标/条件检查函数：在发动时确认自己有可用的主要怪兽区域，且手牌中的这张卡能够以表侧攻击表示特殊召唤。
function c27352108.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：要求自己场上存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 登记本次连锁将这张卡进行特殊召唤的操作信息，供时点检测与连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：将这张卡从手卡以表侧攻击表示特殊召唤，若成功则为这张卡附加本回合内不会被战斗破坏、战斗伤害减半的效果。
function c27352108.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以特殊召唤处理步骤尝试将这张卡表侧攻击表示特殊召唤，成功后才继续为其附加后续的永续保护效果。
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		-- 这个回合，这个效果特殊召唤的这张卡不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 这个回合，这张卡的战斗发生的对自己的战斗伤害变成一半。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置“这张卡的战斗发生的对自己的战斗伤害变成一半”的伤害数值修改方式，指定对自己造成的战斗伤害减半。
		e2:SetValue(aux.ChangeBattleDamage(0,HALF_DAMAGE))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
	-- 完成整个特殊召唤处理步骤，在将所有特殊召唤的卡都处理完毕后统一结算召唤成功的时点。
	Duel.SpecialSummonComplete()
end
-- ②效果的发动条件判定函数：判定这张卡是否因作为连接素材被送去墓地，且当前在墓地，满足“作为连接素材送去墓地的场合”这一发动条件。
function c27352108.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- ②效果选择对象的过滤函数：选择自己墓地中暗属性且能够加入手卡的怪兽。
function c27352108.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- ②效果的目标选择与发动检查函数：从自己墓地选择1只除这张卡以外的暗属性怪兽为对象，并登记将其加入手卡的操作信息。
function c27352108.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c27352108.thfilter(chkc) and chkc~=e:GetHandler() end
	-- 发动时检查自己墓地是否存在至少1只符合条件的暗属性怪兽（除这张卡自身以外）。
	if chk==0 then return Duel.IsExistingTarget(c27352108.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向当前玩家显示“请选择要加入手牌的卡”的提示，用于引导选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己墓地选择1只满足条件且不是这张卡的暗属性怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c27352108.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 登记将所选择的目标怪兽加入手卡的效果操作信息，供连锁时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤函数：定义对方可选自身墓地1只怪兽时的条件——必须是墓地中的怪兽且能够加入手卡。
function c27352108.thfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的处理函数：先将作为对象的那只暗属性怪兽加入手卡，然后若对方墓地存在符合条件的怪兽且对方选择同意，则让对方选择自身墓地1只怪兽加入手卡。
function c27352108.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送去其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 获取对方墓地中所有可作为对方选项的怪兽卡组，并排除受王家长眠之谷影响导致不能加入手卡的卡。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c27352108.thfilter2),1-tp,LOCATION_GRAVE,0,nil)
		-- 若对方墓地存在符合条件的怪兽，且对方玩家选择“是”，则继续执行让对手选择怪兽加入手卡的处理。
		if g:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(27352108,0)) then  --"是否选墓地怪兽加入手卡？"
			-- 向对方玩家显示“请选择要加入手牌的卡”的提示，以便对方选择要加入手卡的怪兽。
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(1-tp,1,1,nil)
			-- 将对方选择的那只怪兽送去其持有者的手卡。
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
