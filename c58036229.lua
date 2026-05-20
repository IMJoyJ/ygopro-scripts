--プロテクトコード・トーカー
-- 效果：
-- 效果怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的连接4以上的连接怪兽不会成为对方的效果的对象，不会被战斗破坏。
-- ②：自己场上有「防火」连接怪兽存在的场合，连接标记合计直到3为止从自己墓地把连接怪兽任意数量除外才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果在对方回合也能发动。
function c58036229.initial_effect(c)
	-- 添加连接召唤手续，需要2只以上的效果怪兽作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：自己场上的连接4以上的连接怪兽不会成为对方的效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c58036229.imetg)
	-- 设置不受对方效果对象影响的过滤函数
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ①：自己场上的连接4以上的连接怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c58036229.imetg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：自己场上有「防火」连接怪兽存在的场合，连接标记合计直到3为止从自己墓地把连接怪兽任意数量除外才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58036229,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1,58036229)
	e3:SetCondition(c58036229.spcon)
	e3:SetCost(c58036229.spcost)
	e3:SetTarget(c58036229.sptg)
	e3:SetOperation(c58036229.spop)
	c:RegisterEffect(e3)
end
-- 过滤自身场上连接4以上的连接怪兽
function c58036229.imetg(e,c)
	return c:IsType(TYPE_LINK) and c:IsLinkAbove(4)
end
-- 过滤「防火」连接怪兽
function c58036229.filter(c)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x18f)
end
-- 效果②的发动条件：检查自己场上是否存在「防火」连接怪兽
function c58036229.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张「防火」连接怪兽
	return Duel.IsExistingMatchingCard(c58036229.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤自己墓地中连接标记在3以下且可以作为代价除外的连接怪兽
function c58036229.rmfilter(c)
	return c:IsType(TYPE_LINK) and c:IsLinkBelow(3) and c:IsAbleToRemoveAsCost()
end
-- 检查选中的怪兽组的连接标记合计是否刚好等于3
function c58036229.fselect(g)
	return g:GetSum(Card.GetLink)==3
end
-- 效果②的发动代价处理：从墓地将连接标记合计为3的任意数量连接怪兽除外
function c58036229.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己墓地中满足除外代价条件的连接怪兽卡组
	local g=Duel.GetMatchingGroup(c58036229.rmfilter,tp,LOCATION_GRAVE,0,c)
	if chk==0 then return g:CheckSubGroup(c58036229.fselect,1,#g) end
	-- 发送系统提示，要求玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c58036229.fselect,false,1,#g)
	-- 将选中的怪兽作为发动代价表侧表示除外
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备与目标确认：检查怪兽区域空位并确认自身是否能特殊召唤，设置特殊召唤的操作信息
function c58036229.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域，且此卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果②的效果处理：将此卡从墓地特殊召唤，并添加离场时除外的永续效果
function c58036229.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与效果关联，并尝试将其以表侧表示特殊召唤到场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
