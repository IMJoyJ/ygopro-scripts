--深淵の獣バルドレイク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己或者对方的墓地1只光·暗属性怪兽为对象才能发动（对方场上有怪兽存在的场合，这个效果在对方回合也能发动）。那只怪兽除外，这张卡从手卡特殊召唤。
-- ②：对方把仪式·融合·同调·超量·连接怪兽特殊召唤的场合，把自己场上1只其他的光·暗属性怪兽解放，以那1只特殊召唤的怪兽为对象才能发动。那只怪兽除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（手牌自身特召，分己方回合起动和对方场上有怪时的双方回合即时效果）和②效果（对方特召仪式/融合/同调/超量/连接怪兽时解放场上光暗属性怪兽将该特召怪兽除外）。
function s.initial_effect(c)
	-- ①：以自己或者对方的墓地1只光·暗属性怪兽为对象才能发动（对方场上有怪兽存在的场合，这个效果在对方回合也能发动）。那只怪兽除外，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)
	-- 注册一个合并的延迟事件监听器，用于监听对方特殊召唤成功这一时点，并返回自定义事件编码。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ②：对方把仪式·融合·同调·超量·连接怪兽特殊召唤的场合，把自己场上1只其他的光·暗属性怪兽解放，以那1只特殊召唤的怪兽为对象才能发动。那只怪兽除外。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤的怪兽除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(custom_code)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
end
-- 判定①效果作为起动效果发动的条件函数（对方场上没有怪兽存在）。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽数量是否为0。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
end
-- 判定①效果作为诱发即时效果发动的条件函数（对方场上有怪兽存在）。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽数量是否大于0。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤满足“光·暗属性且可以被除外”条件的怪兽。
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
-- ①效果的发动准备与合法性检测函数（包含对象选择和特殊召唤可行性判定）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.cfilter(chkc) end
	local c=e:GetHandler()
	-- 检查双方墓地是否存在至少1只满足条件的光·暗属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
		-- 并且自身怪兽区域有空位，且这张卡可以从手牌特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方墓地选择1只满足条件的光·暗属性怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置连锁信息，表明该效果包含将选中的1张卡除外的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置连锁信息，表明该效果包含将这张卡特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的执行函数（将对象怪兽除外，并将这张卡特殊召唤）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的作为对象的墓地怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍对应效果，若成功将其表侧表示除外且确实移至除外区，且自身卡片仍对应效果，则继续处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动者的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤满足“对方特殊召唤的、表侧表示存在于怪兽区域的仪式/融合/同调/超量/连接怪兽，且可以被除外并能成为效果对象”条件的怪兽。
function s.rmfilter(c,tp,e)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp)
		and c:IsType(TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		and c:IsAbleToRemove() and (not e or c:IsCanBeEffectTarget(e))
end
-- 过滤满足“自己场上的光·暗属性怪兽，且解放后不会导致没有可除外的目标”条件的可用作解放Cost的怪兽。
function s.costfilter(c,g,tp)
	-- 判定怪兽是否为光·暗属性，且在排除该怪兽后，被特殊召唤的怪兽组中仍有可除外的目标（防止将唯一的目标解放导致无法处理效果）。
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and g:FilterCount(aux.TRUE,c)>0
		and (c:IsControler(tp) or c:IsFaceup())
end
-- ②效果的发动准备与合法性检测函数（包含解放Cost of 支付和除外对象选择）。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=eg:Filter(s.rmfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return e:IsCostChecked() and #g>0
		-- 并且检查自己场上是否存在至少1只满足条件的可解放的光·暗属性怪兽（不包括自身）。
		and Duel.CheckReleaseGroup(tp,s.costfilter,1,c,g,tp) end
	-- 让玩家选择1只自己场上的其他光·暗属性怪兽作为解放的Cost。
	local rg=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,c,g,tp)
	-- 解放所选择的怪兽以支付发动代价。
	Duel.Release(rg,REASON_COST)
	local tg=g:Clone()
	if #g>1 then
		-- 提示玩家选择要除外的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		tg=g:Select(tp,1,1,nil)
	end
	-- 将选中的对方特殊召唤的怪兽设为当前连锁的效果对象。
	Duel.SetTargetCard(tg)
	-- 设置连锁信息，表明该效果包含将选中的特殊召唤怪兽除外的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,#tg,0,0)
end
-- ②效果的执行函数（将作为对象的特殊召唤怪兽除外）。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为对象的特殊召唤怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
