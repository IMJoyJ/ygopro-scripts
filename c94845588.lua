--聖なる薊花
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的「罪宝」卡从自己的手卡·场上送去墓地（里侧表示卡翻开确认）。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己的场上·墓地1只「蓟花」怪兽为对象才能发动。那只怪兽回到卡组，这张卡加入手卡。
local s,id,o=GetID()
-- 初始化函数：注册①效果（自由时点发动的魔陷效果，分类为特殊召唤+融合召唤+送墓，展示并当作融合召唤特殊召唤额外卡组的「蓟花」融合怪兽）和②效果（墓地发动的起动效果，取对象，1回合1次，让自己场上·墓地的「蓟花」怪兽回卡组、这张卡回手卡）
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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的场合，以自己的场上·墓地1只「蓟花」怪兽为对象才能发动。那只怪兽回到卡组，这张卡加入手卡。
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
-- 过滤函数：筛选额外卡组中等级4以上、能作为融合召唤特殊召唤的「蓟花」融合怪兽，且手卡·场上的「罪宝」卡中能选出其等级每4星为1张的合格素材组合
function s.filter(c,e,tp,mg)
	if c:GetLevel()<4 then return false end
	local ct=math.floor(c:GetLevel()/4)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1bc) and c:CheckFusionMaterial()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and mg:CheckSubGroup(s.gcheck,ct,ct,tp,c)
end
-- 素材组合检查：选出的「罪宝」卡全部能够送去墓地，且这些卡离场后场上仍有能让额外卡组怪兽出场的空格
function s.gcheck(g,tp,fc)
	-- 确认这些素材卡离场后，场上仍有可供额外卡组怪兽特殊召唤的空格
	return Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
		and g:FilterCount(Card.IsAbleToGrave,nil)==g:GetCount()
end
-- ①效果的目标函数：收集手卡·场上的「罪宝」卡，发动时确认没有必须成为融合素材的限制且额外卡组存在满足条件的可特殊召唤的「蓟花」融合怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索自己手卡·场上所有的「罪宝」卡作为候选融合素材
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 发动条件检测：确认没有卡受到必须成为融合素材的效果影响
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 确认额外卡组存在至少1只满足过滤条件的「蓟花」融合怪兽（有对应的「罪宝」素材组合且能特殊召唤）
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置操作信息：本连锁将要从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：选择额外卡组1只「蓟花」融合怪兽给对方观看，按其等级每4星为1张选「罪宝」卡（里侧表示卡翻开确认）送去墓地，之后把观看的怪兽当作融合召唤特殊召唤并完成召唤手续
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认没有必须成为融合素材的效果限制，否则中止处理
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 重新检索自己手卡·场上的「罪宝」卡作为素材候选
	local mg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil,0x19e)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「蓟花」融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 把选中的融合怪兽给对方观看确认
		Duel.ConfirmCards(1-tp,tc)
		local ct=math.floor(tc:GetLevel()/4)
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=mg:SelectSubGroup(tp,s.gcheck,false,ct,ct,tp,tc)
		local cg=sg:Filter(Card.IsFacedown,nil)
		-- 把送去墓地的素材中里侧表示的卡翻开给对方确认
		Duel.ConfirmCards(1-tp,cg)
		-- 把选出的「罪宝」卡送去墓地，并确认至少有卡实际被送入墓地才继续处理
		if Duel.SendtoGrave(sg,REASON_EFFECT)~=0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)~=0 then
			tc:SetMaterial(nil)
			-- 中断效果处理，使之后的特殊召唤与送墓视为不同时进行
			Duel.BreakEffect()
			-- 把观看过的融合怪兽当作融合召唤在自己场上表侧表示特殊召唤
			if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end
-- 过滤函数：筛选表侧表示、能回到卡组的「蓟花」怪兽
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER)
		and c:IsAbleToDeck() and c:IsSetCard(0x1bc)
end
-- ②效果的目标函数：以自己场上·墓地1只「蓟花」怪兽为对象，发动时确认存在可成为对象的怪兽且这张卡能加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 确认自己场上·墓地存在至少1只能成为对象、可回到卡组的「蓟花」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		and c:IsAbleToHand() end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 以自己场上·墓地1只满足条件的「蓟花」怪兽为对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：将对象的卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	-- 设置操作信息：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②效果处理：对象怪兽仍与效果关联且不受「王家长眠之谷」影响的场合，将其回到卡组并洗牌，确实回到卡组且这张卡仍与效果关联时，这张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与本效果关联、不受「王家长眠之谷」影响且仍是怪兽
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and tc:IsType(TYPE_MONSTER)
		-- 把对象怪兽回到持有者卡组并洗牌，确认确实回到卡组
		and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		and c:IsRelateToEffect(e) then
		-- 把墓地的这张卡加入持有者手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
