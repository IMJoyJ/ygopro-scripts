--クロノダイバー・パーペチュア
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的准备阶段把这张卡1个超量素材取除，以「时间潜行者·恒动上链员」以外的自己墓地1只「时间潜行者」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：以这张卡以外的自己场上1只超量怪兽为对象才能发动。从卡组选1张「时间潜行者」卡在作为对象的怪兽下面重叠作为超量素材。这个效果在对方回合也能发动。
function c59208943.initial_effect(c)
	-- 设置超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：自己·对方的准备阶段把这张卡1个超量素材取除，以「时间潜行者·恒动上链员」以外的自己墓地1只「时间潜行者」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59208943,0))  --"从墓地特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,59208943)
	e1:SetCost(c59208943.spcost)
	e1:SetTarget(c59208943.sptg)
	e1:SetOperation(c59208943.spop)
	c:RegisterEffect(e1)
	-- ②：以这张卡以外的自己场上1只超量怪兽为对象才能发动。从卡组选1张「时间潜行者」卡在作为对象的怪兽下面重叠作为超量素材。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59208943,1))  --"补充超量素材"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,59208944)
	e2:SetTarget(c59208943.mattg)
	e2:SetOperation(c59208943.matop)
	c:RegisterEffect(e2)
end
-- 效果①的COST：检查并取除这张卡的1个超量素材
function c59208943.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：自己墓地「时间潜行者·恒动上链员」以外的「时间潜行者」怪兽，且能特殊召唤
function c59208943.spfilter(c,e,tp)
	return c:IsSetCard(0x126) and not c:IsCode(59208943) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：进行对象合法性检查并选择对象
function c59208943.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c59208943.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的「时间潜行者」怪兽
		and Duel.IsExistingTarget(c59208943.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「时间潜行者」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c59208943.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，数量为1，目标为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：特殊召唤目标怪兽
function c59208943.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的特殊召唤对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：场上表侧表示的超量怪兽
function c59208943.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 过滤条件：卡组中的「时间潜行者」卡，且能作为超量素材
function c59208943.matfilter(c)
	return c:IsSetCard(0x126) and c:IsCanOverlay()
end
-- 效果②的发动准备：进行对象合法性检查并选择对象
function c59208943.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c59208943.tgfilter(chkc) and chkc~=c end
	-- 检查自己场上是否存在除这张卡以外的表侧表示超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c59208943.tgfilter,tp,LOCATION_MZONE,0,1,c)
		-- 检查自己卡组中是否存在可以作为超量素材的「时间潜行者」卡
		and Duel.IsExistingMatchingCard(c59208943.matfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择效果的对象（超量怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只除这张卡以外的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c59208943.tgfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 效果②的效果处理：从卡组选卡重叠作为超量素材
function c59208943.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的超量怪兽对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从卡组选择1张满足条件的「时间潜行者」卡
		local g=Duel.SelectMatchingCard(tp,c59208943.matfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡重叠在作为对象的超量怪兽下面作为超量素材
			Duel.Overlay(tc,g)
		end
	end
end
