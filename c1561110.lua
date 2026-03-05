--ABC－ドラゴン・バスター
-- 效果：
-- 「A-突击核」＋「B-破坏龙兽」＋「C-粉碎翼龙」
-- 把自己的场上·墓地的上记的卡除外的场合才能从额外卡组特殊召唤。
-- ①：自己·对方回合1次，丢弃1张手卡，以场上1张卡为对象才能发动。那张卡除外。
-- ②：对方回合，把这张卡解放，以自己的除外状态的3只机械族·光属性同盟怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。
function c1561110.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为30012506,77411244,3405259的3只怪兽为融合素材
	aux.AddFusionProcCode3(c,30012506,77411244,3405259,true,true)
	-- 添加接触融合特殊召唤规则，允许将自己场上或墓地的符合条件的卡除外以特殊召唤此卡
	aux.AddContactFusionProcedure(c,Card.IsAbleToRemoveAsCost,LOCATION_ONFIELD+LOCATION_GRAVE,0,Duel.Remove,POS_FACEUP,REASON_COST)
	-- ①：自己·对方回合1次，丢弃1张手卡，以场上1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c1561110.splimit)
	c:RegisterEffect(e1)
	-- ②：对方回合，把这张卡解放，以自己的除外状态的3只机械族·光属性同盟怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1561110,0))  --"丢弃1张手卡，把场上1张卡除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(c1561110.rmcost)
	e3:SetTarget(c1561110.rmtg)
	e3:SetOperation(c1561110.rmop)
	c:RegisterEffect(e3)
	-- 把自己的场上·墓地的上记的卡除外的场合才能从额外卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(1561110,1))  --"把这张卡解放，把除外的同盟怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(c1561110.spcon2)
	e4:SetCost(c1561110.spcost2)
	e4:SetTarget(c1561110.sptg2)
	e4:SetOperation(c1561110.spop2)
	c:RegisterEffect(e4)
end
c1561110.has_text_type=TYPE_UNION
-- 限制此卡不能从额外卡组特殊召唤，除非满足融合条件
function c1561110.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 丢弃1张手卡作为cost
function c1561110.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃1张手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 选择场上1张卡作为除外对象
function c1561110.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检查场上是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1张卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为除外卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外操作
function c1561110.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断是否为对方回合
function c1561110.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 解放此卡作为cost
function c1561110.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 执行解放此卡的操作
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选符合条件的除外状态的机械族·光属性同盟怪兽
function c1561110.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsType(TYPE_UNION) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤条件，检查是否有足够的场地和符合条件的怪兽
function c1561110.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取符合条件的除外状态的机械族·光属性同盟怪兽
	local g=Duel.GetMatchingGroup(c1561110.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if chk==0 then
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ft>2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			and g:GetClassCount(Card.GetCode)>2
	end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择3只符合条件的除外怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 设置操作目标为选中的怪兽
	Duel.SetTargetCard(sg)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,3,0,0)
end
-- 执行特殊召唤操作
function c1561110.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取连锁中设定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()<=ft then
		-- 将目标卡组特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将选中的卡特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 将剩余卡送入墓地
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
