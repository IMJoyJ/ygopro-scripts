--トークバック・ランサー
-- 效果：
-- 2星以下的电子界族怪兽1只
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡以外的自己场上1只电子界族怪兽解放，以原本卡名和那只怪兽不同的自己墓地1只「码语者」怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
function c96380700.initial_effect(c)
	-- 为这张卡添加连接召唤手续
	aux.AddLinkProcedure(c,c96380700.matfilter,1,1)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合只能使用1次。①：把这张卡以外的自己场上1只电子界族怪兽解放，以原本卡名和那只怪兽不同的自己墓地1只「码语者」怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96380700,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,96380700)
	e1:SetCost(c96380700.spcost)
	e1:SetTarget(c96380700.sptg)
	e1:SetOperation(c96380700.spop)
	c:RegisterEffect(e1)
end
-- 连接素材过滤：2星以下的电子界族怪兽
function c96380700.matfilter(c)
	return c:IsLevelBelow(2) and c:IsLinkRace(RACE_CYBERSE)
end
-- 解放怪兽的过滤条件：电子界族怪兽，且解放后能腾出此卡连接区的空位，并存在可选择的墓地「码语者」怪兽
function c96380700.cfilter(c,e,tp,zone)
	-- 过滤条件：电子界族怪兽，且该怪兽解放后此卡所连接区有可用的怪兽区域
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_MONSTER) and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD,zone)>0
		-- 检查墓地是否存在原本卡名与解放怪兽不同、且可以特殊召唤的「码语者」怪兽
		and Duel.IsExistingTarget(c96380700.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 效果发动代价处理：解放自己场上1只除自身以外的电子界族怪兽，并记录该怪兽的信息
function c96380700.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)
	-- 在发动阶段检查自己场上是否存在可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c96380700.cfilter,1,c,e,tp,zone) end
	-- 选择自己场上1只满足条件的怪兽解放
	local g=Duel.SelectReleaseGroup(tp,c96380700.cfilter,1,1,c,e,tp,zone)
	-- 解放选择的怪兽
	Duel.Release(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 特殊召唤对象的过滤：原本卡名与解放怪兽不同的「码语者」怪兽，且可以特殊召唤
function c96380700.spfilter(c,e,tp,rc)
	return c:IsSetCard(0x101) and c:IsType(TYPE_MONSTER) and not c:IsOriginalCodeRule(rc:GetOriginalCodeRule())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标处理：选择墓地1只原本卡名与解放怪兽不同的「码语者」怪兽作为对象
function c96380700.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cc=e:GetLabelObject()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and c96380700.spfilter(chkc,e,tp,cc) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只满足条件的「码语者」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c96380700.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,cc)
	-- 设置效果处理信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果运行处理：在作为此卡所连接区的自己场上特殊召唤目标怪兽
function c96380700.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and zone&0x1f~=0 then
		-- 将目标怪兽在此卡所连接区的自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
