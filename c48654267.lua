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
-- 用于筛选额外卡组中的灵摆怪兽的过滤函数
function c48654267.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsLocation(LOCATION_EXTRA)
end
-- 用于判断所选怪兽组中额外卡组灵摆怪兽数量是否符合限制条件的函数
function c48654267.gcheck(g,tp,eft)
	return g:FilterCount(c48654267.filter,nil)<=eft
end
-- 设置特殊召唤效果的处理函数，从卡组、额外卡组或墓地选择最多2只「霸王眷龙」怪兽守备表示特殊召唤
function c48654267.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取玩家额外卡组可用的召唤区数量
	local eft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	if ft<=0 then return end
	if ft>=2 then ft=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取满足条件的「霸王眷龙」怪兽组
	local g=Duel.GetMatchingGroup(c48654267.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c48654267.gcheck,false,1,ft,tp,eft)
	if sg:GetCount()>0 then
		local exg=sg:Filter(c48654267.filter,nil)
		sg:Sub(exg)
		if exg:GetCount()>0 then
			-- 遍历额外卡组灵摆怪兽组并进行特殊召唤处理
			for tc in aux.Next(exg) do
				-- 将额外卡组灵摆怪兽以守备表示特殊召唤到场上
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
		if sg:GetCount()>0 then
			-- 遍历非额外卡组灵摆怪兽组并进行特殊召唤处理
			for tc in aux.Next(sg) do
				-- 将非额外卡组灵摆怪兽以守备表示特殊召唤到场上
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
		-- 完成所有特殊召唤步骤的处理
		Duel.SpecialSummonComplete()
	end
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
