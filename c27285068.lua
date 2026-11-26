--開闢なる予幻視
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「无垢者 米底乌斯」存在的场合才能发动。从卡组选1只攻击力300/守备力200的怪兽加入手卡或特殊召唤。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡名记述以及①②两个效果。
function s.initial_effect(c)
	-- 记录这张卡的卡文本中记述了「无垢者 米底乌斯」。
	aux.AddCodeList(c,97556336)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有「无垢者 米底乌斯」存在的场合才能发动。从卡组选1只攻击力300/守备力200的怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组选怪兽"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变成调整"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价为将墓地的这张卡表侧除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.tntg)
	e2:SetOperation(s.tnop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查卡片是否为表侧表示的「无垢者 米底乌斯」。
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(97556336)
end
-- ①效果的发动条件：检查自己场上是否存在表侧表示的「无垢者 米底乌斯」。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在至少1张表侧表示的「无垢者 米底乌斯」。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤条件：检查卡片是否为攻击力300且守备力200，并且可加入手卡或（在有空位时）可特殊召唤的怪兽。
function s.thfilter(c,e,tp)
	if not (c:IsAttack(300) and c:IsDefense(200)) then return false end
	-- 获取自己主要怪兽区可用于特殊召唤的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- ①效果的目标处理函数：检查自己卡组是否存在满足条件的攻击力300/守备力200怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己卡组存在至少1只符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- ①效果的处理函数：从卡组选1只攻击力300/守备力200的怪兽，让玩家选择加入手卡或特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示信息，引导玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组选择1只满足条件的攻击力300/守备力200的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 获取自己主要怪兽区可用于特殊召唤的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 若所选怪兽可加入手卡，且无法特殊召唤、没有怪兽区空位或玩家选择加入手卡时进入加入手卡分支。
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将所选怪兽以效果加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 将加入手卡的怪兽展示给对方确认。
			Duel.ConfirmCards(1-tp,tc)
		elseif tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将所选怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤条件：检查怪兽是否为表侧表示且当前不是调整的怪兽。
function s.tnfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER)
end
-- ②效果的目标处理函数：检查并让己方选择自己场上1只表侧表示非调整怪兽作为对象。
function s.tntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tnfilter(chkc) end
	-- 发动条件检查：确认自己怪兽区存在至少1只可作为对象的表侧表示非调整怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.tnfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 发送提示信息，引导玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让己方从自己怪兽区选择1只表侧表示非调整怪兽作为效果对象。
	Duel.SelectTarget(tp,s.tnfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的处理函数：获取对象怪兽并赋予其直到回合结束时当作调整使用的状态。
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁指定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and not tc:IsType(TYPE_TUNER) then
		-- 这个回合，那只怪兽当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end
