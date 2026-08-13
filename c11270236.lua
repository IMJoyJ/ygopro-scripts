--召喚獣エリュシオン
-- 效果：
-- 「召唤兽」怪兽＋从额外卡组特殊召唤的怪兽
-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」「地」「水」「炎」「风」使用。
-- ②：1回合1次，以自己的场上·墓地1只「召唤兽」怪兽为对象才能发动。那只怪兽以及持有和那只怪兽相同属性的对方场上的怪兽全部除外。这个效果在对方回合也能发动。
function c11270236.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：融合素材为1只「召唤兽」怪兽和1只从额外卡组特殊召唤且在怪兽区域的怪兽，对应融合素材条件。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0xf4),c11270236.ffilter2,false)
	-- 这张卡用以上记的卡为融合素材的融合召唤才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c11270236.splimit)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」「地」「水」「炎」「风」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(0x2f)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己的场上·墓地1只「召唤兽」怪兽为对象才能发动。那只怪兽以及持有和那只怪兽相同属性的对方场上的怪兽全部除外。这个效果在对方回合也能发动。
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
-- 融合素材筛选函数：判断该怪兽是否从额外卡组特殊召唤且位于怪兽区域，用于满足融合素材『从额外卡组特殊召唤的怪兽』。
function c11270236.ffilter2(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE)
end
-- 特殊召唤条件判定：当此卡在额外卡组时，只允许通过融合召唤出场；不在额外卡组时不受此限制。
function c11270236.splimit(e,se,sp,st)
	-- 若此卡位于额外卡组，则要求本次特殊召唤的召唤类型必须为融合召唤，否则不能进行特殊召唤。
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
-- 对象选择过滤器：选择自己场上·墓地表侧表示且可以除外的「召唤兽」怪兽作为对象。
function c11270236.rmfilter1(c)
	return c:IsSetCard(0xf4) and c:IsType(TYPE_MONSTER) and c:IsFaceupEx() and c:IsAbleToRemove()
end
-- 对方怪兽过滤器：选择对方场上表侧表示、属性与所选「召唤兽」怪兽相同且可以除外的怪兽。
function c11270236.rmfilter2(c,att)
	return c:IsFaceup() and c:IsAttribute(att) and c:IsAbleToRemove()
end
-- 效果发动时的目标选择与信息设定：选择1只自己场上·墓地的「召唤兽」怪兽，并将对方场上与其属性相同的表侧表示怪兽加入除外组，同时准备相应除外操作信息。
function c11270236.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c11270236.rmfilter1(chkc) end
	-- 检查自己场上·墓地是否存在至少1只可作为对象的「召唤兽」怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c11270236.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 给出“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己场上·墓地选择1只「召唤兽」怪兽作为这张卡的效果对象。
	local g1=Duel.SelectTarget(tp,c11270236.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 获取对方场上与所选「召唤兽」怪兽当前属性相同的全部表侧表示怪兽，作为后续除外的候选。
	local g2=Duel.GetMatchingGroup(c11270236.rmfilter2,tp,0,LOCATION_MZONE,nil,g1:GetFirst():GetAttribute())
	local gr=false
	if g1:GetFirst():IsLocation(LOCATION_GRAVE) then gr=true end
	g1:Merge(g2)
	if gr then
		-- 设置操作信息：当对象怪兽位于墓地时，标记除外组为对象及相同属性怪兽，持有者为自己，位置为墓地，便于相关连锁判定。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),tp,LOCATION_GRAVE)
	else
		-- 设置操作信息：当对象怪兽位于场上时，标记除外组为对象及相同属性怪兽，目标玩家和位置暂不确定（填0）。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
	end
end
-- 效果处理：若对象怪兽仍与效果关联，则将其以及对方场上与其当前属性相同的表侧表示怪兽全部除外；若对象已变成里侧，则只除外对象自身。
function c11270236.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local tg=Group.FromCards(tc)
		if tc:IsFaceup() then
			-- 效果处理时重新获取对方场上与对象怪兽当前属性相同的表侧表示怪兽，并入待除外的组。
			local g=Duel.GetMatchingGroup(c11270236.rmfilter2,tp,0,LOCATION_MZONE,nil,tc:GetAttribute())
			tg:Merge(g)
		end
		-- 将选定的怪兽全部以表侧表示形式除外。
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
