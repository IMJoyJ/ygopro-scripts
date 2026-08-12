--未界域のサンダーバード
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的雷鸟」以外的场合，再从手卡把1只「未界域的雷鸟」特殊召唤，自己从卡组抽1张。
-- ②：这张卡从手卡丢弃的场合，以对方场上盖放的1张卡为对象才能发动。那张卡破坏。
function c90807199.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的雷鸟」以外的场合，再从手卡把1只「未界域的雷鸟」特殊召唤，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90807199,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c90807199.spcost)
	e1:SetTarget(c90807199.sptg)
	e1:SetOperation(c90807199.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡丢弃的场合，以对方场上盖放的1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90807199,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DISCARD)
	e2:SetCountLimit(1,90807199)
	e2:SetTarget(c90807199.destg)
	e2:SetOperation(c90807199.desop)
	c:RegisterEffect(e2)
end
-- 效果①的Cost：检查自身是否未公开（即在手卡中未给对方观看）。
function c90807199.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：检查卡片是否为「未界域的雷鸟」且可以特殊召唤。
function c90807199.spfilter(c,e,tp)
	return c:IsCode(90807199) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的Target：检查手卡中是否有可丢弃的卡，并设置丢弃手卡的操作信息。
function c90807199.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡中是否存在至少1张可以因效果丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 效果①的Operation：由对方随机选1张手卡丢弃，若不是「未界域的雷鸟」，则特召手卡的「未界域的雷鸟」并抽1张卡。
function c90807199.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己当前的所有手卡。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g<1 then return end
	local tc=g:RandomSelect(1-tp,1):GetFirst()
	-- 成功丢弃随机选出的卡，并判断该卡是否不是「未界域的雷鸟」。
	if tc and Duel.SendtoGrave(tc,REASON_DISCARD+REASON_EFFECT)~=0 and not tc:IsCode(90807199)
		-- 检查自己的主要怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取手卡中所有满足特召条件的「未界域的雷鸟」。
		local spg=Duel.GetMatchingGroup(c90807199.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if spg:GetCount()<=0 then return end
		local sg=spg
		if spg:GetCount()~=1 then
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=spg:Select(tp,1,1,nil)
		end
		-- 中断当前效果处理，使后续的特殊召唤和抽卡不与丢弃手卡视为同时处理。
		Duel.BreakEffect()
		-- 将选择的「未界域的雷鸟」特殊召唤，并检查是否特召成功。
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 玩家从卡组抽1张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 效果②的Target：检查并选择对方场上盖放的1张卡作为破坏对象。
function c90807199.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	-- 检查对方场上是否存在可以作为对象的里侧表示（盖放）的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张里侧表示的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁信息，表示该效果包含破坏选定卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的Operation：破坏作为效果对象的卡。
function c90807199.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该目标卡片。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
