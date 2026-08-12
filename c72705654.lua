--時空の雲篭
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
-- ②：把这张卡解放才能发动。从自己的卡组·墓地把「时空云笼」以外的1只「时空」怪兽特殊召唤。
-- ③：这张卡在手卡·墓地存在，自己把龙族超量怪兽特殊召唤的场合，以那之内的1只为对象才能发动。把这张卡作为那只怪兽的超量素材。
local s,id,o=GetID()
-- 初始化函数，注册卡片的效果①、效果②和效果③
function s.initial_effect(c)
	-- 注册一个用于检测此卡是否已存在于墓地的状态标记效果，防止在特殊召唤的同时送墓导致时点混淆
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从自己的卡组·墓地把「时空云笼」以外的1只「时空」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡组·墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- 注册并合并特殊召唤成功的延迟事件，用于后续检测自己把龙族超量怪兽特殊召唤的场合
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ③：这张卡在手卡·墓地存在，自己把龙族超量怪兽特殊召唤的场合，以那之内的1只为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"变成超量素材"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(custom_code)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e3:SetCountLimit(1,id+o*2)
	e3:SetLabelObject(e0)
	e3:SetCondition(s.matcon)
	e3:SetTarget(s.mattg)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：此卡加入手牌的原因不是抽卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- 效果①的发动检测与效果分类注册函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理函数：将此卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果关联，则将此卡以表侧表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 效果②的发动代价：解放场上的这张卡
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放作为发动代价的这张卡
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 效果②的过滤条件：卡组或墓地中「时空云笼」以外的、可以特殊召唤的「时空」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1b4) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动检测与效果分类注册函数
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查此卡解放后，自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查自己的卡组或墓地中是否存在至少1只满足条件的「时空」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示此效果会从卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果②的效果处理函数：从卡组或墓地选择1只「时空」怪兽特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给玩家发送提示信息，提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组或墓地选择1只满足条件的「时空」怪兽（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果③的发动条件过滤：场上表侧表示的、可以成为效果对象的、龙族超量怪兽，且排除因自身效果特殊召唤的情况
function s.cfilter(c,e,se)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e) and c:IsRace(RACE_DRAGON) and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果③的发动条件：自己把龙族超量怪兽特殊召唤的场合
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,e,se)
end
-- 效果③的对象过滤：本次特殊召唤成功的、自己场上的表侧表示龙族超量怪兽
function s.tgfilter(c,eg,tp)
	return eg:IsContains(c) and c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_DRAGON) and c:IsSummonPlayer(tp)
end
-- 效果③的对象选择与效果分类注册函数
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,eg,tp) end
	-- 检查场上是否存在可以作为效果对象的、本次特殊召唤的龙族超量怪兽
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,eg,tp)
		and e:GetHandler():IsCanOverlay() end
	if eg:GetCount()==1 then
		-- 当只有1只符合条件的怪兽特殊召唤时，直接将其设为效果的对象
		Duel.SetTargetCard(eg)
	else
		-- 给玩家发送提示信息，提示选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家选择1只本次特殊召唤的龙族超量怪兽作为效果的对象
		Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,eg,tp)
	end
	-- 设置离开墓地的操作信息，表示此卡会离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理函数：将此卡作为对象怪兽的超量素材
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将此卡重叠在对象怪兽下面，作为其超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
