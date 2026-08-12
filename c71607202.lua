--魔界特派員デスキャスター
-- 效果：
-- 效果怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。这张卡在连接召唤的回合不能作为连接素材。
-- ①：自己场上的怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1只恶魔族怪兽解放。
-- ②：以「魔界特派员 死亡主播」以外的自己墓地1只恶魔族怪兽为对象才能发动。选自己1张手卡丢弃，作为对象的怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含连接召唤手续、连接素材限制、代替破坏的永续效果以及特殊召唤的起动效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：效果怪兽2只。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,2)
	-- 这张卡在连接召唤的回合不能作为连接素材。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(s.lmlimit)
	c:RegisterEffect(e0)
	-- ①：自己场上的怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1只恶魔族怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.desreptg)
	e1:SetValue(s.desrepval)
	e1:SetOperation(s.desrepop)
	c:RegisterEffect(e1)
	-- ②：以「魔界特派员 死亡主播」以外的自己墓地1只恶魔族怪兽为对象才能发动。选自己1张手卡丢弃，作为对象的怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 限制条件：判断自身是否在特殊召唤（连接召唤）的回合。
function s.lmlimit(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤自身场上因战斗或效果破坏且非代替破坏的怪兽。
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE)
end
-- 过滤场上未确定破坏且未被战斗破坏的恶魔族怪兽（用于作为代替解放）。
function s.rfilter(c)
	return c:IsRace(RACE_FIEND)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的靶指向/检查函数，检查是否有怪兽被破坏以及自己场上是否有可解放的恶魔族怪兽。
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		-- 检查自己场上是否存在至少1只可解放的恶魔族怪兽。
		and Duel.CheckReleaseGroupEx(tp,s.rfilter,1,REASON_EFFECT,false,nil) end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 确定需要代替破坏的卡片是否符合过滤条件。
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的执行函数，选择并解放1只恶魔族怪兽。
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要代替破坏（解放）的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
	-- 玩家选择1只可解放的恶魔族怪兽。
	local g=Duel.SelectReleaseGroupEx(tp,s.rfilter,1,1,REASON_EFFECT,false,nil)
	-- 提示发动了该卡（魔界特派员 死亡主播）的效果。
	Duel.Hint(HINT_CARD,0,id)
	-- 将选中的怪兽作为代替破坏解放。
	Duel.Release(g,REASON_EFFECT+REASON_REPLACE)
end
-- 过滤墓地中除同名卡以外、可特殊召唤的恶魔族怪兽。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶指向/检查函数，处理取对象和丢弃手卡的检查。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的恶魔族怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己手卡是否存在可丢弃的卡。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只恶魔族怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含特殊召唤选定怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的执行函数，处理丢弃手卡、特殊召唤以及后续的特殊召唤限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 玩家选择并丢弃1张手卡。
	if Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT,nil)>0
		and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是恶魔族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该特殊召唤限制效果给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能特殊召唤恶魔族以外的怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_FIEND)
end
