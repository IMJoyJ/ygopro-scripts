--わくわくメルフィーズ
-- 效果：
-- 兽族2星怪兽×2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。这个回合，自己的「童话动物」怪兽可以直接攻击。
-- ②：对方回合，以自己场上1只兽族超量怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以把最多有那只怪兽持有的超量素材数量的2星以下的兽族怪兽从自己墓地特殊召唤。
function c53054164.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加超量召唤手续：以等级2的兽族怪兽2只以上（最多99只）为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),2,2,nil,nil,99)
	-- ①：把这张卡1个超量素材取除才能发动。这个回合，自己的「童话动物」怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53054164,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c53054164.dacon)
	e1:SetCost(c53054164.dacost)
	e1:SetTarget(c53054164.datg)
	e1:SetOperation(c53054164.daop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方回合，以自己场上1只兽族超量怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以把最多有那只怪兽持有的超量素材数量的2星以下的兽族怪兽从自己墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53054164,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,53054164)
	e2:SetCondition(c53054164.tecon)
	e2:SetTarget(c53054164.tetg)
	e2:SetOperation(c53054164.teop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判断：当前回合玩家必须能够进入战斗阶段（通常在自己主要阶段且无其他限制）时才能发动。
function c53054164.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前玩家能否进入战斗阶段，作为效果①的发动条件。
	return Duel.IsAbleToEnterBP()
end
-- 效果①的发动代价：从这张卡上取除1个超量素材（作为COST支付）。
function c53054164.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的发动条件：通过flag标记确认本回合尚未发动过①（防止一回合多次发动）。
function c53054164.datg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①发动检查：当前玩家不存在53054164的flag标记，即本回合尚未使用过①效果。
	if chk==0 then return Duel.GetFlagEffect(tp,53054164)==0 end
end
-- 效果①的处理：给己方场上的「童话动物」怪兽赋予本回合可直接攻击的效果，并注册本回合已使用①的标记。
function c53054164.daop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：把这张卡1个超量素材取除才能发动。这个回合，自己的「童话动物」怪兽可以直接攻击。②：对方回合，以自己场上1只兽族超量怪兽为对象才能发动。那只怪兽回到额外卡组。那之后，可以把最多有那只怪兽持有的超量素材数量的2星以下的兽族怪兽从自己墓地特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设定直接攻击效果的适用对象为己方场上卡名属于「童话动物」系列的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x146))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将直接攻击效果注册到当前玩家（tp）的场地，使其在这个回合对己方的「童话动物」怪兽生效。
	Duel.RegisterEffect(e1,tp)
	-- 为当前玩家注册1个编号为53054164的flag标记，持续到结束阶段，用于标记本回合已发动过①，防止重复发动。
	Duel.RegisterFlagEffect(tp,53054164,RESET_PHASE+PHASE_END,0,1)
end
-- 效果②的发动条件：当前必须是对方回合（tp为发动者，回合玩家不等于tp）。
function c53054164.tecon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为对手的判定结果，以保证②只能在对方回合发动。
	return Duel.GetTurnPlayer()==1-tp
end
-- 效果②的对象筛选条件：表侧表示、兽族、超量怪兽，并且可以返回额外卡组。
function c53054164.tefilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end
-- 效果②发动时的目标选择：从自己场上选择1只满足条件的兽族超量怪兽作为对象，并设置返回额外卡组的操作信息。
function c53054164.tetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c53054164.tefilter(chkc) end
	-- 效果②发动合法性检查：自己场上是否存在至少1只满足条件的兽族超量怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c53054164.tefilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示「请选择要返回卡组的卡」的提示信息，用于接下来的对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己场上选择1只满足条件的兽族超量怪兽作为效果对象，并通过Duel.SelectTarget自动关联到当前连锁。
	local g=Duel.SelectTarget(tp,c53054164.tefilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将本次效果的处理信息设定为：把选择的对象卡返回额外卡组（CATEGORY_TOEXTRA）。
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
end
-- ②中从墓地特殊召唤的卡片筛选条件：等级2以下、兽族怪兽，且可以被效果特殊召唤。
function c53054164.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的具体处理：先将对象怪兽返回额外卡组；若成功返回且其持有的超量素材数>0、己方有怪兽区空位且墓地存在可特召的兽族怪兽，则询问玩家是否进行特殊召唤，随后选择并特殊召唤相应数量的怪兽。
function c53054164.teop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽（即要返回额外卡组的那只兽族超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local ct=tc:GetOverlayCount()
		-- 将对象怪兽以效果返回持有者卡组并洗切，同时确认该怪兽确实位于额外卡组（表示返回成功）。
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA)
			-- 额外要求：对象怪兽原持有的超量素材数量大于0，且自己场上有空余的怪兽区域供特殊召唤使用。
			and ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 确认自己墓地存在至少1只满足特殊召唤条件且不受王家长眠之谷影响的2星以下兽族怪兽。
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c53054164.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
			-- 弹出选择框询问玩家是否要发动特殊召唤效果的后续处理（即是否进行特殊召唤）。
			and Duel.SelectYesNo(tp,aux.Stringid(53054164,2)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理与之前的返回处理分开（错开时点，避免同时处理）。
			Duel.BreakEffect()
			-- 获取己方当前可用的怪兽区域数量，用于限制这次特殊召唤的数量上限。
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			ct=math.min(ct,ft)
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
			-- 给玩家显示「请选择要特殊召唤的卡」的提示信息，用于接下来的选择。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从自己墓地选择1至ct张满足条件的兽族怪兽，ct取原素材数与可用怪兽区域数中较小者。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53054164.spfilter),tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
			-- 将选择的怪兽以表侧表示（POS_FACEUP）特殊召唤到己方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
