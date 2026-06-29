--聖なる薊花
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的「罪宝」卡从自己的手卡·场上送去墓地（里侧表示卡翻开确认）。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只「蓟花」怪兽为对象才能发动。那只怪兽回到卡组，这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动时特殊召唤）和②效果（墓地起动回收）。
function s.initial_effect(c)
	-- ①：把额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的「罪宝」卡从自己的手卡·场上送去墓地（里侧表示卡翻开确认）。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只「蓟花」怪兽为对象才能发动。那只怪兽回到卡组，这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 过滤额外卡组中满足条件的「蓟花」融合怪兽：等级不小于4、可以被特殊召唤，且手卡·场上有足够数量（等级每4星为1张）的「罪宝」卡作为送去墓地的素材。
function s.filter(c,e,tp,mg)
	if c:GetLevel()<4 then return false end
	local ct=math.floor(c:GetLevel()/4)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1bc) and c:CheckFusionMaterial()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and mg:CheckSubGroup(s.gcheck,ct,ct,tp,c)
end
-- 检查选取的「罪宝」卡组是否满足：送去墓地后能腾出足够的额外怪兽区域空位，且所有选取的卡都能送去墓地。
function s.gcheck(g,tp,fc)
	-- 检查在选取的卡片离场后，是否能在额外怪兽区域或连接端特殊召唤该融合怪兽。
	return Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
		and g:FilterCount(Card.IsAbleToGrave,nil)==g:GetCount()
end
-- ①效果的发动准备与合法性检测，检查手卡·场上是否有足够的「罪宝」卡，以及额外卡组是否有可特殊召唤的「蓟花」融合怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家手卡及场上的所有「罪宝」卡。
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 检查是否存在必须作为融合素材的卡片限制。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查额外卡组是否存在至少1只满足特殊召唤条件的「蓟花」融合怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置连锁处理的操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的实际处理：展示额外卡组的「蓟花」融合怪兽，将对应数量的「罪宝」卡送去墓地（里侧表示卡翻开确认），然后将该融合怪兽当作融合召唤特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查必须作为融合素材的卡片限制，若不满足则直接结束效果处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 获取当前手卡及场上的所有「罪宝」卡。
	local mg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足特殊召唤条件的「蓟花」融合怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的融合怪兽给对方玩家观看。
		Duel.ConfirmCards(1-tp,tc)
		local ct=math.floor(tc:GetLevel()/4)
		-- 提示玩家选择要送去墓地的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=mg:SelectSubGroup(tp,s.gcheck,false,ct,ct,tp,tc)
		local cg=sg:Filter(Card.IsFacedown,nil)
		-- 将选中的里侧表示卡片翻开给对方确认。
		Duel.ConfirmCards(1-tp,cg)
		-- 将选中的「罪宝」卡因效果送去墓地，并确认其中至少有1张成功送去墓地。
		if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)~=0 then
			tc:SetMaterial(nil)
			-- 中断当前效果处理，使后续的特殊召唤处理与送去墓地不视为同时进行（会造成错时点）。
			Duel.BreakEffect()
			if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end
-- 过滤场上（表侧表示）或墓地的「蓟花」怪兽，且该怪兽必须能回到卡组。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER)
		and c:IsAbleToDeck() and c:IsSetCard(0x1bc)
end
-- ②效果的发动准备与合法性检测，选择自己场上或墓地1只「蓟花」怪兽作为对象，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查自己场上或墓地是否存在可回到卡组的「蓟花」怪兽，且墓地的这张卡自身能加入手卡。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		and c:IsAbleToHand() end
	-- 提示玩家选择要回到卡组的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择自己场上或墓地1只「蓟花」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置连锁处理的操作信息：将选中的怪兽送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置连锁处理的操作信息：将墓地的这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②效果的实际处理：使作为对象的怪兽回到卡组，若成功，则将墓地的这张卡加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的效果对象（即选中的「蓟花」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关、不受「王家长眠之谷」影响且仍为怪兽卡。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and tc:IsType(TYPE_MONSTER)
		-- 将对象怪兽送回持有者的卡组并洗牌，确认是否成功回到卡组。
		and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		and c:IsRelateToEffect(e) then
		-- 将墓地的这张卡加入手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
