--究極宝玉陣
-- 效果：
-- ①：自己的「宝玉兽」怪兽被战斗破坏时，从手卡·卡组以及自己场上的表侧表示的卡之中把「宝玉兽」卡7种类各1张送去墓地才能发动。把1只「究极宝玉神」融合怪兽当作融合召唤从额外卡组特殊召唤。
-- ②：自己场上的表侧表示的「究极宝玉神」怪兽因对方的效果从场上离开的场合，把墓地的这张卡除外才能发动。选自己墓地的「宝玉兽」怪兽任意数量当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c36328300.initial_effect(c)
	-- 效果原文内容：①：自己的「宝玉兽」怪兽被战斗破坏时，从手卡·卡组以及自己场上的表侧表示的卡之中把「宝玉兽」卡7种类各1张送去墓地才能发动。把1只「究极宝玉神」融合怪兽当作融合召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c36328300.condition)
	e1:SetCost(c36328300.cost)
	e1:SetTarget(c36328300.target)
	e1:SetOperation(c36328300.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：自己场上的表侧表示的「究极宝玉神」怪兽因对方的效果从场上离开的场合，把墓地的这张卡除外才能发动。选自己墓地的「宝玉兽」怪兽任意数量当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c36328300.plcon)
	-- 将这张卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36328300.pltg)
	e2:SetOperation(c36328300.plop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为「宝玉兽」且为己方控制
function c36328300.confilter(c,tp)
	return c:IsPreviousSetCard(0x1034) and c:IsPreviousControler(tp)
end
-- 效果作用：判断是否有己方「宝玉兽」怪兽被战斗破坏
function c36328300.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36328300.confilter,1,nil,tp)
end
-- 过滤函数：判断卡是否为「宝玉兽」且可以送去墓地
function c36328300.cfilter(c)
	return c:IsSetCard(0x1034) and (c:IsFaceup() or not c:IsOnField()) and c:IsAbleToGraveAsCost()
end
-- 过滤函数：判断是否有足够的额外卡组召唤空间
function c36328300.exfilter(c,tp)
	-- 判断是否有足够的额外卡组召唤空间
	return Duel.GetLocationCountFromEx(tp,tp,c,TYPE_FUSION)>0
end
-- 过滤函数：判断卡片组是否满足额外召唤空间要求
function c36328300.gselect(g,tp)
	-- 判断卡片组是否满足额外召唤空间要求
	return Duel.GetLocationCountFromEx(tp,tp,g,TYPE_FUSION)>0
end
-- 效果作用：判断是否满足发动条件，包括是否有7种不同「宝玉兽」卡且有额外召唤空间
function c36328300.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的「宝玉兽」卡组
	local g=Duel.GetMatchingGroup(c36328300.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=7
		-- 判断是否有额外召唤空间或满足条件的卡组
		and (Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)>0 or g:IsExists(c36328300.exfilter,1,nil,tp)) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 设置额外检查函数为卡名各不相同检查
	aux.GCheckAdditional=aux.dncheck
	local rg=g:SelectSubGroup(tp,c36328300.gselect,false,7,7,tp)
	-- 取消额外检查函数
	aux.GCheckAdditional=nil
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(rg,REASON_COST)
end
-- 过滤函数：判断是否为「究极宝玉神」融合怪兽且可特殊召唤
function c36328300.filter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x2034) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
end
-- 效果作用：判断是否满足特殊召唤条件
function c36328300.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足融合素材要求
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 判断额外卡组是否存在满足条件的融合怪兽
		and Duel.IsExistingMatchingCard(c36328300.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果作用：执行特殊召唤操作
function c36328300.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤条件
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)<=0 or not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,c36328300.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将融合怪兽特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 过滤函数：判断怪兽是否为「究极宝玉神」且因对方效果从场上离开
function c36328300.plcfilter(c,tp)
	return c:IsPreviousSetCard(0x2034) and c:IsPreviousControler(tp)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果作用：判断是否有己方「究极宝玉神」怪兽因对方效果离开场
function c36328300.plcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36328300.plcfilter,1,nil,tp)
end
-- 过滤函数：判断是否为「宝玉兽」怪兽且未被禁止
function c36328300.plfilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 效果作用：判断是否满足发动条件，包括是否有「宝玉兽」怪兽且有魔法陷阱区域空间
function c36328300.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有魔法陷阱区域空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断墓地是否存在满足条件的「宝玉兽」怪兽
		and Duel.IsExistingMatchingCard(c36328300.plfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将墓地的卡放置到魔法陷阱区域
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- 效果作用：执行将墓地的「宝玉兽」怪兽当作永续魔法卡放置
function c36328300.plop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家魔法陷阱区域的可用空间数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的「宝玉兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c36328300.plfilter,tp,LOCATION_GRAVE,0,1,ft,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			-- 将卡移动到魔法陷阱区域
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 将卡转换为永续魔法卡类型
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
