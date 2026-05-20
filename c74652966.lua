--コード・オブ・ソウル
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有连接怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。这个回合，自己要把「转生炎兽」连接怪兽连接召唤的场合1次，可以只用自己场上1只同名「转生炎兽」连接怪兽为素材作连接召唤。
-- ③：对方主要阶段，把墓地的这张卡除外才能发动。进行1只连接3以上的电子界族连接怪兽的连接召唤。
function c74652966.initial_effect(c)
	-- ①：自己场上有连接怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74652966,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,74652966)
	e1:SetCondition(c74652966.spcon)
	e1:SetTarget(c74652966.sptg)
	e1:SetOperation(c74652966.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。这个回合，自己要把「转生炎兽」连接怪兽连接召唤的场合1次，可以只用自己场上1只同名「转生炎兽」连接怪兽为素材作连接召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(74652966,1))  --"赋予转生连接"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,44201739+1)
	e2:SetOperation(c74652966.efop)
	c:RegisterEffect(e2)
	-- ③：对方主要阶段，把墓地的这张卡除外才能发动。进行1只连接3以上的电子界族连接怪兽的连接召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74652966,2))  --"加速连接"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,44201739+2)
	e3:SetCondition(c74652966.lkcon)
	-- 设置发动代价为把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c74652966.lktg)
	e3:SetOperation(c74652966.lkop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的连接怪兽
function c74652966.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 效果①的发动条件：自己场上有连接怪兽存在
function c74652966.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的连接怪兽
	return Duel.IsExistingMatchingCard(c74652966.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备与合法性检查
function c74652966.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有空位，且这张卡是否可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息为特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将这张卡特殊召唤
function c74652966.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的效果处理：为额外卡组的「转生炎兽」连接怪兽赋予特殊的连接召唤规则
function c74652966.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 可以只用自己场上1只同名「转生炎兽」连接怪兽为素材作连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74652966,3))  --"用「炽魂代码人」的效果连接召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,44201739+200)
	e1:SetCondition(c74652966.linkcon)
	e1:SetOperation(c74652966.linkop)
	e1:SetValue(SUMMON_TYPE_LINK)
	-- 这个回合，自己要把「转生炎兽」连接怪兽连接召唤的场合1次
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetTargetRange(LOCATION_EXTRA,0)
	e2:SetTarget(c74652966.mattg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetLabelObject(e1)
	-- 将赋予效果注册给玩家，使其在这个回合内适用
	Duel.RegisterEffect(e2,tp)
end
-- 过滤条件：用于特殊连接召唤的、与目标怪兽同名的表侧表示连接怪兽素材
function c74652966.lmfilter(c,lc,tp,og,lmat)
	return c:IsFaceup() and c:IsCanBeLinkMaterial(lc) and c:IsLinkCode(lc:GetCode()) and c:IsLinkType(TYPE_LINK)
		-- 检查将该素材送去墓地后是否有足够的额外怪兽区域空位，并进行必须作为连接素材的限制检查
		and Duel.GetLocationCountFromEx(tp,tp,c,lc)>0 and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_LMATERIAL)
		and (not og or og:IsContains(c)) and (not lmat or lmat==c)
end
-- 特殊连接召唤规则的允许条件：场上存在合法的同名连接素材
function c74652966.linkcon(e,c,og,lmat,min,max)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在满足特殊连接召唤素材条件的怪兽
	return Duel.IsExistingMatchingCard(c74652966.lmfilter,tp,LOCATION_MZONE,0,1,nil,c,tp,og,lmat)
end
-- 特殊连接召唤规则的操作：选择素材并送去墓地
function c74652966.linkop(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
	-- 选择1只满足特殊连接召唤素材条件的怪兽
	local mg=Duel.SelectMatchingCard(tp,c74652966.lmfilter,tp,LOCATION_MZONE,0,1,1,nil,c,tp,og,lmat)
	c:SetMaterial(mg)
	-- 将选择的怪兽作为连接素材送去墓地
	Duel.SendtoGrave(mg,REASON_MATERIAL+REASON_LINK)
end
-- 过滤条件：额外卡组的「转生炎兽」连接怪兽
function c74652966.mattg(e,c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_LINK)
end
-- 效果③的发动条件：对方主要阶段
function c74652966.lkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()==1-tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 过滤条件：可以进行连接召唤的、连接3以上的电子界族连接怪兽
function c74652966.lkfilter(c)
	return c:IsLinkSummonable(nil) and c:IsRace(RACE_CYBERSE) and c:IsLinkAbove(3)
end
-- 效果③的发动准备与合法性检查
function c74652966.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以进行连接召唤的连接3以上电子界族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74652966.lkfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁中的操作信息为特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果③的效果处理：进行连接召唤
function c74652966.lkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的连接怪兽
	local g=Duel.SelectMatchingCard(tp,c74652966.lkfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽进行连接召唤
		Duel.LinkSummon(tp,tc,nil)
	end
end
