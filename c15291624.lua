--超雷龍－サンダー・ドラゴン
-- 效果：
-- 「雷龙」＋雷族怪兽
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●雷族怪兽的效果在手卡发动的回合，把融合怪兽以外的自己场上1只雷族效果怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：只要这张卡在怪兽区域存在，对方不能用抽卡以外的方法从卡组把卡加入手卡。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己墓地1只雷族怪兽除外。
function c15291624.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：此卡可以用卡号为31786629的「雷龙」与1只雷族怪兽作为融合素材进行融合召唤。
	aux.AddFusionProcCodeFun(c,31786629,aux.FilterBoolFunction(Card.IsRace,RACE_THUNDER),1,true,true)
	-- 对应效果原文：『这张卡用融合召唤以及以下方法才能特殊召唤。』中关于融合召唤的限制，即此卡只能通过融合召唤这种方式从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果的条件值为aux.fuslimit，表示此卡只能用“融合召唤”这一正规方式来特殊召唤，不能通过其他特殊召唤手段出场。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- 对应效果原文：『●雷族怪兽的效果在手卡发动的回合，把融合怪兽以外的自己场上1只雷族效果怪兽解放的场合可以从额外卡组特殊召唤。』，此处实现该特殊召唤手续的场合判断、对象选择与解放处理。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c15291624.spcon)
	e2:SetTarget(c15291624.sptg)
	e2:SetOperation(c15291624.spop)
	c:RegisterEffect(e2)
	-- 对应效果原文：『①：只要这张卡在怪兽区域存在，对方不能用抽卡以外的方法从卡组把卡加入手卡。』
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TO_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	-- 设置该永续效果影响的目标为位于卡组的卡片，从而封锁对方通过抽卡以外手段将卡组的卡加入手卡的行为。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e3)
	-- 对应效果原文：『②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把自己墓地1只雷族怪兽除外。』
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetTarget(c15291624.reptg)
	c:RegisterEffect(e4)
	-- 注册一个自定义活动计数器，用来记录本回合是否出现过“雷族怪兽的效果在手卡发动”的情况，为该怪兽的特殊召唤手续提供判定依据。
	Duel.AddCustomActivityCounter(15291624,ACTIVITY_CHAIN,c15291624.chainfilter)
end
-- 计数器过滤函数：当当前连锁的效果是雷族怪兽效果且其发动位置在手卡时返回 false（使计数器增加），从而记录一次符合条件的手卡雷族效果发动；其他发动不计入。
function c15291624.chainfilter(re,tp,cid)
	return not (re:GetHandler():IsRace(RACE_THUNDER) and re:IsActiveType(TYPE_MONSTER)
		-- 判断该连锁效果发动时的位置是否为手卡，确保只有“在手卡发动的雷族怪兽效果”才会计入特殊召唤手续的发动条件。
		and Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)==LOCATION_HAND)
end
-- 解放素材过滤函数：筛选自己场上的雷族效果怪兽，要求它不是融合怪兽，且解放后能腾出空位让此卡从额外卡组特殊召唤，并且可以当作融合素材使用。
function c15291624.spfilter(c,fc,tp)
	return c:IsRace(RACE_THUNDER) and c:IsFusionType(TYPE_EFFECT) and not c:IsFusionType(TYPE_FUSION)
		-- 检查解放该怪兽后，从额外卡组特殊召唤此卡是否还有可用怪兽区域，以及该卡是否可作为此卡的融合素材，以保证这次特殊召唤手续合法。
		and Duel.GetLocationCountFromEx(tp,tp,c,fc)>0 and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL)
end
-- 特殊召唤手续的发动条件：本回合内任意一方发动过雷族怪兽的手卡效果，并且自己场上存在满足解放条件的雷族效果怪兽时，才能进行这次特殊召唤。
function c15291624.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 通过查询自定义计数器，确认本回合是否已有雷族怪兽效果在手卡发动（自己或对方发动均可）。
	return (Duel.GetCustomActivityCount(15291624,tp,ACTIVITY_CHAIN)~=0 or Duel.GetCustomActivityCount(15291624,1-tp,ACTIVITY_CHAIN)~=0)
		-- 检查自己场上是否存在至少1只符合条件的雷族效果怪兽可供解放，且解放后能够进行此特殊召唤。
		and Duel.CheckReleaseGroupEx(tp,c15291624.spfilter,1,REASON_SPSUMMON,false,nil,c,tp)
end
-- 特殊召唤手续的目标选择：从可解放的怪兽中选择1只作为解放对象，并将其保存到效果标签中，供后续特殊召唤处理时使用。
function c15291624.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家场上可供解放的怪兽组，并用spfilter过滤出所有满足雷族、效果、非融合等条件的候选怪兽。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c15291624.spfilter,nil,c,tp)
	-- 向玩家显示“请选择要解放的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的操作：将之前选择保存的怪兽作为融合素材记录到该卡，并执行解放，从而完成从额外卡组的特殊召唤。
function c15291624.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 将选择的怪兽解放，作为这次特殊召唤手续的代价（解放原因标记为特殊召唤）。
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 代替破坏除外对象的过滤条件：选择自己墓地中1只雷族怪兽，且该怪兽可以被除外。
function c15291624.repfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemove()
end
-- 代替破坏效果的触发条件：这张卡将要因战斗或效果被破坏，且不是作为代替破坏处理，同时墓地有符合条件的雷族怪兽时，可以发动代替破坏。
function c15291624.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查墓地是否存在至少1只符合条件的雷族怪兽，用于决定是否可以作为代替破坏的除外对象。
		and Duel.IsExistingMatchingCard(c15291624.repfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 如果这张卡将要被破坏，则询问玩家是否发动代替破坏效果，即是否用墓地雷族怪兽代替这张卡被破坏。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 向玩家显示“请选择要代替破坏的卡”的选择提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从自己墓地选择1只符合条件的雷族怪兽，作为代替这张卡破坏的除外对象。
		local g=Duel.SelectMatchingCard(tp,c15291624.repfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选中的墓地雷族怪兽表侧除外，以代替这张卡的破坏，防止这张卡因战斗/效果被破坏而送墓。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
