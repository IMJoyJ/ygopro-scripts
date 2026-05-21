--覇王眷竜オッドアイズ
-- 效果：
-- ←4 【灵摆】 4→
-- ①：把自己场上1只「霸王眷龙」怪兽解放才能发动。这张卡破坏，从卡组把1只攻击力1500以下的灵摆怪兽加入手卡。
-- 【怪兽效果】
-- ①：把自己场上2只「霸王眷龙」怪兽解放才能发动。这张卡从手卡特殊召唤。
-- ②：自己的灵摆怪兽和对方怪兽进行战斗的场合，给与对方的战斗伤害变成2倍。
-- ③：自己·对方的战斗阶段把这张卡解放才能发动。从自己的额外卡组（表侧）把「霸王眷龙 异色眼」以外的「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽合计最多2只守备表示特殊召唤。
function c96733134.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和作为灵摆卡发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：把自己场上1只「霸王眷龙」怪兽解放才能发动。这张卡破坏，从卡组把1只攻击力1500以下的灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96733134,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCost(c96733134.thcost)
	e1:SetTarget(c96733134.thtg)
	e1:SetOperation(c96733134.thop)
	c:RegisterEffect(e1)
	-- ①：把自己场上2只「霸王眷龙」怪兽解放才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96733134,1))  --"解放「霸王眷龙」怪兽特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(c96733134.hspcost)
	e2:SetTarget(c96733134.hsptg)
	e2:SetOperation(c96733134.hspop)
	c:RegisterEffect(e2)
	-- ②：自己的灵摆怪兽和对方怪兽进行战斗的场合，给与对方的战斗伤害变成2倍。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c96733134.damtg)
	-- 设置战斗伤害改变效果的值，使对方受到的战斗伤害变成2倍。
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
	-- ③：自己·对方的战斗阶段把这张卡解放才能发动。从自己的额外卡组（表侧）把「霸王眷龙 异色眼」以外的「霸王眷龙」灵摆怪兽或「霸王门」灵摆怪兽合计最多2只守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(96733134,2))  --"额外卡组怪兽特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(0,TIMING_BATTLE_START)
	e4:SetCondition(c96733134.spcon)
	e4:SetCost(c96733134.spcost)
	e4:SetTarget(c96733134.sptg)
	e4:SetOperation(c96733134.spop)
	c:RegisterEffect(e4)
end
-- 灵摆效果①的Cost函数：检查并解放自己场上1只「霸王眷龙」怪兽。
function c96733134.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可以解放的「霸王眷龙」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x20f8) end
	-- 选择自己场上1只「霸王眷龙」怪兽。
	local sg=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x20f8)
	-- 解放选中的怪兽作为发动的代价。
	Duel.Release(sg,REASON_COST)
end
-- 过滤函数：检索卡组中攻击力1500以下的灵摆怪兽。
function c96733134.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAttackBelow(1500) and c:IsAbleToHand()
end
-- 灵摆效果①的Target函数：检查卡组中是否存在符合条件的卡，并设置破坏自身和检索卡片的操作信息。
function c96733134.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只攻击力1500以下的灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c96733134.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：破坏自身。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置连锁操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果①的Operation函数：破坏自身，并从卡组将1只攻击力1500以下的灵摆怪兽加入手牌。
function c96733134.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍在场，并将其破坏，若破坏失败则不处理后续效果。
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只符合条件的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c96733134.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：自己场上的「霸王眷龙」怪兽（若在对方场上控制则须表侧表示）。
function c96733134.rfilter(c,tp)
	return c:IsSetCard(0x20f8) and (c:IsControler(tp) or c:IsFaceup())
end
-- 怪兽效果①的Cost函数：检查并解放自己场上2只「霸王眷龙」怪兽。
function c96733134.hspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有可解放的「霸王眷龙」怪兽。
	local rg=Duel.GetReleaseGroup(tp):Filter(c96733134.rfilter,nil,tp)
	-- 检查是否能选择2只怪兽解放，且解放后有足够的怪兽区域用于特殊召唤。
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择2只解放后能腾出足够怪兽区域的「霸王眷龙」怪兽。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 应用代替解放等相关效果的次数限制。
	aux.UseExtraReleaseCount(g,tp)
	-- 解放选中的怪兽作为发动的代价。
	Duel.Release(g,REASON_COST)
end
-- 怪兽效果①的Target函数：检查自身是否能特殊召唤，并设置特殊召唤的操作信息。
function c96733134.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 怪兽效果①的Operation函数：将手牌的这张卡特殊召唤。
function c96733134.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查主怪兽区是否有空位，且此卡是否仍存在于手牌。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 怪兽效果②的Target函数：筛选进行战斗的自己的灵摆怪兽。
function c96733134.damtg(e,c)
	return c:IsType(TYPE_PENDULUM) and c:GetBattleTarget()~=nil
end
-- 怪兽效果③的Condition函数：检查当前是否为自己或对方的战斗阶段。
function c96733134.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否在战斗阶段开始到战斗阶段结束之间。
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 怪兽效果③的Cost函数：检查并解放自身。
function c96733134.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(c,REASON_COST)
end
-- 过滤函数：额外卡组中表侧表示的、除「霸王眷龙 异色眼」以外的「霸王眷龙」或「霸王门」灵摆怪兽，且能被特殊召唤。
function c96733134.spfilter(c,e,tp,rc)
	return c:IsFaceup() and c:IsSetCard(0x10f8,0x20f8)
		and c:IsType(TYPE_PENDULUM) and not c:IsCode(96733134)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查在解放此卡后，额外卡组怪兽特殊召唤到场上的可用格子是否足够。
		and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
end
-- 怪兽效果③的Target函数：检查额外卡组是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息。
function c96733134.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在至少1只符合特殊召唤条件的灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c96733134.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置连锁操作信息：从额外卡组特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果③的Operation函数：从额外卡组（表侧）将最多2只符合条件的怪兽守备表示特殊召唤。
function c96733134.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算额外卡组怪兽可特殊召唤到场上的最大空格数。
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	if ft==0 then return end
	ft=math.min(ft,2)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		ft=1
	end
	-- 检测是否存在限制特殊召唤次数的其他卡片效果（如某些特定限制卡）。
	local ect=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	if ect~=nil then ft=math.min(ft,ect) end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择最多ft张符合条件的灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c96733134.spfilter,tp,LOCATION_EXTRA,0,1,ft,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
