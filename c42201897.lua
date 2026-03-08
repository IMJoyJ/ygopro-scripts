--アザミナ・ハマルティア
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的自己的墓地·除外状态的「罪宝」卡回到卡组。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1张「罪宝」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
local s,id,o=GetID()
-- 注册两个效果：①特殊召唤效果和②盖放效果
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
	-- 效果发动时把此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 过滤满足条件的额外卡组融合怪兽：等级大于等于4，为蓟花卡组，有融合素材，可以特殊召唤，且其等级每4星对应数量的墓地除外罪宝卡可组成满足条件的融合素材组
function s.filter(c,e,tp,mg)
	if c:GetLevel()<4 then return false end
	local ct=math.floor(c:GetLevel()/4)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1bc) and c:CheckFusionMaterial()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and mg:CheckSubGroup(s.gcheck,ct,ct,tp,c)
end
-- 检查融合素材组是否满足特殊召唤条件：场地位置足够，且所有卡都能送入卡组
function s.gcheck(g,tp,fc)
	-- 检查特殊召唤时是否有足够的额外卡组召唤位置
	return Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
		and g:FilterCount(Card.IsAbleToDeck,nil)==g:GetCount()
end
-- 准备发动效果时，检查是否满足融合召唤的必要条件，以及额外卡组是否存在符合条件的融合怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地和除外状态的罪宝卡
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsSetCard,Card.IsFaceupEx),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,0x19e)
	-- 检查是否满足融合召唤的必要条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查额外卡组是否存在符合条件的融合怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置连锁处理信息：准备特殊召唤一张额外卡组的融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 发动效果：选择额外卡组的融合怪兽，确认给对方观看，然后选择对应数量的墓地除外罪宝卡送回卡组，最后特殊召唤该融合怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查是否满足融合召唤的必要条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 获取自己墓地和除外状态的罪宝卡
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(aux.AND(Card.IsSetCard,Card.IsFaceupEx)),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,0x19e)
	-- 提示玩家选择要特殊召唤的融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择额外卡组中符合条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 向对方展示所选的融合怪兽
		Duel.ConfirmCards(1-tp,tc)
		local ct=math.floor(tc:GetLevel()/4)
		-- 提示玩家选择要送回卡组的罪宝卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=mg:SelectSubGroup(tp,s.gcheck,false,ct,ct,tp,tc)
		if sg:GetCount()>0 then
			-- 显示所选的罪宝卡被选为对象
			Duel.HintSelection(sg)
			-- 将选中的罪宝卡送回卡组并检查是否成功送入卡组
			if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)~=0 then
				-- 中断当前效果处理，使后续处理视为不同时处理
				Duel.BreakEffect()
				tc:SetMaterial(nil)
				-- 特殊召唤所选的融合怪兽
				if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP) then
					tc:CompleteProcedure()
				end
			end
		end
	end
end
-- 过滤满足条件的罪宝魔法陷阱卡：为罪宝卡组，为魔法或陷阱类型，可以盖放
function s.setfilter(c)
	return c:IsSetCard(0x19e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 准备发动盖放效果：选择自己墓地的一张罪宝魔法陷阱卡进行盖放
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 检查是否满足盖放效果的发动条件：墓地是否存在符合条件的罪宝魔法陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的魔法陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择墓地中的罪宝魔法陷阱卡
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息：准备盖放一张魔法陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 发动盖放效果：将选中的魔法陷阱卡盖放在场上，并设置其在本回合不能发动
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡是否仍然有效，且未受王家长眠之谷影响，且成功盖放
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SSet(tp,tc)~=0 then
		-- 设置效果使盖放的卡在本回合不能发动
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
