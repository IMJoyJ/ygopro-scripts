--ショートヴァレル・ドラゴン
-- 效果：
-- 「弹丸」怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，自己场上有「枪管」连接怪兽存在的场合，把自己场上1只连接3以下的怪兽解放才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡不能作为连接标记数量和解放的怪兽相同的怪兽的连接素材。
function c73341839.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要「弹丸」怪兽2只作为素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x102),2,2)
	-- ①：这张卡在墓地存在，自己场上有「枪管」连接怪兽存在的场合，把自己场上1只连接3以下的怪兽解放才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡不能作为连接标记数量和解放的怪兽相同的怪兽的连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73341839,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,73341839)
	e1:SetCondition(c73341839.spcon)
	e1:SetCost(c73341839.spcost)
	e1:SetTarget(c73341839.sptg)
	e1:SetOperation(c73341839.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「枪管」连接怪兽
function c73341839.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10f) and c:IsType(TYPE_LINK)
end
-- 效果发动条件：自己场上存在「枪管」连接怪兽
function c73341839.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「枪管」连接怪兽
	return Duel.IsExistingMatchingCard(c73341839.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：连接3以下的怪兽，且该怪兽解放后能空出可用的怪兽区域
function c73341839.costfilter(c,tp)
	-- 检查怪兽是否为连接3以下，且解放该怪兽后自己场上有可用于特殊召唤的怪兽区域
	return c:IsLinkBelow(3) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动代价：解放自己场上1只连接3以下的怪兽，并记录其连接标记数量
function c73341839.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动步骤检查是否可以解放1只满足条件的怪兽作为代价
	if chk==0 then return Duel.CheckReleaseGroup(tp,c73341839.costfilter,1,nil,tp) end
	-- 让玩家选择1只满足条件的怪兽解放
	local sg=Duel.SelectReleaseGroup(tp,c73341839.costfilter,1,1,nil,tp)
	e:SetLabel(sg:GetFirst():GetLink())
	-- 解放选中的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 效果发动目标：确认自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c73341839.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，对象为墓地的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡特殊召唤，并添加「不能作为连接标记数量和解放的怪兽相同的怪兽的连接素材」的限制
function c73341839.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与效果相关，则将其在自己场上表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡不能作为连接标记数量和解放的怪兽相同的怪兽的连接素材。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetTarget(c73341839.lklimit)
		e1:SetLabel(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 限制条件：不能作为连接标记数量等于被解放怪兽连接标记数量的怪兽的连接素材
function c73341839.lklimit(e,c)
	if not c then return false end
	local lk=e:GetLabel()
	return c:IsLink(lk)
end
