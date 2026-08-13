--覇王龍ズァーク
-- 效果：
-- ←1 【灵摆】 1→
-- ①：只要这张卡在灵摆区域存在，对方不能把场上的融合·同调·超量怪兽的效果发动。
-- ②：1回合1次，抽卡阶段以外从卡组有卡加入对方手卡时才能发动。那些卡破坏。
-- 【怪兽效果】
-- 龙族的融合·同调·超量·灵摆怪兽各1只合计4只
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡特殊召唤的场合发动。对方场上的卡全部破坏。
-- ②：这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ③：这张卡战斗破坏对方怪兽时才能发动。从卡组·额外卡组把1只「霸王眷龙」怪兽特殊召唤。
-- ④：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c13331639.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续，素材限定为龙族的融合·同调·超量·灵摆怪兽各1只，且不可使用融合代替素材。
	aux.AddFusionProcMix(c,false,true,c13331639.fusfilter1,c13331639.fusfilter2,c13331639.fusfilter3,c13331639.fusfilter4)
	-- 为这张卡添加灵摆怪兽属性（使其可作为灵摆卡在灵摆区域使用），但不注册灵摆卡“卡的发动的效果”。
	aux.EnablePendulumAttribute(c,false)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件的判定值设为aux.fuslimit，即只有通过融合召唤方式才能特殊召唤这张卡。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在灵摆区域存在，对方不能把场上的融合·同调·超量怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c13331639.limval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，抽卡阶段以外从卡组有卡加入对方手卡时才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13331639,0))  --"破坏加入手卡的卡"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c13331639.ddcon)
	e3:SetTarget(c13331639.ddtg)
	e3:SetOperation(c13331639.ddop)
	c:RegisterEffect(e3)
	-- ①：这张卡特殊召唤的场合发动。对方场上的卡全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(13331639,1))  --"对方场上的卡全部破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(c13331639.destg)
	e4:SetOperation(c13331639.desop)
	c:RegisterEffect(e4)
	-- 对方不能把这张卡作为效果的对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 设定该效果的判定值为aux.tgoval，即来自对方的效果不能把这张卡作为对象。
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设定该效果的判定值为aux.indoval，即来自对方的效果不能把这张卡破坏。
	e6:SetValue(aux.indoval)
	c:RegisterEffect(e6)
	-- ③：这张卡战斗破坏对方怪兽时才能发动。从卡组·额外卡组把1只「霸王眷龙」怪兽特殊召唤。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(13331639,2))  --"从卡组·额外卡组把1只「霸王眷龙」怪兽特殊召唤"
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果的发动条件为aux.bdocon，即这张卡在与对方怪兽的战斗中破坏对方怪兽。
	e7:SetCondition(aux.bdocon)
	e7:SetTarget(c13331639.sptg)
	e7:SetOperation(c13331639.spop)
	c:RegisterEffect(e7)
	-- ④：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(13331639,3))  --"这张卡在自己的灵摆区域放置"
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_DESTROYED)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCondition(c13331639.pencon)
	e8:SetTarget(c13331639.pentg)
	e8:SetOperation(c13331639.penop)
	c:RegisterEffect(e8)
end
c13331639.material_type=TYPE_SYNCHRO
-- 融合素材过滤函数1：素材必须是龙族且为融合怪兽。
function c13331639.fusfilter1(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_FUSION)
end
-- 融合素材过滤函数2：素材必须是龙族且为同调怪兽。
function c13331639.fusfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 融合素材过滤函数3：素材必须是龙族且为超量怪兽。
function c13331639.fusfilter3(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_XYZ)
end
-- 融合素材过滤函数4：素材必须是龙族且为灵摆怪兽。
function c13331639.fusfilter4(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_PENDULUM)
end
-- 灵摆效果①的判定函数：对方发动的效果若为场上融合·同调·超量怪兽的怪兽效果，则该效果不能发动。
function c13331639.limval(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER)
		and rc:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 灵摆效果②的发动条件判定：当前阶段不是抽卡阶段。
function c13331639.ddcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段不是抽卡阶段。
	return Duel.GetCurrentPhase()~=PHASE_DRAW
end
-- 过滤从卡组加入对方手卡的卡（这些卡的当前控制者是对方，且移动前在卡组）。
function c13331639.ddfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 发动时从事件组中筛选出从卡组加入对方手卡的卡，若存在则设定将其破坏。
function c13331639.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c13331639.ddfilter,nil,tp)
	if chk==0 then return g:GetCount()>0 end
	-- 设置本次连锁将破坏筛选出的卡，数量为实际数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，从事件组中筛选出从卡组加入对方手卡的卡并破坏。
function c13331639.ddop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c13331639.ddfilter,nil,tp)
	if g:GetCount()>0 then
		-- 以效果破坏这些卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 特殊召唤成功时取得对方场上的全部卡，并设置破坏信息。
function c13331639.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的全部卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 设置本次连锁将破坏对方场上的全部卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理时，获取对方场上全部卡并破坏。
function c13331639.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的全部卡。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if g:GetCount()>0 then
		-- 以效果破坏这些卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 特殊召唤对象过滤函数：必须是卡名含有「霸王眷龙」的怪兽且可以特殊召唤；从卡组特殊召唤需要己方主怪兽区有空位，从额外卡组特殊召唤需要有额外怪兽区或可用区域。
function c13331639.spfilter(c,e,tp)
	return c:IsSetCard(0x20f8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若素材来自卡组，则需主怪兽区有空位。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 若素材来自额外卡组，则需要有可从额外卡组特殊召唤的可用区域。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 发动时检查卡组·额外卡组是否存在1只可特殊召唤的「霸王眷龙」怪兽，若有则设置特殊召唤操作信息。
function c13331639.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动时点检测，则检查卡组·额外卡组是否存在至少1只符合条件的「霸王眷龙」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c13331639.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置本次连锁将从卡组·额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理时，从卡组·额外卡组选择1只「霸王眷龙」怪兽以表侧表示特殊召唤。
function c13331639.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择特殊召唤怪兽的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组·额外卡组选择1只符合条件的「霸王眷龙」怪兽。
	local g=Duel.SelectMatchingCard(tp,c13331639.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果④的发动条件：这张卡在怪兽区域表侧表示存在时被破坏。
function c13331639.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 发动时检查自己的灵摆区域左或右是否有可用空位。
function c13331639.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若自己的灵摆区域至少有一个空位，则可以发动。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 效果处理时，若这张卡仍与效果关联，则将其移动到自己灵摆区域表侧表示放置。
function c13331639.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡移动到自己的灵摆区域并表侧表示放置。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
