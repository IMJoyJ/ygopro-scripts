--覇王龍ズァーク－シンクロ・ユニバース
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：把自己场上1只「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽解放才能发动。这张卡特殊召唤。
-- 【怪兽效果】
-- 调整＋调整以外的暗属性灵摆怪兽1只以上
-- ①：这张卡只要在怪兽区域存在，卡名当作「霸王龙 扎克」使用。
-- ②：这张卡战斗破坏对方怪兽的伤害计算后或者给与对方战斗伤害时才能发动。从自己的卡组·额外卡组·墓地把最多2只「霸王眷龙」怪兽守备表示特殊召唤。
-- ③：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c48654267.initial_effect(c)
	-- 记录该卡牌的卡号为13331639，用于后续效果判断
	aux.AddCodeList(c,13331639)
	-- 使该卡在场上时卡号视为13331639（霸王龙 扎克）
	aux.EnableChangeCode(c,13331639,LOCATION_MZONE)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤
	aux.EnablePendulumAttribute(c)
	c:EnableReviveLimit()
	-- 设置该卡的同调召唤条件：需要1只调整和1只调整以外的暗属性灵摆怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(c48654267.matfilter),1)
	-- ①：把自己场上1只「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽解放才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48654267,0))  --"从灵摆区域特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,48654267)
	e1:SetCost(c48654267.pspcost)
	e1:SetTarget(c48654267.psptg)
	e1:SetOperation(c48654267.pspop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽的伤害计算后或者给与对方战斗伤害时才能发动。从自己的卡组·额外卡组·墓地把最多2只「霸王眷龙」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48654267,1))  --"特殊召唤「霸王眷龙」怪兽"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c48654267.spcon1)
	e2:SetTarget(c48654267.sptg)
	e2:SetOperation(c48654267.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c48654267.spcon2)
	c:RegisterEffect(e3)
	-- ③：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48654267,2))  --"在灵摆区域放置"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(c48654267.pencon)
	e4:SetTarget(c48654267.pentg)
	e4:SetOperation(c48654267.penop)
	c:RegisterEffect(e4)
end
-- 同调召唤时用于筛选素材的过滤函数，要求是暗属性灵摆怪兽
function c48654267.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_PENDULUM)
end
-- 灵摆召唤时用于选择解放卡的过滤函数，要求是「霸王眷龙」或「霸王门」灵摆怪兽且有可用怪兽区
function c48654267.cfilter(c,tp)
	-- 判断是否为「霸王眷龙」或「霸王门」灵摆怪兽且有可用怪兽区
	return c:IsSetCard(0x10f8,0x20f8) and c:IsType(TYPE_PENDULUM) and Duel.GetMZoneCount(tp,c)>0
		and (c:IsFaceup() or c:IsControler(tp))
end
-- 检查是否有满足条件的解放卡并选择1张进行解放
function c48654267.pspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的解放卡
	if chk==0 then return Duel.CheckReleaseGroup(tp,c48654267.cfilter,1,nil,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的1张解放卡
	local g=Duel.SelectReleaseGroup(tp,c48654267.cfilter,1,1,nil,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 设置灵摆召唤效果的目标判定函数，判断该卡是否能被特殊召唤
function c48654267.psptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 设置灵摆召唤效果的处理函数，将该卡特殊召唤到场上
function c48654267.pspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 战斗破坏对方怪兽时触发的效果条件判断函数
function c48654267.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and bc~=nil and bc:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 受到对方战斗伤害时触发的效果条件判断函数
function c48654267.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
end
-- 用于筛选可特殊召唤的「霸王眷龙」怪兽的过滤函数，要求在卡组、额外卡组或墓地且有可用怪兽区
function c48654267.spfilter(c,e,tp)
	return c:IsSetCard(0x20f8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 判断该卡是否在卡组或墓地且有可用怪兽区
		and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 判断该卡是否在额外卡组且有可用额外卡组召唤区
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 设置特殊召唤效果的目标判定函数，检查是否有满足条件的「霸王眷龙」怪兽可特殊召唤
function c48654267.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的「霸王眷龙」怪兽可特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(c48654267.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将特殊召唤最多2只「霸王眷龙」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE)
end
function c48654267.exfilter2(c)
	return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
function c48654267.exfilter3(c)
	return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM)))
end
function c48654267.gcheck(g,ft1,ft2,ft3,ect,ft)
	return #g<=ft
		and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_GRAVE)<=ft1
		and g:FilterCount(c48654267.exfilter2,nil)<=ft2
		and g:FilterCount(c48654267.exfilter3,nil)<=ft3
		and g:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect
end
-- 设置特殊召唤效果的处理函数，从卡组、额外卡组或墓地选择最多2只「霸王眷龙」怪兽守备表示特殊召唤
function c48654267.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
	local ft3=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM+TYPE_LINK)
	local ft=Duel.GetUsableMZoneCount(tp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		if ft1>0 then ft1=1 end
		if ft2>0 then ft2=1 end
		if ft3>0 then ft3=1 end
		ft=1
	end
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	local loc=0
	if ft1>0 then loc=loc+LOCATION_DECK+LOCATION_GRAVE end
	if ect>0 and (ft2>0 or ft3>0) then loc=loc+LOCATION_EXTRA end
	if loc==0 then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c48654267.spfilter),tp,loc,0,nil,e,tp)
	if sg:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local rg=sg:SelectSubGroup(tp,c48654267.gcheck,false,1,2,ft1,ft2,ft3,ect,ft)
	Duel.SpecialSummon(rg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断该卡是否在怪兽区被破坏且为表侧表示的条件函数
function c48654267.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置灵摆区域放置效果的目标判定函数，检查是否有可用的灵摆区位置
function c48654267.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可用的灵摆区位置
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 设置灵摆区域放置效果的处理函数，将该卡移动到自己的灵摆区域
function c48654267.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡移动到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
