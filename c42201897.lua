--アザミナ・ハマルティア
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的自己的墓地·除外状态的「罪宝」卡回到卡组。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1张「罪宝」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
local s,id,o=GetID()
-- 初始化卡片效果：注册①卡片发动时特殊召唤蓟花融合怪兽的效果，以及②墓地除外自身盖放罪宝魔陷的诱发即时效果
function s.initial_effect(c)
	-- ①：把额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的自己的墓地·除外状态的「罪宝」卡回到卡组。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_GRAVE_ACTION+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1张「罪宝」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 把墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 过滤额外卡组中可展示并特殊召唤的「蓟花」融合怪兽
function s.filter(c,e,tp,mg)
	if c:GetLevel()<4 then return false end
	local ct=math.floor(c:GetLevel()/4)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1bc) and c:CheckFusionMaterial()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and mg:CheckSubGroup(s.gcheck,ct,ct,tp,c)
end
-- 检查返回卡组的卡片组是否满足能够回到卡组且场上有额外怪兽区空位
function s.gcheck(g,tp,fc)
	-- 检查将这些卡返回卡组后，额外怪兽区是否有空位特殊召唤该融合怪兽
	return Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
		and g:FilterCount(Card.IsAbleToDeck,nil)==g:GetCount()
end
-- ①效果的发动准备与特殊召唤目标确认
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地·除外状态的表侧表示「罪宝」卡
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsSetCard,Card.IsFaceupEx),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,0x19e)
	-- 检查玩家是否受到必须使用特定融合素材效果的限制
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查额外卡组是否存在可以展示并特殊召唤的「蓟花」融合怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的效果处理：展示额外卡组「蓟花」融合怪兽，将对应数量的「罪宝」卡返回卡组，并将其当作融合召唤特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足必须使用特定融合素材的限制要求
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 获取自己墓地·除外状态不受王家长眠之谷影响的表侧表示「罪宝」卡
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(aux.AND(Card.IsSetCard,Card.IsFaceupEx)),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,0x19e)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择额外卡组1只「蓟花」融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 把选中的融合怪兽给对方观看
		Duel.ConfirmCards(1-tp,tc)
		local ct=math.floor(tc:GetLevel()/4)
		-- 提示玩家选择要返回卡组的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=mg:SelectSubGroup(tp,s.gcheck,false,ct,ct,tp,tc)
		if sg then
			-- 显示被选为返回卡组的对象卡片
			Duel.HintSelection(sg)
			-- 将选中的「罪宝」卡返回卡组并洗牌，并判断是否有卡片成功回到卡组或额外卡组
			if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)~=0 then
				-- 中断当前效果处理，使后续特殊召唤视为不同时处理
				Duel.BreakEffect()
				tc:SetMaterial(nil)
				-- 将给人观看的怪兽当作融合召唤表侧表示特殊召唤
				if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
					tc:CompleteProcedure()
				end
			end
		end
	end
end
-- 过滤墓地中可以盖放到场上的「罪宝」魔法·陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x19e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ②效果的发动准备与取对象
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 检查墓地是否存在可以盖放的「罪宝」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择自己墓地1张「罪宝」魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：1张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②效果的效果处理：将对象卡在自己场上盖放，并赋予本回合不能发动的限制
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的对象卡片
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡仍与效果关联且不受王家长眠之谷影响，在自己场上盖放
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在这个回合不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
