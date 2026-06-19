--おジャマパーティ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。从卡组把1张「扰乱」卡加入手卡，那之后选1张手卡丢弃。
-- ②：自己场上的「武装龙」怪兽或者机械族·光属性的融合怪兽被战斗·效果破坏的场合，可以作为代替把自己的手卡·场上·墓地1张「扰乱」卡除外。
-- ③：这张卡被送去墓地的场合才能发动。除外的自己的「扰乱」怪兽尽可能特殊召唤。
function c75884822.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。从卡组把1张「扰乱」卡加入手卡，那之后选1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c75884822.target)
	c:RegisterEffect(e1)
	-- ①：自己·对方的主要阶段才能发动。从卡组把1张「扰乱」卡加入手卡，那之后选1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75884822,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,75884822)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCondition(c75884822.thcon)
	e2:SetTarget(c75884822.thtg)
	e2:SetOperation(c75884822.thop)
	c:RegisterEffect(e2)
	-- ②：自己场上的「武装龙」怪兽或者机械族·光属性的融合怪兽被战斗·效果破坏的场合，可以作为代替把自己的手卡·场上·墓地1张「扰乱」卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(c75884822.reptg)
	e3:SetValue(c75884822.repval)
	e3:SetOperation(c75884822.repop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合才能发动。除外的自己的「扰乱」怪兽尽可能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(75884822,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,75884823)
	e4:SetTarget(c75884822.sptg)
	e4:SetOperation(c75884822.spop)
	c:RegisterEffect(e4)
end
-- 魔法卡发动时的效果处理，若在主要阶段且满足检索条件，可选择在发动卡片的同时发动①的效果
function c75884822.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if c75884822.thcon(e,tp,eg,ep,ev,re,r,rp)
		and c75884822.thtg(e,tp,eg,ep,ev,re,r,rp,0)
		-- 询问玩家在发动这张卡时是否同时发动其①的效果
		and Duel.SelectYesNo(tp,94) then
		-- 给玩家注册一个本回合已发动过该效果的标记（用于限制一回合一次）
		Duel.RegisterFlagEffect(tp,75884822,RESET_PHASE+PHASE_END,0,0)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES_SELF)
		e:SetOperation(c75884822.thop)
		c75884822.thtg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
-- ①的效果的发动条件函数
function c75884822.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己或对方的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤卡组中「扰乱」卡片且能加入手牌的过滤函数
function c75884822.thfilter(c)
	return c:IsSetCard(0xf) and c:IsAbleToHand()
end
-- ①的效果的靶向（Target）函数，用于检查发动条件并设置操作信息
function c75884822.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家本回合是否尚未发动过该效果
	if chk==0 then return Duel.GetFlagEffect(tp,75884822)==0
		-- 检查卡组中是否存在至少1张可以加入手牌的「扰乱」卡
		and Duel.IsExistingMatchingCard(c75884822.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果包含从卡组将1张卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①的效果的执行（Operation）函数，处理检索并丢弃手牌
function c75884822.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的「扰乱」卡
	local g=Duel.SelectMatchingCard(tp,c75884822.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 如果成功将选中的卡加入手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果处理，使后续的丢弃手牌处理不与检索同时进行（造成错时点）
		Duel.BreakEffect()
		-- 让玩家选择并丢弃1张手牌
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)
	end
end
-- 过滤需要代替破坏的怪兽（自己场上的「武装龙」怪兽或机械族·光属性融合怪兽）
function c75884822.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField()
		and ((c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION)) or c:IsSetCard(0x111))
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 过滤用于代替破坏而除外的「扰乱」卡（手牌、场上或墓地）
function c75884822.desfilter(c,e,tp)
	return c:IsControler(tp) and (c:IsFaceup() or not c:IsOnField()) and c:IsSetCard(0xf)
		and c:IsAbleToRemove() and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED) and not c:IsImmuneToEffect(e)
end
-- 代替破坏效果的靶向（Target）函数，检查是否有怪兽将被破坏以及是否有可除外的代替卡
function c75884822.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c75884822.repfilter,1,nil,tp)
		-- 检查自己的手牌、场上或墓地是否存在至少1张可以除外的「扰乱」卡
		and Duel.IsExistingMatchingCard(c75884822.desfilter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 询问玩家是否使用代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择用于代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家从手牌、场上或墓地选择1张用于代替破坏的「扰乱」卡
		local g=Duel.SelectMatchingCard(tp,c75884822.desfilter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
-- 确定代替破坏效果所适用的对象怪兽
function c75884822.repval(e,c)
	return c75884822.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的执行（Operation）函数，将选中的「扰乱」卡除外
function c75884822.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示该卡，提示正在适用其代替破坏的效果
	Duel.Hint(HINT_CARD,0,75884822)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选中的代替卡以表侧表示除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
-- 过滤除外状态中可以特殊召唤的「扰乱」怪兽
function c75884822.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③的效果的靶向（Target）函数，检查是否有可用的怪兽区域和可特殊召唤的除外怪兽
function c75884822.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少1只可以特殊召唤的「扰乱」怪兽
		and Duel.IsExistingMatchingCard(c75884822.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 获取玩家场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 设置连锁的操作信息，表示该效果包含从除外区特殊召唤怪兽的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,tp,LOCATION_REMOVED)
end
-- ③的效果的执行（Operation）函数，将除外的「扰乱」怪兽尽可能特殊召唤
function c75884822.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取除外区所有满足特殊召唤条件的「扰乱」怪兽
	local tg=Duel.GetMatchingGroup(c75884822.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local g=nil
	if tg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
