--アザミナ・ハマルティア
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的自己的墓地·除外状态的「罪宝」卡回到卡组。那之后，给人观看的怪兽当作融合召唤作特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1张「罪宝」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
local s,id,o=GetID()
-- 注册卡片发动展示额外「蓟花」融合怪兽回收对应数量「罪宝」卡并特召该融合怪兽、以及从墓地除外自身盖放墓地「罪宝」魔陷的效果
function s.initial_effect(c)
	-- ①：把额外卡组1只「蓟花」融合怪兽给对方观看，那个等级每4星为1张的自己的墓地·除外状态的「罪宝」卡回到卡组。那之后，给观看的怪兽当作融合召唤特殊召唤。
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
	-- ②：把墓地的这张卡除外，以自己墓地1张「罪宝」魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 将墓地的此卡除外作为盖放效果发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 额外卡组中属于「蓟花」字段且可用于融合特召的融合怪兽过滤条件
function s.filter(c,e,tp,mg)
	if c:GetLevel()<4 then return false end
	local ct=math.floor(c:GetLevel()/4)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1bc) and c:CheckFusionMaterial()
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and mg:CheckSubGroup(s.gcheck,ct,ct,tp,c)
end
-- 确认所选的作为回收的罪宝卡均符合返回卡组的条件，且额外区域有该融合怪兽的召唤格
function s.gcheck(g,tp,fc)
	-- 检查自己场上的额外怪兽格是否足够容纳该特召怪兽
	return Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
		and g:FilterCount(Card.IsAbleToDeck,nil)==g:GetCount()
end
-- 展示特召效果的发动准备与合法性检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地与除外状态中的全部「罪宝」卡片
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsSetCard,Card.IsFaceupEx),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,0x19e)
	-- 检查玩家当前是否受到必须融合素材限制效果的影响
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查额外卡组中是否存在符合展示和融合召唤条件的「蓟花」融合怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	-- 设置操作信息为从额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 展示融合怪兽并回收墓地/除外「罪宝」卡，以及当作融合召唤特殊召唤效果的执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认是否符合玩家的必须融合素材限制
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 获取自己墓地与除外状态中所有对双方公开的「罪宝」卡片
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(aux.AND(Card.IsSetCard,Card.IsFaceupEx)),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,0x19e)
	-- 向玩家发送提示，请选择需要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只符合条件的「蓟花」融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的融合怪兽展示给对方确认
		Duel.ConfirmCards(1-tp,tc)
		local ct=math.floor(tc:GetLevel()/4)
		-- 向玩家发送提示，请选择需要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		local sg=mg:SelectSubGroup(tp,s.gcheck,false,ct,ct,tp,tc)
		if sg:GetCount()>0 then
			-- 选择与展示融合怪兽星数换算数等量的墓地/除外的「罪宝」卡片
			Duel.HintSelection(sg)
			-- 将这组被选中的「罪宝」卡片送回卡组并洗牌
			if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)~=0 then
				-- 若卡片成功送回卡组，则切断连锁以执行特殊召唤
				Duel.BreakEffect()
				tc:SetMaterial(nil)
				-- 将展示的「蓟花」融合怪兽当作融合召唤以表侧表示特殊召唤
				if Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
					tc:CompleteProcedure()
				end
			end
		end
	end
end
-- 墓地中属于「罪宝」字段且可盖放的魔法或陷阱卡片过滤条件
function s.setfilter(c)
	return c:IsSetCard(0x19e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 墓地「罪宝」盖放效果的发动准备与对象选择
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 检查自己墓地是否存在符合盖放条件的「罪宝」魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择需要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从墓地中选择1张「罪宝」魔陷作为盖放对象
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为将墓地的卡片移动出墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 将墓地「罪宝」盖放在场上以及为其注册本回合无法发动效果的执行
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中关联的作为对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 若该卡在墓地依然有效且成功被盖放到场上，则继续处理
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.SSet(tp,tc)~=0 then
		-- 注册在该回合内禁止这表盖放的魔法或陷阱卡被主动发动的单体限制效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
