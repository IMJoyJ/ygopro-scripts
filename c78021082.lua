--妖精伝姫を紡ぐ者
-- 效果：
-- 「妖精传姬」怪兽＋魔法师族怪兽
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。自己的卡组·除外状态的1只「妖精传姬」怪兽特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，自己把地属性以外的「妖精传姬」怪兽召唤·特殊召唤的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效化，卡名当作「妖精王子」使用。
-- ③：场上的「妖精王子」变成魔法师族。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- 将「妖精王子」的卡号加入此卡的关联卡片列表中
	aux.AddCodeList(c,19144623)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，素材为「妖精传姬」怪兽＋魔法师族怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1db),aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),true)
	-- ①：自己主要阶段才能发动。自己的卡组·除外状态的1只「妖精传姬」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 为单张卡片注册合并延迟事件，监听自己召唤、特殊召唤成功时的时点
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS})
	-- ②：这张卡在怪兽区域存在的状态，自己把地属性以外的「妖精传姬」怪兽召唤·特殊召唤的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效化，卡名当作「妖精王子」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变卡名"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：场上的「妖精王子」变成魔法师族。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_RACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 过滤场上卡名为「妖精王子」的怪兽作为效果适用对象
	e3:SetTarget(aux.TargetBoolFunction(Card.IsCode,19144623))
	e3:SetValue(RACE_SPELLCASTER)
	c:RegisterEffect(e3)
end
-- 过滤卡组或除外状态中可以特殊召唤的「妖精传姬」怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0x1db) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备，检查怪兽区域空位以及是否存在可特召的「妖精传姬」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的卡组或除外状态中是否存在至少1只满足特召条件的「妖精传姬」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表明将从卡组或除外状态特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
-- ①号效果的处理，从卡组或除外状态选择1只「妖精传姬」怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己的卡组或除外状态选择1只满足条件的「妖精传姬」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己召唤、特殊召唤成功的地属性以外的「妖精传姬」怪兽
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1db) and c:IsSummonPlayer(tp)
		and not c:IsAttribute(ATTRIBUTE_EARTH)
end
-- ②号效果的发动条件，检查是否自己召唤、特殊召唤了地属性以外的「妖精传姬」怪兽（且不包含此卡自身）
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤对方场上未被无效的效果怪兽，或者卡名不是「妖精王子」的表侧表示怪兽
function s.disfilter(c)
	-- 检查怪兽是否为表侧表示的效果怪兽，且满足“未被无效”或“卡名不是「妖精王子」”的条件
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and (aux.NegateEffectMonsterFilter(c) or not c:IsCode(19144623))
end
-- ②号效果的发动准备，选择对方场上1只效果怪兽作为对象
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.disfilter(chkc) end
	-- 检查此卡在当前连锁中未注册过标记，且对方场上存在可选择的无效化对象
	if chk==0 then return c:GetFlagEffect(id)==0 and Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil) end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	-- 提示玩家选择要无效效果的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择对方场上1只满足条件的效果怪兽作为效果对象
	Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ②号效果的处理，使作为对象的怪兽效果无效，且卡名当作「妖精王子」使用
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain()
		and (tc:IsCanBeDisabledByEffect(e) or not tc:IsCode(19144623)) then
		-- 使与目标怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 卡名当作「妖精王子」使用。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_CHANGE_CODE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(19144623)
		tc:RegisterEffect(e3)
	end
end
