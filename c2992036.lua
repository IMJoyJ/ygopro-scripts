--根絶の機皇神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地3只「机皇」怪兽为对象才能发动（同名卡最多1张）。那些怪兽加入手卡或无视召唤条件特殊召唤。这张卡的发动后，直到下次的自己回合的结束时自己不是机械族怪兽不能特殊召唤。
-- ②：自己场上有「机皇神」怪兽存在的场合，把墓地的这张卡除外才能发动。选对方场上1只同调怪兽破坏，给与对方那个原本攻击力数值的伤害。
function c2992036.initial_effect(c)
	-- ①：以自己墓地3只「机皇」怪兽为对象才能发动（同名卡最多1张）。那些怪兽加入手卡或无视召唤条件特殊召唤。这张卡的发动后，直到下次的自己回合的结束时自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2992036,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,2992036)
	e1:SetTarget(c2992036.target)
	e1:SetOperation(c2992036.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「机皇神」怪兽存在的场合，把墓地的这张卡除外才能发动。选对方场上1只同调怪兽破坏，给与对方那个原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2992036,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,2992037)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(c2992036.descon)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c2992036.destg)
	e2:SetOperation(c2992036.desop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的墓地「机皇」怪兽，这些怪兽可以加入手卡或特殊召唤
function c2992036.filter(c,e,tp)
	return c:IsSetCard(0x13) and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
		and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end
-- 检查所选的3只怪兽是否满足加入手卡或特殊召唤的条件，并确保卡名不重复
function c2992036.fselect(g,e,tp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct1=g:FilterCount(Card.IsAbleToHand,nil)
	local ct2=g:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,true,false)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	return (ct1==#g or ct2==#g and ct2<=ft and not Duel.IsPlayerAffectedByEffect(tp,59822133)) and aux.dncheck(g)
end
-- 设置效果目标，选择满足条件的3只怪兽
function c2992036.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取满足条件的墓地「机皇」怪兽组
	local g=Duel.GetMatchingGroup(c2992036.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(c2992036.fselect,3,3,e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,c2992036.fselect,false,3,3,e,tp)
	-- 设置所选的3只怪兽为效果对象
	Duel.SetTargetCard(tg)
end
-- 处理效果发动，根据选择将怪兽加入手卡或特殊召唤，并设置后续不能特殊召唤机械族怪兽的效果
function c2992036.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设置的效果对象
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检查是否因王家长眠之谷而无效
	if aux.NecroValleyNegateCheck(tg) then return end
	if tg:GetCount()>0 then
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local b1=tg:FilterCount(Card.IsAbleToHand,nil)==#tg
		local ct=tg:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,true,false)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		local b2=ct==#tg and ft>=ct and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
		local opt=-1
		if b1 and not b2 then
			-- 选择将怪兽加入手卡
			opt=Duel.SelectOption(tp,1190)
		elseif not b1 and b2 then
			-- 选择将怪兽特殊召唤
			opt=Duel.SelectOption(tp,1152)+1
		elseif b1 and b2 then
			-- 同时提供加入手卡和特殊召唤两种选项供玩家选择
			opt=Duel.SelectOption(tp,1190,1152)
		end
		if opt==0 then
			-- 将怪兽加入手卡
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		elseif opt==1 then
			-- 无视召唤条件特殊召唤怪兽
			Duel.SpecialSummon(tg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置效果作用：直到下次自己回合结束时，自己不能特殊召唤非机械族怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c2992036.splimit)
		-- 判断是否为当前回合玩家
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 注册效果：禁止特殊召唤
		Duel.RegisterEffect(e1,tp)
	end
end
-- 设置效果目标：非机械族怪兽不能特殊召唤
function c2992036.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 过滤场上存在的「机皇神」怪兽
function c2992036.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x5013)
end
-- 判断是否满足发动②效果的条件：场上有「机皇神」怪兽
function c2992036.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「机皇神」怪兽
	return Duel.IsExistingMatchingCard(c2992036.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤对方场上的同调怪兽
function c2992036.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 设置效果目标：选择对方场上的同调怪兽
function c2992036.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的同调怪兽组
	local g=Duel.GetMatchingGroup(c2992036.desfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 处理效果发动：选择对方场上的同调怪兽破坏并造成伤害
function c2992036.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1只同调怪兽
	local g=Duel.SelectMatchingCard(tp,c2992036.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 显示所选怪兽被破坏的动画效果
		Duel.HintSelection(g)
		-- 破坏所选怪兽
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			local atk=tc:GetBaseAttack()
			if atk>0 then
				-- 给与对方相当于怪兽原本攻击力数值的伤害
				Duel.Damage(1-tp,atk,REASON_EFFECT)
			end
		end
	end
end
