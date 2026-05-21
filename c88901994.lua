--シンクロ・ランブル
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只调整或者1只7·8星的龙族同调怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的「红龙」或者7·8星的龙族同调怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
local s,id,o=GetID()
-- 初始化卡片效果，注册①效果（魔法卡发动、特召墓地怪兽并施加额外卡组特召限制）和②效果（墓地代破）。
function s.initial_effect(c)
	-- 将「红龙」（卡号63436931）记录到这张卡关联的卡名列表中。
	aux.AddCodeList(c,63436931)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只调整或者1只7·8星的龙族同调怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「红龙」或者7·8星的龙族同调怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	-- 设置代替破坏效果的适用对象过滤函数，用于筛选场上被破坏的「红龙」或7·8星龙族同调怪兽。
	e2:SetValue(aux.TargetBoolFunction(s.cfilter,e2))
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己墓地中可以守备表示特殊召唤的调整怪兽，或者7·8星的龙族同调怪兽。
function s.filter(c,e,tp)
	return (c:IsType(TYPE_TUNER) or c:IsLevel(7,8) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动准备与合法性检测：检查墓地是否存在符合条件的怪兽，以及自己场上是否有空余的怪兽区域。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查当前发动效果的玩家场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可以作为效果对象的、满足特召条件的怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，表明此效果包含将选中的1张卡特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理：将作为对象的怪兽守备表示特殊召唤，并注册“直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤”的限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤到发动效果玩家的场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。②：自己场上的「红龙」或者7·8星的龙族同调怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将额外卡组特召限制效果注册给发动效果的玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件函数：限制不能从额外卡组特殊召唤同调怪兽以外的怪兽。
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end
-- 过滤函数：筛选自己场上因战斗或效果被破坏的表侧表示「红龙」或7·8星龙族同调怪兽。
function s.cfilter(c,e)
	local tp=e:GetHandlerPlayer()
	return c:IsFaceup() and (c:IsCode(63436931) or c:IsLevel(7,8) and c:IsRace(RACE_DRAGON)
		and c:IsType(TYPE_SYNCHRO)) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏效果的目标检测：检查墓地的这张卡是否可以除外，以及场上是否有符合条件的怪兽即将被破坏，并询问玩家是否发动代替效果。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.cfilter,1,nil,e) end
	-- 询问玩家是否要发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的处理：将墓地的这张卡除外，以代替怪兽的破坏。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将作为源卡的这张卡（墓地中的此卡）因效果代替而表侧表示除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
