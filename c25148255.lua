--ジャンク・アンカー
-- 效果：
-- 这张卡可以作为「同调士」调整的代替而成为同调素材。
-- ①：1回合1次，丢弃1张手卡，以调整以外的自己墓地1只「废品」怪兽为对象才能发动。那只怪兽特殊召唤，只用那只怪兽和这张卡为素材，把以「同调士」调整为素材的1只同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地而除外。
function c25148255.initial_effect(c)
	-- ①：1回合1次，丢弃1张手卡，以调整以外的自己墓地1只「废品」怪兽为对象才能发动。那只怪兽特殊召唤，只用那只怪兽和这张卡为素材，把以「同调士」调整为素材的1只同调怪兽同调召唤。那个时候的同调素材怪兽不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25148255,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c25148255.sccost)
	e1:SetTarget(c25148255.sctg)
	e1:SetOperation(c25148255.scop)
	c:RegisterEffect(e1)
	-- 这张卡可以作为「同调士」调整的代替而成为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(20932152)
	c:RegisterEffect(e2)
end
-- 丢弃1张手卡作为cost
function c25148255.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃1张手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST)
end
-- 筛选墓地中的「废品」怪兽，排除调整，且能特殊召唤，且存在满足条件的同调怪兽
function c25148255.mfilter(c,e,tp,mc)
	local mg=Group.FromCards(c,mc)
	return c:IsSetCard(0x43) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在满足同调召唤条件的额外怪兽
		and Duel.IsExistingMatchingCard(c25148255.scfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 检查同调怪兽是否满足同调召唤条件
function c25148255.scfilter(c,mg,tp)
	-- 检查同调怪兽是否满足同调召唤条件
	return aux.IsMaterialListSetCard(c,0x1017) and c:IsSynchroSummonable(nil,mg) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 设置效果目标，选择墓地中的「废品」怪兽
function c25148255.sctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25148255.mfilter(chkc,e,tp,c) end
	-- 检查玩家是否可以进行2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的墓地怪兽作为目标
		and Duel.IsExistingTarget(c25148255.mfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c) end
	-- 提示玩家选择作为同调素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)  --"请选择要作为同调素材的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c25148255.mfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,c)
	-- 设置效果操作信息，准备特殊召唤额外怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果的执行流程
function c25148255.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 将目标怪兽特殊召唤到场上
	if not tc:IsRelateToEffect(e) or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	if not c:IsRelateToEffect(e) then return end
	-- 刷新场上状态
	Duel.AdjustAll()
	local mg=Group.FromCards(c,tc)
	if mg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
	-- 获取满足同调召唤条件的额外怪兽
	local g=Duel.GetMatchingGroup(c25148255.scfilter,tp,LOCATION_EXTRA,0,nil,mg,tp)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将此卡和目标怪兽除外，防止其进入墓地
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
		local e2=e1:Clone()
		tc:RegisterEffect(e2,true)
		-- 执行同调召唤手续
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
