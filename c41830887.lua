--複写機塊コピーボックル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「机块」怪兽为对象才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡直到结束阶段当作和作为对象的怪兽同名卡使用。
-- ②：把墓地的这张卡除外，以自己场上1只「机块」怪兽为对象才能发动。从自己的手卡·墓地选1只那只怪兽的同名怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c41830887.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己场上1只「机块」怪兽为对象才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡直到结束阶段当作和作为对象的怪兽同名卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41830887,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,41830887)
	e1:SetTarget(c41830887.sptg1)
	e1:SetOperation(c41830887.spop1)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「机块」怪兽为对象才能发动。从自己的手卡·墓地选1只那只怪兽的同名怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41830887,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,41830888)
	-- 设置②效果的发动条件，禁止此卡在被送去墓地的那个回合发动（由aux.exccon实现）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价，将墓地中的此卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c41830887.sptg2)
	e2:SetOperation(c41830887.spop2)
	c:RegisterEffect(e2)
end
-- 定义通用筛选条件：场上表侧表示且属于「机块」系列的怪兽（0x14b），用于选择对象。
function c41830887.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x14b)
end
-- ①效果发动条件判定：自身可以被特殊召唤、己方主要怪兽区有空位、并存在1只场上表侧表示的「机块」怪兽可选择为对象。
function c41830887.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c41830887.filter(chkc) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查己方主要怪兽区是否存在空余位置，用于特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在1只以上表侧表示且属于「机块」系列的怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c41830887.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的提示，用于对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择1只场上表侧表示且属于「机块」系列的怪兽作为效果对象，并将该对象与当前连锁关联。
	Duel.SelectTarget(tp,c41830887.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，声明本效果将进行1只怪兽（即手卡中的此卡）的特殊召唤，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：将手卡中的此卡特殊召唤上场，若成功则赋予其直到结束阶段视为对象怪兽同名卡的效果，最后完成特殊召唤流程。
function c41830887.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local code=tc:GetOriginalCode()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)) then return end
	-- 以表侧表示将手卡的此卡特殊召唤到己方场上（特殊召唤进程的一步），并判断是否特殊召唤成功。
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡直到结束阶段当作和作为对象的怪兽同名卡使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 完成整个特殊召唤进程，实际结算特殊召唤并触发相关的召唤成功时点。
	Duel.SpecialSummonComplete()
end
-- ②效果对象筛选：己方场上的表侧表示「机块」怪兽，且其当前卡名的同名卡存在于手卡或墓地并可被特殊召唤。
function c41830887.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x14b)
		-- 检查手卡或墓地中是否存在1张以上与对象怪兽同名的、能被特殊召唤的怪兽（不包括效果持有者自身）。
		and Duel.IsExistingMatchingCard(c41830887.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp,c:GetCode())
end
-- 定义可特殊召唤的同名怪兽的筛选条件：卡名与指定代码一致，且能被当前效果特殊召唤。
function c41830887.spfilter2(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动条件判定：己方主要怪兽区有空位，并存在1只满足spfilter1的「机块」怪兽可选择为对象。
function c41830887.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41830887.spfilter1(chkc,e,tp) end
	-- 发动合法性检查：己方主要怪兽区必须存在空位，以供后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在1只以上满足②效果条件的「机块」怪兽可作为对象。
		and Duel.IsExistingTarget(c41830887.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择效果的对象”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只场上满足spfilter1的「机块」怪兽作为效果对象，并关联到连锁。
	Duel.SelectTarget(tp,c41830887.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息，声明本效果将把1只怪兽从手卡或墓地特殊召唤到己方场上（具体是哪张处理时再选，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：若对象怪兽仍与效果相关且表侧表示，则从自己手卡·墓地选择1只与其同名的怪兽特殊召唤。
function c41830887.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 向玩家显示“请选择要特殊召唤的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡和墓地中筛选出1只与对象怪兽同名且能被特殊召唤的怪兽。
		local g=Duel.SelectMatchingCard(tp,c41830887.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode())
		if g:GetCount()>0 then
			-- 将选择出的同名怪兽特殊召唤到己方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
