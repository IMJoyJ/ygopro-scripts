--覇雷星ライジン
-- 效果：
-- 5星以上的战士族·光属性怪兽＋战士族·地属性怪兽
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ②：这张卡用和不持有等级的怪兽的战斗给与对方的战斗伤害变成2倍。
-- ③：这张卡被战斗·效果破坏送去墓地的回合的结束阶段，以自己墓地2只7星以下的战士族怪兽为对象才能发动。那些怪兽特殊召唤。
function c99991455.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只满足ffilter1（5星以上·战士族·光属性）和1只满足ffilter2（战士族·地属性）的怪兽作为融合素材。
	aux.AddFusionProcFun2(c,c99991455.ffilter1,c99991455.ffilter2,true)
	-- ①：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	-- ②：这张卡用和不持有等级的怪兽的战斗给与对方的战斗伤害变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(c99991455.damcon)
	-- 设置战斗伤害变更效果：对方受到的来自这张卡的战斗伤害变为2倍。
	e2:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏送去墓地的回合的结束阶段。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c99991455.regop)
	c:RegisterEffect(e3)
end
-- 融合素材1的筛选条件：等级在5星以上、战士族、光属性。
function c99991455.ffilter1(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_WARRIOR) and c:IsFusionAttribute(ATTRIBUTE_LIGHT)
end
-- 融合素材2的筛选条件：战士族、地属性。
function c99991455.ffilter2(c)
	return c:IsRace(RACE_WARRIOR) and c:IsFusionAttribute(ATTRIBUTE_EARTH)
end
-- 战斗伤害翻倍效果的条件：这张卡的战斗对象存在，且该对象不持有等级（没有等级）。
function c99991455.damcon(e)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and not bc:IsLevelAbove(0)
end
-- 这张卡被战斗或效果破坏送去墓地时，注册一个在结束阶段发动的效果：该效果取对象特殊召唤墓地2只7星以下战士族，且一回合只能使用1次。
function c99991455.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY) then
		-- 这个卡名的③的效果1回合只能使用1次。以自己墓地2只7星以下的战士族怪兽为对象才能发动。那些怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(99991455,0))
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e1:SetCountLimit(1,99991455)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c99991455.sptg)
		e1:SetOperation(c99991455.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤目标的筛选条件：可以被特殊召唤、等级在7星以下、战士族。
function c99991455.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(7) and c:IsRace(RACE_WARRIOR)
end
-- 效果发动时点检查：自己场上可用怪兽区域不少于2个，且墓地存在至少2只满足条件的战士族怪兽可作为对象；同时不受【青眼精灵龙】禁止同时特殊召唤2只以上怪兽的效果影响。
function c99991455.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c99991455.filter(chkc,e,tp) end
	-- 发动条件之一：自己场上至少有2个可用怪兽区域，用于特殊召唤2只怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 发动条件之二：墓地存在至少2只满足c99991455.filter的战士族怪兽，且它们能成为效果对象。
		and Duel.IsExistingTarget(c99991455.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 显示选择提示信息，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择2只符合条件的战士族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c99991455.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设定本次连锁的操作信息为特殊召唤2只怪兽，便于其他卡与此效果连锁。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理：从效果对象中筛选仍相关的卡，按可用区域数量选择实际召唤数量，依次特殊召唤到场上。
function c99991455.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 取得连锁处理时对象卡组中仍与效果相关的卡片（未离开墓地、未被无效等）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if g:GetCount()>ft then
		-- 当可特殊召唤数量受可用区域限制时，提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 将一只对象怪兽以表侧表示特殊召唤（分步特殊召唤的第一步）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc=g:GetNext()
	end
	-- 结束分步特殊召唤流程，完成整个特殊召唤处理。
	Duel.SpecialSummonComplete()
end
