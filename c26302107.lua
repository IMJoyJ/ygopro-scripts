--未界域のワーウルフ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的狼人」以外的场合，再从手卡把1只「未界域的狼人」特殊召唤，自己从卡组抽1张。
-- ②：这张卡从手卡丢弃的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
function c26302107.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的狼人」以外的场合，再从手卡把1只「未界域的狼人」特殊召唤，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26302107,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c26302107.spcost)
	e1:SetTarget(c26302107.sptg)
	e1:SetOperation(c26302107.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡丢弃的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26302107,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DISCARD)
	e2:SetCountLimit(1,26302107)
	e2:SetTarget(c26302107.atktg)
	e2:SetOperation(c26302107.atkop)
	c:RegisterEffect(e2)
end
-- 效果发动时需要确认手卡的这张卡是否公开（IsPublic），未公开则不能发动。
function c26302107.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 用于筛选手卡中可以特殊召唤的「未界域的狼人」卡片。
function c26302107.spfilter(c,e,tp)
	return c:IsCode(26302107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁处理信息，表示将要丢弃1张手牌。
function c26302107.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否至少有1张手牌可以被丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	-- 设置连锁处理信息，表示将要丢弃1张手牌。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 处理①效果的主要逻辑：随机选择对方手牌并丢弃，若非「未界域的狼人」则特殊召唤并抽卡。
function c26302107.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家手牌组。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g<1 then return end
	local tc=g:RandomSelect(1-tp,1):GetFirst()
	-- 判断是否成功将对方选中的卡丢入墓地且不是「未界域的狼人」。
	if tc and Duel.SendtoGrave(tc,REASON_DISCARD+REASON_EFFECT)~=0 and not tc:IsCode(26302107)
		-- 判断是否有足够的怪兽区域进行特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取玩家手牌中所有「未界域的狼人」卡片。
		local spg=Duel.GetMatchingGroup(c26302107.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if spg:GetCount()<=0 then return end
		local sg=spg
		if spg:GetCount()~=1 then
			-- 提示玩家选择要特殊召唤的「未界域的狼人」。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=spg:Select(tp,1,1,nil)
		end
		-- 中断当前效果处理，使后续效果视为错时处理。
		Duel.BreakEffect()
		-- 将选择的「未界域的狼人」特殊召唤到场上。
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 从卡组抽1张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 设置②效果的目标检查，确认对方场上是否有表侧表示的怪兽。
function c26302107.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 处理②效果的主要逻辑：将对方场上所有表侧表示怪兽的攻击力下降1000。
function c26302107.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为对方场上的怪兽设置攻击力下降1000的效果，持续到回合结束。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
