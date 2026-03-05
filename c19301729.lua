--電子光虫－レジストライダー
-- 效果：
-- 把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
-- ①：自己对昆虫族·3星怪兽的召唤成功时才能发动。这张卡从手卡特殊召唤。那之后，可以把这张卡和那只怪兽的等级变成5星或者7星。
-- ②：这张卡从手卡的特殊召唤成功的场合才能发动。选自己场上1只昆虫族怪兽把表示形式变更。
-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡的攻击力·守备力上升1000。
function c19301729.initial_effect(c)
	-- 效果原文：把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(c19301729.xyzlimit)
	c:RegisterEffect(e0)
	-- 效果原文：①：自己对昆虫族·3星怪兽的召唤成功时才能发动。这张卡从手卡特殊召唤。那之后，可以把这张卡和那只怪兽的等级变成5星或者7星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19301729,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c19301729.spcon)
	e1:SetTarget(c19301729.sptg)
	e1:SetOperation(c19301729.spop)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡从手卡的特殊召唤成功的场合才能发动。选自己场上1只昆虫族怪兽把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19301729,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c19301729.poscon)
	e2:SetTarget(c19301729.postg)
	e2:SetOperation(c19301729.posop)
	c:RegisterEffect(e2)
	-- 效果原文：③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。●这张卡的攻击力·守备力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c19301729.efcon)
	e3:SetOperation(c19301729.efop)
	c:RegisterEffect(e3)
end
-- 规则层面：设置该卡不能被作为超量素材的条件，只有非昆虫族怪兽不能作为超量素材。
function c19301729.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_INSECT)
end
-- 规则层面：判断是否为己方3星昆虫族怪兽召唤成功，满足条件才能发动效果。
function c19301729.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep==tp and ec:IsLevel(3) and ec:IsRace(RACE_INSECT)
end
-- 规则层面：判断是否可以将该卡特殊召唤，检查场上是否有空位及卡本身是否可特殊召唤。
function c19301729.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查场上是否有空位用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面：将召唤成功的怪兽设为效果处理的目标。
	Duel.SetTargetCard(eg)
	-- 规则层面：设置效果处理信息，表示要特殊召唤该卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面：执行特殊召唤操作，并询问是否改变等级。
function c19301729.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面：判断是否成功特殊召唤并询问是否改变等级。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.SelectYesNo(tp,aux.Stringid(19301729,2)) then  --"是否改变等级？"
		-- 规则层面：中断当前效果处理，使后续效果视为不同时处理。
		Duel.BreakEffect()
		local g=Group.FromCards(c)
		if tc:IsRelateToEffect(e) then g:AddCard(tc) end
		g=g:Filter(Card.IsFaceup,nil)
		-- 规则层面：让玩家宣言一个等级（5或7）。
		local lv=Duel.AnnounceNumber(tp,5,7)
		-- 规则层面：遍历卡片组中的每张卡。
		for oc in aux.Next(g) do
			-- 效果原文：●这张卡的攻击力·守备力上升1000。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			oc:RegisterEffect(e1)
		end
	end
end
-- 规则层面：判断该卡是否从手卡特殊召唤成功。
function c19301729.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 规则层面：定义筛选场上昆虫族且可改变表示形式的怪兽的过滤函数。
function c19301729.posfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsFaceup() and c:IsCanChangePosition()
end
-- 规则层面：判断是否可以选场上一只昆虫族怪兽改变表示形式。
function c19301729.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查场上是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19301729.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 规则层面：设置效果处理信息，表示要改变怪兽表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
end
-- 规则层面：执行改变表示形式的操作。
function c19301729.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 规则层面：选择场上一只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c19301729.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 规则层面：显示被选中的怪兽动画效果。
		Duel.HintSelection(g)
		-- 规则层面：将选中的怪兽改变为指定表示形式。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 规则层面：判断该卡是否作为超量素材被使用。
function c19301729.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 规则层面：为超量召唤的怪兽增加攻击力和守备力各1000点，并确保其具有效果类型。
function c19301729.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 效果原文：●这张卡的攻击力·守备力上升1000。
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	rc:RegisterEffect(e2,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 效果原文：●这张卡的攻击力·守备力上升1000。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19301729,3))  --"「电子光虫-电阻水黾」效果适用中"
end
