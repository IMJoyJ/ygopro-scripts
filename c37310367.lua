--ロックアウト・ガードナー
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡攻击表示特殊召唤。这个效果特殊召唤的这张卡在这个回合不会被战斗破坏。
-- ②：只以自己场上的电子界族怪兽1只为对象的对方场上的怪兽的效果发动时才能发动。那只自己的电子界族怪兽和那只对方怪兽的效果直到回合结束时无效化。
function c37310367.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡攻击表示特殊召唤。这个效果特殊召唤的这张卡在这个回合不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37310367,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c37310367.spcon)
	e1:SetTarget(c37310367.sptg)
	e1:SetOperation(c37310367.spop)
	c:RegisterEffect(e1)
	-- ②：只以自己场上的电子界族怪兽1只为对象的对方场上的怪兽的效果发动时才能发动。那只自己的电子界族怪兽和那只对方怪兽的效果直到回合结束时无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37310367,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c37310367.discon)
	e2:SetTarget(c37310367.distg)
	e2:SetOperation(c37310367.disop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：对方怪兽进行直接攻击宣言（攻击怪兽的控制者不是自己且攻击目标为空）。
function c37310367.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测到攻击怪兽由对方控制且没有攻击对象，即对方怪兽直接攻击我方。
	return Duel.GetAttacker():GetControler()~=tp and Duel.GetAttackTarget()==nil
end
-- 效果①发动时的合法性检查与对象登记：确认自己怪兽区有空位、这张卡可以表侧攻击表示特殊召唤，并登记特殊召唤的操作信息。
function c37310367.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时检查自己怪兽区是否存在可用空格，以满足从手卡特殊召唤的条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 登记特殊召唤操作信息：将这张卡以特殊召唤的方式处理，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的解决处理：将这张卡从手卡表侧攻击表示特殊召唤；若成功，为这张卡附加本回合不会被战斗破坏的效果。
function c37310367.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果相关联且特殊召唤成功，然后继续执行后续赋予抗性的处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		-- 这个效果特殊召唤的这张卡在这个回合不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 效果②的发动条件：对方场上的怪兽效果以取对象方式发动，且该效果的对象仅为自己场上1只表侧表示的电子界族怪兽，同时发动效果的怪兽在对方怪兽区。
function c37310367.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取该连锁中发动效果所选择的对象卡组，用于检查对象是否为1只以及是否是自己的电子界族怪兽。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_MZONE)
		and tc:IsControler(tp) and tc:IsFaceup() and tc:IsRace(RACE_CYBERSE) and tc:IsLocation(LOCATION_MZONE)
end
-- 效果②发动时设定对象：将之前保存的自己的电子界族怪兽和发动效果的对方怪兽设为对象，并登记无效化操作信息。
function c37310367.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return true end
	local g=Group.FromCards(tc,re:GetHandler())
	-- 将两张卡设置为当前连锁的对象，使它们与效果建立关联。
	Duel.SetTargetCard(g)
	-- 登记无效化操作信息：目标为两张卡，数量2，类别为效果无效化。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,2,0,0)
end
-- 过滤函数：筛选出仍表侧表示且与当前效果相关的卡片，用于处理时确认目标仍然有效。
function c37310367.disfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果②的解决处理：从连锁目标中筛选出仍有效的两张卡，分别将双方怪兽的效果无效化，并使各自关联的连锁无效，持续到回合结束。
function c37310367.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡，并通过过滤器排除已经离场或与效果无关的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c37310367.disfilter,nil,e)
	if g:GetCount()<2 then return end
	local rc=re:GetHandler()
	local sc=g:GetFirst()
	if sc==rc then sc=g:GetNext() end
	if sc:IsControler(tp) and sc:IsRace(RACE_CYBERSE) and rc:IsControler(1-tp) then
		sc=g:GetFirst()
		while sc do
			-- 将与该卡相关的连锁（如它发动过的效果）无效化，并在该卡变里侧时重置无效化状态。
			Duel.NegateRelatedChain(sc,RESET_TURN_SET)
			-- 那只自己的电子界族怪兽和那只对方怪兽的效果直到回合结束时无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
			-- 那只自己的电子界族怪兽和那只对方怪兽的效果直到回合结束时无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e2)
			sc=g:GetNext()
		end
	end
end
