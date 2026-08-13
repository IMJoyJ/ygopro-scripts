--根絶の機皇神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地3只「机皇」怪兽为对象才能发动（同名卡最多1张）。那些怪兽加入手卡或无视召唤条件特殊召唤。这张卡的发动后，直到下次的自己回合的结束时自己不是机械族怪兽不能特殊召唤。
-- ②：自己场上有「机皇神」怪兽存在的场合，把墓地的这张卡除外才能发动。选对方场上1只同调怪兽破坏，给与对方那个原本攻击力数值的伤害。
function c2992036.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己墓地3只「机皇」怪兽为对象才能发动（同名卡最多1张）。那些怪兽加入手卡或无视召唤条件特殊召唤。这张卡的发动后，直到下次的自己回合的结束时自己不是机械族怪兽不能特殊召唤。
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
	-- 设置②效果的发动代价：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c2992036.destg)
	e2:SetOperation(c2992036.desop)
	c:RegisterEffect(e2)
end
-- ①效果的对象筛选：选择自己墓地的「机皇」怪兽，要求可作为效果对象，且满足能被加入手卡或能被无视召唤条件特殊召唤。
function c2992036.filter(c,e,tp)
	return c:IsSetCard(0x13) and c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e)
		and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,true,false))
end
-- 选择子组判定：确认3张卡均为机皇且卡名互不相同，同时要么全部可回手，要么全部可特殊召唤且特殊召唤数量不超过己方可用怪兽区，且未受青眼精灵龙（禁止同时特殊召唤2只以上怪兽）影响。
function c2992036.fselect(g,e,tp)
	-- 获取己方场上可用的怪兽区域数量，用于判断是否满足同时特殊召唤所需空格。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct1=g:FilterCount(Card.IsAbleToHand,nil)
	local ct2=g:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,true,false)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	return (ct1==#g or ct2==#g and ct2<=ft and not Duel.IsPlayerAffectedByEffect(tp,59822133)) and aux.dncheck(g)
end
-- ①效果的发动前处理：从自己墓地筛选并按规则选择3只「机皇」怪兽（同名卡最多1张）作为对象，并设为该连锁的对象。
function c2992036.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中所有满足①效果筛选条件的「机皇」怪兽，构成可选对象集合。
	local g=Duel.GetMatchingGroup(c2992036.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(c2992036.fselect,3,3,e,tp) end
	-- 弹出选择对象的UI提示，引导玩家选择要作为效果对象的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local tg=g:SelectSubGroup(tp,c2992036.fselect,false,3,3,e,tp)
	-- 将选中的「机皇」怪兽卡组设为当前连锁的效果对象。
	Duel.SetTargetCard(tg)
end
-- ①效果处理：将对象怪兽全部加入手卡或全部无视召唤条件特殊召唤（处理时检查可用区域与青眼精灵龙限制），随后附加自肃效果：直到下次自己回合结束时，自己不能特殊召唤机械族以外的怪兽。
function c2992036.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取效果对象，并过滤出仍然与本次效果相关的卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 若对象卡因王家长眠之谷等效果而使该墓地效果应被无效，则中止本次效果处理。
	if aux.NecroValleyNegateCheck(tg) then return end
	if tg:GetCount()>0 then
		-- 获取己方可用怪兽区空格数，用于判断能否将对象特殊召唤。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local b1=tg:FilterCount(Card.IsAbleToHand,nil)==#tg
		local ct=tg:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,true,false)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		local b2=ct==#tg and ft>=ct and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
		local opt=-1
		if b1 and not b2 then
			-- 当只满足回手条件时，弹出“加入手卡”的选项供玩家选择。
			opt=Duel.SelectOption(tp,1190)
		elseif not b1 and b2 then
			-- 当只满足特殊召唤条件时，弹出“特殊召唤”选项，选择后得到opt=1，对应后续特殊召唤分支。
			opt=Duel.SelectOption(tp,1152)+1
		elseif b1 and b2 then
			-- 当回手和特殊召唤均可执行时，同时弹出两个选项，玩家选择回手(opt=0)或特殊召唤(opt=1)。
			opt=Duel.SelectOption(tp,1190,1152)
		end
		if opt==0 then
			-- 将选中的「机皇」怪兽全部加入持有者的手卡。
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		elseif opt==1 then
			-- 无视召唤条件，将选中的「机皇」怪兽以表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(tg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到下次的自己回合的结束时自己不是机械族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c2992036.splimit)
		-- 判断当前回合是否为发动者的回合，以正确计算自肃效果持续到下次自己回合结束的剩余时长。
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
		end
		-- 将“不能特殊召唤机械族以外的怪兽”的自肃效果注册给发动者。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃效果的过滤函数：仅允许特殊召唤机械族怪兽，非机械族怪兽不能特殊召唤。
function c2992036.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- ②效果发动条件的过滤器：判定自己场上是否存在表侧表示的「机皇神」怪兽。
function c2992036.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x5013)
end
-- ②效果的发动条件：自己场上有表侧表示的「机皇神」怪兽存在。
function c2992036.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「机皇神」怪兽。
	return Duel.IsExistingMatchingCard(c2992036.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果破坏对象的过滤器：选取对方场上的表侧表示同调怪兽。
function c2992036.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- ②效果的发动前处理：确认对方场上有表侧同调怪兽可作为破坏对象，并设置要执行破坏与伤害的操作信息。
function c2992036.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的所有表侧同调怪兽，构成可选的破坏对象集合。
	local g=Duel.GetMatchingGroup(c2992036.desfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：本连锁将破坏对方场上的1只怪兽（对象数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本连锁将给与对方玩家效果伤害（伤害数值由后续破坏怪兽的原攻击力决定）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- ②效果处理：从对方场上选择1只表侧同调怪兽破坏，若破坏成功，给与对方那只怪兽原本攻击力数值的伤害。
function c2992036.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择要破坏的卡的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从对方场上选择1只表侧同调怪兽作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,c2992036.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 为被选中的破坏对象播放选中的动画提示。
		Duel.HintSelection(g)
		-- 用效果破坏选中的同调怪兽，并检查是否破坏成功。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			local atk=tc:GetBaseAttack()
			if atk>0 then
				-- 给与对方玩家该怪兽原本攻击力数值的效果伤害。
				Duel.Damage(1-tp,atk,REASON_EFFECT)
			end
		end
	end
end
