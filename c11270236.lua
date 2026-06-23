--召喚獣エリュシオン
-- 效果：
-- 「召唤兽」怪兽＋从额外卡组特殊召唤的怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」「地」「水」「炎」「风」使用。
-- ②：1回合1次，以自己的场上·墓地1只「召唤兽」怪兽为对象才能发动。那只怪兽以及持有和那只怪兽相同属性的对方场上的怪兽全部除外。这个效果在对方回合也能发动。
function c11270236.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，要求融合素材为1只「召唤兽」怪兽和1只从额外卡组特殊召唤的怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xf4),c11270236.ffilter2,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c11270236.splimit)
	c:RegisterEffect(e1)
	-- 只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」「地」「水」「炎」「风」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(0x2f)
	c:RegisterEffect(e2)
	-- 1回合1次，以自己的场上·墓地1只「召唤兽」怪兽为对象才能发动。那只怪兽以及持有和那只怪兽相同属性的对方场上的怪兽全部除外。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11270236,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetTarget(c11270236.rmtg)
	e3:SetOperation(c11270236.rmop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否为从额外卡组特殊召唤到怪兽区域的怪兽
function c11270236.ffilter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE)
end
-- 特殊召唤限制效果的处理函数，用于判断是否可以通过融合召唤方式特殊召唤
function c11270236.splimit(e,se,sp,st)
	-- 如果这张卡不在额外卡组，则允许召唤；否则必须通过融合召唤方式召唤
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 过滤函数，用于判断是否为「召唤兽」怪兽且在场上或墓地正面表示存在且可以除外
function c11270236.rmfilter1(c)
	return c:IsSetCard(0xf4) and c:IsType(TYPE_MONSTER) and c:IsFaceupEx() and c:IsAbleToRemove()
end
-- 过滤函数，用于判断是否为对方场上的怪兽且具有指定属性
function c11270236.rmfilter2(c,att)
	return c:IsFaceup() and c:IsAttribute(att) and c:IsAbleToRemove()
end
-- 效果发动时的处理函数，用于选择目标并设置操作信息
function c11270236.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c11270236.rmfilter1(chkc) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c11270236.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择满足条件的1只「召唤兽」怪兽作为目标
	local g1=Duel.SelectTarget(tp,c11270236.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 获取与目标怪兽属性相同的对方场上的所有怪兽
	local g2=Duel.GetMatchingGroup(c11270236.rmfilter2,tp,0,LOCATION_MZONE,nil,g1:GetFirst():GetAttribute())
	local gr=false
	if g1:GetFirst():IsLocation(LOCATION_GRAVE) then gr=true end
	g1:Merge(g2)
	if gr then
		-- 设置操作信息，表示将从墓地除外的卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),tp,LOCATION_GRAVE)
	else
		-- 设置操作信息，表示将从场上除外的卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
	end
end
-- 效果发动时的处理函数，用于执行除外效果
function c11270236.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local tg=Group.FromCards(tc)
		if tc:IsFaceup() then
			-- 获取与目标怪兽属性相同的对方场上的所有怪兽
			local g=Duel.GetMatchingGroup(c11270236.rmfilter2,tp,0,LOCATION_MZONE,nil,tc:GetAttribute())
			tg:Merge(g)
		end
		-- 将目标怪兽及其相同属性的对方怪兽全部除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
