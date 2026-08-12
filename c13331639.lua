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
	-- 为卡片添加融合召唤手续，使用龙族融合·同调·超量·灵摆怪兽各1只为融合素材
	aux.AddFusionProcMix(c,false,true,c13331639.fusfilter1,c13331639.fusfilter2,c13331639.fusfilter3,c13331639.fusfilter4)
	-- 为卡片添加灵摆怪兽属性，启用灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c,false)
	-- ①：只要这张卡在灵摆区域存在，对方不能把场上的融合·同调·超量怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为必须通过融合召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ②：1回合1次，抽卡阶段以外从卡组有卡加入对方手卡时才能发动。那些卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c13331639.limval)
	c:RegisterEffect(e2)
	-- ①：这张卡特殊召唤的场合发动。对方场上的卡全部破坏。
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
	-- ②：这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(13331639,1))  --"对方场上的卡全部破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(c13331639.destg)
	e4:SetOperation(c13331639.desop)
	c:RegisterEffect(e4)
	-- ③：这张卡战斗破坏对方怪兽时才能发动。从卡组·额外卡组把1只「霸王眷龙」怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	-- 设置效果使卡片不会被对方的效果破坏
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果使卡片不会被对方的效果破坏
	e6:SetValue(aux.indoval)
	c:RegisterEffect(e6)
	-- ④：怪兽区域的这张卡被战斗·效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(13331639,2))  --"从卡组·额外卡组把1只「霸王眷龙」怪兽特殊召唤"
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果使卡片在战斗破坏对方怪兽时才能发动
	e7:SetCondition(aux.bdocon)
	e7:SetTarget(c13331639.sptg)
	e7:SetOperation(c13331639.spop)
	c:RegisterEffect(e7)
	-- 龙族的融合·同调·超量·灵摆怪兽各1只合计4只
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
-- 融合素材过滤函数1：检查是否为龙族融合怪兽
function c13331639.fusfilter1(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_FUSION)
end
-- 融合素材过滤函数2：检查是否为龙族同调怪兽
function c13331639.fusfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 融合素材过滤函数3：检查是否为龙族超量怪兽
function c13331639.fusfilter3(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_XYZ)
end
-- 融合素材过滤函数4：检查是否为龙族灵摆怪兽
function c13331639.fusfilter4(c)
	return c:IsRace(RACE_DRAGON) and c:IsFusionType(TYPE_PENDULUM)
end
-- 限制效果发动的过滤函数：判断是否为融合·同调·超量怪兽
function c13331639.limval(e,re,rp)
	local rc=re:GetHandler()
	return rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER)
		and rc:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 破坏加入手卡效果的触发条件：当前阶段不是抽卡阶段
function c13331639.ddcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段不是抽卡阶段
	return Duel.GetCurrentPhase()~=PHASE_DRAW
end
-- 过滤加入手卡的卡的函数：判断是否为对方从卡组加入手卡的卡
function c13331639.ddfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPreviousLocation(LOCATION_DECK)
end
-- 破坏加入手卡效果的目标设定函数
function c13331639.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(c13331639.ddfilter,nil,tp)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息为破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏加入手卡效果的处理函数
function c13331639.ddop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c13331639.ddfilter,nil,tp)
	if g:GetCount()>0 then
		-- 实际执行破坏操作
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 特殊召唤效果的目标设定函数
function c13331639.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 设置操作信息为破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 特殊召唤效果的处理函数
function c13331639.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if g:GetCount()>0 then
		-- 实际执行破坏操作
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 特殊召唤目标卡的过滤函数
function c13331639.spfilter(c,e,tp)
	return c:IsSetCard(0x20f8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断卡是否在卡组且场上怪兽区有空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 判断卡是否在额外卡组且有特殊召唤空位
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 特殊召唤效果的目标设定函数
function c13331639.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的特殊召唤目标
	if chk==0 then return Duel.IsExistingMatchingCard(c13331639.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤目标卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 特殊召唤效果的处理函数
function c13331639.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择特殊召唤目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,c13331639.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 灵摆区域放置效果的触发条件函数
function c13331639.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 灵摆区域放置效果的目标设定函数
function c13331639.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可用的灵摆区域
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 灵摆区域放置效果的处理函数
function c13331639.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片移动到灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
