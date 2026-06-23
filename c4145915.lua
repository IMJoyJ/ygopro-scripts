--ギミック・パペット－キラーナイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是「机关傀儡」怪兽不能从额外卡组特殊召唤。
-- ①：这张卡在手卡存在的场合，以自己墓地1只「机关傀儡」怪兽或者对方墓地1只怪兽为对象才能发动。那只怪兽在持有者场上效果无效守备表示特殊召唤。那之后，这张卡特殊召唤。
-- ②：这张卡从手卡以外送去墓地的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片的效果，并添加用于限制特殊召唤的自定义计数器
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合能使用1次，这些效果发动的回合，自己不是「机关傀儡」怪兽不能从额外卡组特殊召唤。①：这张卡在手卡存在的场合，以自己墓地1只「机关傀儡」怪兽或者对方墓地1只怪兽为对象才能发动。那只怪兽在持有者场上效果无效守备表示特殊召唤。那之后，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合能使用1次，这些效果发动的回合，自己不是「机关傀儡」怪兽不能从额外卡组特殊召唤。②：这张卡从手卡以外送去墓地的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 添加用于检测特殊召唤非「机关傀儡」怪兽的自定义计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 过滤函数：当特召的怪兽不是来自额外卡组，或者是表侧表示的「机关傀儡」怪兽时返回true（不增加计数）
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x1083) and c:IsFaceup()
end
-- 限制/誓约处理：检查本回合是否未特召过非「机关傀儡」怪兽，并在发动时注册限制本回合不能从额外卡组特召非「机关傀儡」怪兽的效果
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查玩家本回合是否没有从额外卡组特殊召唤过非「机关傀儡」怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这些效果发动的回合，自己不是「机关傀儡」怪兽不能从额外卡组特殊召唤。①：这张卡在手卡存在的场合，以自己墓地1只「机关傀儡」怪兽或者对方墓地1只怪兽为对象才能发动。那只怪兽在持有者场上效果无效守备表示特殊召唤。那之后，这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家tp注册不能从额外卡组特殊召唤非「机关傀儡」怪兽的誓约限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数：限制玩家不能从额外卡组特殊召唤非「机关傀儡」怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x1083) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：筛选自己墓地的「机关傀儡」怪兽或者对方墓地的怪兽，并进行特殊召唤空间判定
function s.spfilter(c,e,tp)
	local cp=c:GetOwner()
	return (c:IsSetCard(0x1083) and c:IsControler(tp) or c:IsControler(1-tp))
		-- 若目标持有者为自己，检查自己场上的怪兽区域空位数是否大于1（需特召目标和此卡），且目标能否在自己场上守备表示特殊召唤
		and (cp==tp and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 若目标持有者为对方，检查自己和对方场上的怪兽区域空位数是否都大于0，且目标能否在对方场上守备表示特殊召唤
		or cp==1-tp and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp))
end
-- 效果①的发动条件与对象判定：需要能进行2次特殊召唤、手牌的此卡可特殊召唤，且自己或对方墓地存在符合条件的对象怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 在chk==0时，检查玩家这回合是否可以进行2次以上的特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己或对方的墓地是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己或对方墓地中选择1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	g:AddCard(c)
	-- 设置特殊召唤的操作信息，将所选怪兽和手牌的此卡放入特殊召唤候选对象中
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：先特殊召唤被选择的墓地怪兽且效果无效化，若成功则将此卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local res=false
		local cp=tc:GetOwner()
		-- 若目标怪兽的持有者是自己，检查自己场上是否有可用的怪兽区域空格，并且该怪兽能否在自己场上特殊召唤
		if cp==tp and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 执行将被选择的怪兽以守备表示特殊召唤到自己场上的分解步骤
			res=Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			if res then
				-- 效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 效果无效
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
			-- 完成分解特殊召唤的流程处理
			Duel.SpecialSummonComplete()
		-- 若目标怪兽的持有者是对方，检查对方场上是否有可用的怪兽区域空格，并且该怪兽能否在对方场上特殊召唤
		elseif cp==1-tp and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp) then
			-- 执行将被选择的怪兽以守备表示特殊召唤到对方场上的分解步骤
			res=Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
			if res then
				-- 效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 效果无效
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
			-- 完成分解特殊召唤的流程处理
			Duel.SpecialSummonComplete()
		end
		-- 若前置怪兽特殊召唤成功，且手牌的此卡仍满足特殊召唤条件、自己场上有空余的怪兽区域
		if res and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 中断当前效果处理，使前后的效果处理不视为同时进行
			Duel.BreakEffect()
			-- 将手牌的此卡在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果②的发动条件：此卡从手牌以外送去墓地的场合
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 效果②的对象与效果判定：检查此卡能否加入手卡，并设定回收的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置加入手卡的操作信息，将此卡作为目标并设定回收数量为1
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将此卡加入手卡，并让对方玩家确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡从墓地送回手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 展示被加入手卡的此卡，向对方玩家进行确认
		Duel.ConfirmCards(1-tp,c)
	end
end
