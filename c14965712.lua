--増殖するクリボー！
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方把怪兽的效果发动时或者对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，对方把场上的怪兽的效果发动时或者对方怪兽攻击的伤害计算时才能发动。从自己的卡组·墓地选1只「黑魔术师」或者攻击力300/守备力200的怪兽加入手卡或特殊召唤。那之后，可以把那只对方怪兽的攻击力变成0。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡名记述「黑魔术师」、手卡特殊召唤的①效果以及场上检索或特召并可降攻的②效果
function s.initial_effect(c)
	-- 记录此卡文本上记述了「黑魔术师」卡名
	aux.AddCodeList(c,46986414)
	-- 这个卡名的①的效果1回合只能使用1次。 ①：对方把怪兽的效果发动时或者对方怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤。
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
	-- ②：1回合1次，对方把场上的怪兽的效果发动时或者对方怪兽攻击的伤害计算时才能发动。从自己的卡组·墓地选1只「黑魔术师」或者攻击力300/守备力200的怪兽加入手卡或特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
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
-- 发动条件检查，确认是否为对方发动的怪兽效果
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 发动条件检查，确认攻击怪兽是否为对方控制
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前进行攻击的怪兽控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 检查自己怪兽区是否有空位且此卡可表侧表示特殊召唤，并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否至少有1个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置将手卡的这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理，确认此卡仍与效果关联后从手卡表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，检查是否为场上表侧表示的融合怪兽（冗余辅助函数）
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 发动条件检查，确认是否为对方场上怪兽发动的效果，并记录发动效果的怪兽卡
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (ep==1-tp and re:GetActivateLocation()==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER)) then return false end
	e:SetLabelObject(re:GetHandler())
	return true
end
-- 发动条件检查，确认是否为对方怪兽进行的攻击，并记录该攻击怪兽卡
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	if not a:IsControler(1-tp) then return false end
	e:SetLabelObject(a)
	return true
end
-- 过滤函数，检查是否为「黑魔术师」或攻击力300·守备力200的怪兽，且能加入手卡或在有空位时可特殊召唤
function s.thfilter(c,e,tp)
	if not (c:IsAttack(300) and c:IsDefense(200) or c:IsCode(46986414)) then return false end
	-- 获取自己怪兽区域的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 检查卡组·墓地是否存在符合条件的怪兽，并将此前记录的对方怪兽设为连锁对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组·墓地是否存在至少1只满足加入手卡或特殊召唤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 将引发发动的对方怪兽关联为本次连锁的对象
	Duel.SetTargetCard(e:GetLabelObject())
end
-- 效果处理，从卡组·墓地选1只符合条件的怪兽加入手卡或特殊召唤，之后可选择把那只对方怪兽攻击力变为0
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示控制者选择要加入手卡或特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组·墓地（受王家长眠之谷限制过滤）选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取当前自己怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local oc=g:GetFirst()
	if oc then
		local res=true
		-- 判断选中的怪兽是否加入手卡（可加手且无法特召、无空位或玩家选择加手时执行）
		if oc:IsAbleToHand() and (not oc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 将选中的怪兽加入自己手卡
			Duel.SendtoHand(oc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,oc)
			res=oc:IsLocation(LOCATION_HAND)
		elseif ft>0 and oc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选中的怪兽表侧表示特殊召唤到自己场上并记录是否成功
			res=Duel.SpecialSummon(oc,0,tp,tp,false,false,POS_FACEUP)>0
		end
		-- 获取之前关联的对方怪兽
		local tc=Duel.GetFirstTarget()
		if tc and res and tc:IsRelateToChain() and tc:IsControler(1-tp) and tc:IsFaceup() and tc:GetAttack()>0
			-- 询问自己是否把那只对方怪兽攻击力变为0，并检查其是否不受效果影响
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) and not tc:IsImmuneToEffect(e) then  --"是否把攻击力变成0？"
			-- 中断当前效果处理，使后续改变攻击力的效果视为不同时处理
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
