--幻影騎士団ステンドグリーブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「幻影骑士团」怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。那之后，可以让这张卡的等级上升1星。
-- ②：把墓地的这张卡除外才能发动。从手卡把「幻影骑士团 污痕胫甲」以外的1只「幻影骑士团」怪兽特殊召唤。那之后，可以让那只怪兽的等级上升1星。
function c88544390.initial_effect(c)
	-- ①：自己场上有「幻影骑士团」怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。那之后，可以让这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88544390,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,88544390)
	e1:SetCondition(c88544390.spcon)
	e1:SetTarget(c88544390.sptg)
	e1:SetOperation(c88544390.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把「幻影骑士团 污痕胫甲」以外的1只「幻影骑士团」怪兽特殊召唤。那之后，可以让那只怪兽的等级上升1星。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(88544390,1))  --"自身是否上升等级？"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,88544391)
	-- 把墓地的这张卡除外作为发动成本（Cost）
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c88544390.sptarget)
	e2:SetOperation(c88544390.spoperation)
	c:RegisterEffect(e2)
end
-- 过滤条件：由自己控制的、表侧表示的「幻影骑士团」怪兽
function c88544390.spfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x10db) and c:IsFaceup()
end
-- 检查特殊召唤成功的怪兽中是否存在满足过滤条件的怪兽
function c88544390.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c88544390.spfilter,1,nil,tp)
end
-- 效果1的发动准备（Target）：检查自身是否能特殊召唤以及怪兽区域是否有空位
function c88544390.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果1的效果处理（Operation）：将自身特殊召唤，并由玩家选择是否让其等级上升1星
function c88544390.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于手卡且特殊召唤成功，则询问玩家是否让其等级上升1星
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.SelectYesNo(tp,aux.Stringid(88544390,2)) then  --"是否上升等级？"
		-- 中断当前效果处理，使后续的等级上升处理不与特殊召唤同时进行（防止错时点）
		Duel.BreakEffect()
		-- 可以让这张卡的等级上升1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件：手卡中除「幻影骑士团 污痕胫甲」以外的、可以特殊召唤的「幻影骑士团」怪兽
function c88544390.filter(c,e,tp)
	return c:IsSetCard(0x10db) and not c:IsCode(88544390) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动准备（Target）：检查怪兽区域空位以及手卡中是否存在满足条件的怪兽
function c88544390.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c88544390.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置从手卡特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果2的效果处理（Operation）：从手卡特殊召唤1只满足条件的「幻影骑士团」怪兽，并由玩家选择是否让其等级上升1星
function c88544390.spoperation(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c88544390.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功特殊召唤选中的怪兽，则询问玩家是否让该怪兽的等级上升1星
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.SelectYesNo(tp,aux.Stringid(88544390,2)) then  --"是否上升等级？"
		-- 中断当前效果处理，使后续的等级上升处理不与特殊召唤同时进行（防止错时点）
		Duel.BreakEffect()
		local tc=g:GetFirst()
		-- 可以让那只怪兽的等级上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
