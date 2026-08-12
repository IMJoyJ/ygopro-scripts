--増殖するクリボー！
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方把怪兽的效果发动时或者对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，对方把场上的怪兽的效果发动时或者对方怪兽攻击的伤害计算时才能发动。从自己的卡组·墓地选1只「黑魔术师」或者攻击力300/守备力200的怪兽加入手卡或特殊召唤。那之后，可以把那只对方怪兽的攻击力变成0。
local s,id,o=GetID()
-- 初始化卡片效果：注册记载的卡名，注册手卡特殊召唤的两个诱发即时效果，以及注册在场上发动的检索/特殊召唤的两个诱发即时效果。
function s.initial_effect(c)
	-- 将卡片「黑魔术师」（卡密码：46986414）记录到这张卡的相关卡片列表中。
	aux.AddCodeList(c,46986414)
	-- ①：对方把怪兽的效果发动时或者对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)
	-- ②：1回合1次，对方把场上的怪兽的效果发动时或者对方怪兽攻击的伤害计算时才能发动。从自己的卡组·墓地选1只「黑魔术师」或者攻击力300/守备力200的怪兽加入手卡或特殊召唤。那之后，可以把那只对方怪兽的攻击力变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(s.thcon1)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetCondition(s.thcon2)
	c:RegisterEffect(e4)
end
-- 判断特殊召唤的发动条件是否满足：对方玩家发动了怪兽的效果。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 判断特殊召唤的发动条件是否满足：对方怪兽进行攻击宣言。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击宣言的怪兽是否由对方玩家控制。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 特殊召唤效果的发动准备与检查：检查自己场上的怪兽区域是否有空位，且这张卡是否可以进行特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自己场上的怪兽区域是否存在空余的位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置连锁操作信息：包含特殊召唤这张卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤的效果处理：如果这张卡与当前连锁相关联，则将其特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：属于融合怪兽且表侧表示存在（冗余过滤函数）。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 判断检索/特召效果的发动条件是否满足：对方在场上发动了怪兽的效果，并将发动该效果的怪兽记录为效果对象的目标。
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (ep==1-tp and re:GetActivateLocation()==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER)) then return false end
	e:SetLabelObject(re:GetHandler())
	return true
end
-- 判断检索/特召效果的发动条件是否满足：对方怪兽攻击进行伤害计算，并将进行攻击的怪兽记录为效果对象的目标。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的对方怪兽。
	local a=Duel.GetAttacker()
	if not a:IsControler(1-tp) then return false end
	e:SetLabelObject(a)
	return true
end
-- 过滤条件：属于「黑魔术师」或攻击力300且守备力200的怪兽，且可以被加入手卡或进行特殊召唤。
function s.thfilter(c,e,tp)
	if not (c:IsAttack(300) and c:IsDefense(200) or c:IsCode(46986414)) then return false end
	-- 获取自己场上主要的怪兽区域的可放置空位数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 检索/特召效果的发动准备与检查：在效果发动时，检查卡组及墓地中是否存在满足条件的怪兽，并将之前记录的对方怪兽设定为效果处理的对象。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查自己卡组或墓地里是否存在至少1张可以进行操作的满足条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 将之前记录的对方怪兽设定为当前连锁的效果对象。
	Duel.SetTargetCard(e:GetLabelObject())
end
-- 检索/特召效果的处理：从卡组或墓地选择1只满足条件的卡片加入手卡或特殊召唤，成功后可选择使作为效果对象的对方怪兽攻击力变为0。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组或墓地选择1张不受「王家长眠之谷」影响且满足过滤条件的卡片。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取自己场上主要的怪兽区域空余的格子数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local oc=g:GetFirst()
	if oc then
		local res=true
		-- 判断选择的卡是否以加入手卡方式处理：当卡片能够加入手卡且无法特殊召唤，或没有特殊召唤的空格，又或是玩家主动选择加入手卡时。
		if oc:IsAbleToHand() and (not oc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 由于效果处理将选中的卡片加入手卡。
			Duel.SendtoHand(oc,nil,REASON_EFFECT)
			-- 向对方玩家展示（确认）已加入手卡的卡片。
			Duel.ConfirmCards(1-tp,oc)
			res=oc:IsLocation(LOCATION_HAND)
		elseif ft>0 and oc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选中的卡片以表侧表示特殊召唤到自己场上，并判断是否成功召唤。
			res=Duel.SpecialSummon(oc,0,tp,tp,false,false,POS_FACEUP)>0
		end
		-- 获取在效果发动时被设定为连锁对象的对方怪兽。
		local tc=Duel.GetFirstTarget()
		if tc and res and tc:IsRelateToChain() and tc:IsControler(1-tp) and tc:IsFaceup() and tc:GetAttack()>0
			-- 询问玩家是否要将该对方怪兽的攻击力变成0，并检查其是否具有效果免疫。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) and not tc:IsImmuneToEffect(e) then  --"是否把攻击力变成0？"
			-- 中断效果处理，使得后续使攻击力归0的操作与之前的检索/召唤不视为同时进行。
			Duel.BreakEffect()
			-- 那之后，可以把那只对方怪兽的攻击力变成0。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
