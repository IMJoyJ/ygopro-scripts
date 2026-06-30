--聖なる薊花
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的「罪宝」卡从自己的手卡·场上送去墓地（里侧表示卡翻开确认）。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只「蓟花」怪兽为对象才能发动。那只怪兽回到卡组，这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册效果①（特殊召唤融合怪兽）与效果②（回收手牌）的触发效果
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
-- 过滤额外卡组可以进行特殊召唤的「蓟花」融合怪兽，并计算需要送去墓地的「罪宝」卡数量以及是否有足够的怪兽区空位和可送墓卡
function s.filter(c,e,tp,mg)
	if c:GetLevel()<4 then return false end
	local ct=math.floor(c:GetLevel()/4)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1bc) and c:CheckFusionMaterial()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and mg:CheckSubGroup(s.gcheck,ct,ct,tp,c)
end
-- 检查选定的作为特召代价的卡片是否可以合法送去墓地，并且在该卡片离场后是否有足够的额外怪兽特殊召唤区域
function s.gcheck(g,tp,fc)
	-- 检查在选定的材料送去墓地后，是否能为该额外卡组怪兽提供足够的怪兽区域空位
	return Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
		and g:FilterCount(Card.IsAbleToGrave,nil)==g:GetCount()
end
-- 效果①的发动目标检测，检查是否满足特殊召唤 and 送墓材料的前提条件，并注册特殊召唤操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手牌和场上所有的「罪宝」卡
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 在效果发动检测阶段检查是否有必须作为融合素材的相关限制卡
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 并且检查额外卡组中是否存在可以特殊召唤且有符合送墓条件的「罪宝」卡的「蓟花」融合怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置效果处理的操作信息为：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理，让玩家展示额外卡组的1只「蓟花」融合怪兽，选择其等级每4星为1张的「罪宝」卡送去墓地，然后将展示的怪兽当作融合召唤特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果存在必须作为素材但未被选用的融合素材限制，则无法处理效果
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 获取自己手牌 and 场上的所有「罪宝」卡
	local mg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 提示玩家选择要从额外卡组特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组中选择1只符合条件的「蓟花」融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 向对方展示所选的融合怪兽
		Duel.ConfirmCards(1-tp,tc)
		local ct=math.floor(tc:GetLevel()/4)
		-- 提示玩家选择送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=mg:SelectSubGroup(tp,s.gcheck,false,ct,ct,tp,tc)
		local cg=sg:Filter(Card.IsFacedown,nil)
		-- 将玩家选择的里侧表示的送墓卡片向对方玩家翻开确认
		Duel.ConfirmCards(1-tp,cg)
		-- 将选中的「罪宝」卡送去墓地，并检查是否成功送去墓地
		if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)~=0 then
			tc:SetMaterial(nil)
			-- 中断当前效果，使得送去墓地与特殊召唤的处理视为不同时进行
			Duel.BreakEffect()
			-- 将展示的融合怪兽当作融合召唤特殊召唤，并判断是否成功
			if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end
-- 过滤自己场上或墓地中可以返回卡组的「蓟花」怪兽
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER)
		and c:IsAbleToDeck() and c:IsSetCard(0x1bc)
end
-- 效果②的发动目标检测，检查场上·墓地中是否有可回到卡组的「蓟花」怪兽，以及此卡是否可以加入手牌，并注册相关操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 在效果发动检测阶段检查场上或墓地中是否存在符合返回卡组条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		and c:IsAbleToHand() end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己场上或墓地的1只「蓟花」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置效果处理的操作信息为：将选定的对象怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置效果处理的操作信息为：将墓地的这张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果②的效果处理，将选中的怪兽送回卡组，如果成功送回则将墓地的这张卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为对象的「蓟花」怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果相关，且不受墓穴地带影响且依然是怪兽
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and tc:IsType(TYPE_MONSTER)
		-- 将选定的怪兽送回卡组并洗牌，检查是否成功
		and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		and c:IsRelateToEffect(e) then
		-- 将墓地的这张卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
