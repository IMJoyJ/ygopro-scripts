--アストラル・クリボー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把额外卡组1只「No.」超量怪兽给对方观看才能发动。这张卡从手卡特殊召唤。这张卡的等级变成和给人观看的怪兽的阶级数值相同。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是「No.」超量怪兽不能从额外卡组特殊召唤。
-- ②：场上的这张卡为素材作超量召唤的「No.」怪兽得到以下效果。
-- ●这张卡不会被战斗以及对方的效果破坏。
function c64591429.initial_effect(c)
	-- ①：把额外卡组1只「No.」超量怪兽给对方观看才能发动。这张卡从手卡特殊召唤。这张卡的等级变成和给人观看的怪兽的阶级数值相同。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是「No.」超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64591429,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,64591429)
	e1:SetCost(c64591429.spcost)
	e1:SetTarget(c64591429.sptg)
	e1:SetOperation(c64591429.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的「No.」怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c64591429.effcon)
	e2:SetOperation(c64591429.effop)
	c:RegisterEffect(e2)
end
-- 过滤额外卡组中未给对方观看的「No.」超量怪兽
function c64591429.cfilter(c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and not c:IsPublic()
end
-- ①号效果的发动代价：展示额外卡组1只「No.」超量怪兽，并记录其阶级
function c64591429.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以给对方观看的「No.」超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c64591429.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择额外卡组的1只「No.」超量怪兽
	local g=Duel.SelectMatchingCard(tp,c64591429.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	-- 将选中的怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetRank())
end
-- ①号效果的发动准备：检查怪兽区域空位以及自身是否能特殊召唤
function c64591429.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的处理：特殊召唤自身，改变等级，并适用额外卡组特殊召唤限制
function c64591429.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local lv=e:GetLabel()
	-- 尝试将自身以表侧表示特殊召唤
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这张卡的等级变成和给人观看的怪兽的阶级数值相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是「No.」超量怪兽不能从额外卡组特殊召唤。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetRange(LOCATION_MZONE)
		e2:SetAbsoluteRange(tp,1,0)
		e2:SetTarget(c64591429.splimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
-- 限制自己只能从额外卡组特殊召唤「No.」超量怪兽
function c64591429.splimit(e,c)
	return not (c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)) and c:IsLocation(LOCATION_EXTRA)
end
-- 检查是否作为「No.」怪兽的超量素材
function c64591429.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ and e:GetHandler():GetReasonCard():IsSetCard(0x48)
end
-- 赋予超量召唤的「No.」怪兽不会被战斗及对方效果破坏的效果，若其不是效果怪兽则追加效果怪兽类型
function c64591429.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡不会被战斗以及对方的效果破坏。
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(64591429,1))  --"「星光栗子球」效果适用中"
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	rc:RegisterEffect(e2,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ②：场上的这张卡为素材作超量召唤的「No.」怪兽得到以下效果。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
end
