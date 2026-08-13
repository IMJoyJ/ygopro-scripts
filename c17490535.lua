--エーリアン・ブレイン
-- 效果：
-- 自己场上存在的爬虫类族怪兽被对方怪兽的攻击破坏送去墓地时才能发动。得到那个时候进行攻击的对方怪兽的控制权，那只怪兽当作爬虫类族使用。
function c17490535.initial_effect(c)
	-- 自己场上存在的爬虫类族怪兽被对方怪兽的攻击破坏送去墓地时才能发动。得到那个时候进行攻击的对方怪兽的控制权，那只怪兽当作爬虫类族使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c17490535.condition)
	e1:SetTarget(c17490535.target)
	e1:SetOperation(c17490535.activate)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件：被破坏送去墓地的怪兽只有1只，且其原控制者为己方、原种族/场上种族为爬虫类族，并且是作为攻击对象被对方怪兽战斗破坏。
function c17490535.condition(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return eg:GetCount()==1 and ec:IsPreviousControler(tp) and ec:IsRace(RACE_REPTILE)
		and bit.band(ec:GetPreviousRaceOnField(),RACE_REPTILE)~=0
		-- 并且该怪兽是攻击对象，且当前位于墓地，破坏原因为战斗破坏。
		and ec==Duel.GetAttackTarget() and ec:IsLocation(LOCATION_GRAVE) and ec:IsReason(REASON_BATTLE)
end
-- 获取导致破坏的攻击怪兽，在发动时确认其控制者为对方、与本次战斗相关且控制权可以变更；然后将该怪兽设为对象，并登记改变控制权的操作信息。
function c17490535.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst():GetReasonCard()
	if chk==0 then return tc:IsControler(1-tp) and tc:IsRelateToBattle() and tc:IsControlerCanBeChanged() end
	-- 将攻击怪兽设置为当前连锁的对象，使其与本效果建立联系，供效果处理时获取。
	Duel.SetTargetCard(tc)
	-- 登记操作信息：本次效果将改变1只怪兽的控制权，对象为攻击怪兽，供相关规则检测。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
-- 效果处理：取出对象怪兽，若其仍与本效果关联，则尝试获得其控制权；成功后为那只怪兽附加“种族变为爬虫类族”的持续效果，并在其离场等场合重置。
function c17490535.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁的对象中取出攻击怪兽作为tc。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 尝试将tc的控制权转移给己方tp；成功时返回非零值。
		if Duel.GetControl(tc,tp)~=0 then
			-- 那只怪兽当作爬虫类族使用。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_REPTILE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
