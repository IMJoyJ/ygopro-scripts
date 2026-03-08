--未界域のビッグフット
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的大脚怪」以外的场合，再从手卡把1只「未界域的大脚怪」特殊召唤，自己抽1张。
-- ②：这张卡从手卡丢弃的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡破坏。
function c43316238.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的大脚怪」以外的场合，再从手卡把1只「未界域的大脚怪」特殊召唤，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43316238,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c43316238.spcost)
	e1:SetTarget(c43316238.sptg)
	e1:SetOperation(c43316238.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡丢弃的场合，以对方场上1张表侧表示卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43316238,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DISCARD)
	e2:SetCountLimit(1,43316238)
	e2:SetTarget(c43316238.destg)
	e2:SetOperation(c43316238.desop)
	c:RegisterEffect(e2)
end
-- 效果发动时，确认自己手卡是否公开（未公开则不能发动）
function c43316238.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤手卡中可以特殊召唤的「未界域的大脚怪」
function c43316238.spfilter(c,e,tp)
	return c:IsCode(43316238) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时，确认自己手卡是否有可丢弃的卡
function c43316238.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时，确认自己手卡是否有可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	-- 设置效果处理时将要丢弃1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果处理：随机选择对方手卡1张丢弃，若非「未界域的大脚怪」则特殊召唤1只「未界域的大脚怪」并抽1张
function c43316238.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手卡的全部卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if g:GetCount()<=0 then return end
	local tc=g:RandomSelect(1-tp,1):GetFirst()
	-- 将随机选择的卡送去墓地并确认是否为「未界域的大脚怪」
	if Duel.SendtoGrave(tc,REASON_DISCARD+REASON_EFFECT)~=0 and not tc:IsCode(43316238)
		-- 确认自己场上是否有空位可特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取自己手卡中所有「未界域的大脚怪」
		local spg=Duel.GetMatchingGroup(c43316238.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if spg:GetCount()<=0 then return end
		local sg=spg
		if spg:GetCount()~=1 then
			-- 提示玩家选择要特殊召唤的「未界域的大脚怪」
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=spg:Select(tp,1,1,nil)
		end
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 将选择的「未界域的大脚怪」特殊召唤
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 特殊召唤成功后，自己抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 效果发动时，选择对方场上1张表侧表示卡作为对象
function c43316238.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 效果发动时，确认对方场上是否有表侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张表侧表示卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理时将要破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：将选择的对方场上卡破坏
function c43316238.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
