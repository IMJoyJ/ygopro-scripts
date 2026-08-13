--電子光虫－レジストライダー
-- 效果：
-- 把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
-- ①：自己对昆虫族·3星怪兽的召唤成功时才能发动。这张卡从手卡特殊召唤。那之后，可以把这张卡和那只怪兽的等级变成5星或者7星。
-- ②：这张卡从手卡的特殊召唤成功的场合才能发动。选自己场上1只昆虫族怪兽把表示形式变更。
-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡的攻击力·守备力上升1000。
function c19301729.initial_effect(c)
	-- 把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(c19301729.xyzlimit)
	c:RegisterEffect(e0)
	-- ①：自己对昆虫族·3星怪兽的召唤成功时才能发动。这张卡从手卡特殊召唤。那之后，可以把这张卡和那只怪兽的等级变成5星或者7星。
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
	-- ②：这张卡从手卡的特殊召唤成功的场合才能发动。选自己场上1只昆虫族怪兽把表示形式变更。
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
	-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。●这张卡的攻击力·守备力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c19301729.efcon)
	e3:SetOperation(c19301729.efop)
	c:RegisterEffect(e3)
end
-- 判定非昆虫族怪兽不能作为超量素材：当素材怪兽不是昆虫族时返回true，使这张卡不能成为该超量召唤的素材。
function c19301729.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_INSECT)
end
-- 发动条件：当自己成功召唤昆虫族·3星怪兽时，该召唤控制者是己方且召唤的怪兽为昆虫族·3星。
function c19301729.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=eg:GetFirst()
	return ep==tp and ec:IsLevel(3) and ec:IsRace(RACE_INSECT)
end
-- 发动时点检测：己方主要怪兽区有空位，且这张卡在手牌可以被特殊召唤。
function c19301729.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否存在空闲区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将召唤成功的那只昆虫族·3星怪兽设为当前效果关联的对象，便于后续处理时判断其是否仍可作为等级变更对象。
	Duel.SetTargetCard(eg)
	-- 设置操作信息：本次效果将进行特殊召唤，对象为本卡，数量1，地点不特定（手牌）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理①效果：先特殊召唤这张卡，若特殊召唤成功且玩家选择变更等级，则中断当前连锁，将这张卡与仍关联的召唤怪兽（若还在场上且表侧表示）组成对象组，由玩家宣言5或7，然后为该组怪兽附加等级变更效果。
function c19301729.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤本卡，若成功且玩家选择‘是’（变更等级），则进入等级变更处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.SelectYesNo(tp,aux.Stringid(19301729,2)) then  --"是否改变等级？"
		-- 中断当前效果处理，使后续的等级变更效果作为独立处理，避免错过时点。
		Duel.BreakEffect()
		local g=Group.FromCards(c)
		if tc:IsRelateToEffect(e) then g:AddCard(tc) end
		g=g:Filter(Card.IsFaceup,nil)
		-- 让玩家宣言一个数字（5或7），作为要变更的等级。
		local lv=Duel.AnnounceNumber(tp,5,7)
		-- 遍历需要变更等级的怪兽组，对每只怪兽施加等级变更效果。
		for oc in aux.Next(g) do
			-- 把这张卡和那只怪兽的等级变成5星或者7星。
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
-- ②效果的发动条件：通过判定这张卡在特殊召唤成功之前位于手牌，来确定它是从手卡特殊召唤的。
function c19301729.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 选择对象的过滤条件：自己场上的表侧表示昆虫族怪兽，且该怪兽当前可以变更表示形式。
function c19301729.posfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsFaceup() and c:IsCanChangePosition()
end
-- ②效果的目标检测：己方场上存在至少1只符合条件的昆虫族怪兽即可发动，并设置操作信息为变更表示形式。
function c19301729.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：己方场上存在1只表侧表示且可变更表示形式的昆虫族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19301729.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：本次效果将变更1只怪兽的表示形式，所在位置为怪兽区。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
end
-- 处理②效果：提示选择表示形式变更对象，选择己方场上1只昆虫族怪兽，手动标记选择动画，然后按规则切换其表示形式。
function c19301729.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让己方玩家从自己场上选择1只符合条件的昆虫族怪兽作为效果对象。
	local g=Duel.SelectMatchingCard(tp,c19301729.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 手动为选中的怪兽显示被选为对象的动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 变更该怪兽的表示形式：表侧攻击变表侧守备，表侧守备变里侧守备，里侧守备变表侧攻击，里侧攻击变表侧攻击。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- ③效果的触发条件：这张卡作为超量召唤的素材被使用（原因代号REASON_XYZ）。
function c19301729.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 处理③效果：给超量召唤出的怪兽赋予攻击力·守备力上升1000的效果；若该怪兽不是效果怪兽，则追加效果怪兽类型以便适用所得效果；最后附加‘电子光虫-电阻水黾效果适用中’的提示标记。
function c19301729.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡的攻击力·守备力上升1000。
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
		-- ③：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(19301729,3))  --"「电子光虫-电阻水黾」效果适用中"
end
