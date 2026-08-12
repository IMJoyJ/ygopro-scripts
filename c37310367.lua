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
-- 判断是否满足效果①的发动条件：攻击方不是自己且没有攻击目标怪兽
function c37310367.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击方控制者不是自己且攻击目标为nil
	return Duel.GetAttacker():GetControler()~=tp and Duel.GetAttackTarget()==nil
end
-- 设置效果①的发动目标：将自身特殊召唤
function c37310367.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤的条件：场上存在空位且自身可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置连锁操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的发动处理：将自身特殊召唤并赋予不会被战斗破坏的效果
function c37310367.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否参与效果处理且特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		-- 赋予特殊召唤的卡片不会被战斗破坏的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断是否满足效果②的发动条件：对方发动效果且对象为己方电子界族怪兽
function c37310367.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsLocation(LOCATION_MZONE)
		and tc:IsControler(tp) and tc:IsFaceup() and tc:IsRace(RACE_CYBERSE) and tc:IsLocation(LOCATION_MZONE)
end
-- 设置效果②的发动目标：己方电子界族怪兽和对方怪兽
function c37310367.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return true end
	local g=Group.FromCards(tc,re:GetHandler())
	-- 设置连锁操作对象为己方电子界族怪兽和对方怪兽
	Duel.SetTargetCard(g)
	-- 设置连锁操作信息：使对象怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,2,0,0)
end
-- 过滤函数：判断卡片是否表侧表示且与效果相关
function c37310367.disfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
-- 效果②的发动处理：使对象怪兽效果无效
function c37310367.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 过滤当前连锁对象卡片组中符合条件的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c37310367.disfilter,nil,e)
	if g:GetCount()<2 then return end
	local rc=re:GetHandler()
	local sc=g:GetFirst()
	if sc==rc then sc=g:GetNext() end
	if sc:IsControler(tp) and sc:IsRace(RACE_CYBERSE) and rc:IsControler(1-tp) then
		sc=g:GetFirst()
		while sc do
			-- 使对象卡片相关的连锁无效
			Duel.NegateRelatedChain(sc,RESET_TURN_SET)
			-- 使对象怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e1)
			-- 使对象怪兽效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			sc:RegisterEffect(e2)
			sc=g:GetNext()
		end
	end
end
