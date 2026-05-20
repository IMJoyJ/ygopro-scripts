--No－P.U.N.K.ディア・ノート
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只其他的「朋克」怪兽给对方观看才能发动。手卡的这张卡和给人观看的怪兽之内1只特殊召唤，另1只送去墓地。
-- ②：这张卡从场上送去墓地的场合，以5星怪兽以外的自己墓地1只「朋克」怪兽为对象才能发动。那只怪兽特殊召唤。这个回合，自己不能把「能朋克 鹿角仙符」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册手卡起动效果①和送墓诱发效果②
function c6609736.initial_effect(c)
	-- ①：把手卡1只其他的「朋克」怪兽给对方观看才能发动。手卡的这张卡和给人观看的怪兽之内1只特殊召唤，另1只送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6609736,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,6609736)
	e1:SetCost(c6609736.tgcost)
	e1:SetTarget(c6609736.tgtg)
	e1:SetOperation(c6609736.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合，以5星怪兽以外的自己墓地1只「朋克」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6609736,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,6609736+o)
	e2:SetCondition(c6609736.spcon)
	e2:SetTarget(c6609736.sptg)
	e2:SetOperation(c6609736.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中除自身以外的「朋克」怪兽，且该怪兽与自身之中至少有1只可以特殊召唤、另1只可以送去墓地
function c6609736.costfilter(c,ec,e,tp)
	if not c:IsSetCard(0x171) or not c:IsType(TYPE_MONSTER) or c:IsPublic() then return false end
	local g=Group.FromCards(c,ec)
	return g:IsExists(c6609736.tgspfilter,1,nil,g,e,tp)
end
-- 过滤可以特殊召唤，且传入卡组中存在另一张可以送去墓地的卡的过滤条件
function c6609736.tgspfilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsAbleToGrave,1,c)
end
-- ①效果的发动代价：把手卡1只其他的「朋克」怪兽给对方观看
function c6609736.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡中是否存在满足条件的另一只「朋克」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c6609736.costfilter,tp,LOCATION_HAND,0,1,c,c,e,tp) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手卡中1只其他的「朋克」怪兽
	local sc=Duel.SelectMatchingCard(tp,c6609736.costfilter,tp,LOCATION_HAND,0,1,1,c,c,e,tp):GetFirst()
	-- 给对方玩家确认选择的怪兽
	Duel.ConfirmCards(1-tp,sc)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
	sc:CreateEffectRelation(e)
	e:SetLabelObject(sc)
end
-- ①效果的发动准备：检查怪兽区域空位，并设置送去墓地和特殊召唤的操作信息
function c6609736.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置将手卡1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置从手卡特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的效果处理：将手卡的这张卡和展示的怪兽中的1只特殊召唤，另1只送去墓地
function c6609736.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local g=Group.FromCards(c,sc)
	local fg=g:Filter(Card.IsRelateToEffect,nil,e)
	if fg:GetCount()~=2 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=fg:FilterSelect(tp,c6609736.tgspfilter,1,1,nil,fg,e,tp)
	-- 如果成功特殊召唤了选择的其中1只怪兽
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 将剩下的另1只怪兽送去墓地
		Duel.SendtoGrave(g-sg,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡从场上送去墓地的场合
function c6609736.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤自己墓地中5星以外的「朋克」怪兽
function c6609736.spfilter(c,e,tp)
	return c:IsSetCard(0x171) and not c:IsLevel(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备：选择墓地中1只满足条件的「朋克」怪兽作为对象
function c6609736.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c6609736.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可以特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在5星以外的「朋克」怪兽
		and Duel.IsExistingTarget(c6609736.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只5星以外的「朋克」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c6609736.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤该对象的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的效果处理：将作为对象的怪兽特殊召唤，并适用本回合不能特殊召唤「能朋克 鹿角仙符」的限制
function c6609736.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不能把「能朋克 鹿角仙符」特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c6609736.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内不能特殊召唤「能朋克 鹿角仙符」的玩家限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，指定卡名为「能朋克 鹿角仙符」
function c6609736.splimit(e,c,tp,sumtp,sumpos)
	return c:IsCode(6609736)
end
