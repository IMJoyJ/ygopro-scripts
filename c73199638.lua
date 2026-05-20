--海皇の咆哮
-- 效果：
-- 选择自己墓地3只3星以下的海龙族怪兽才能发动。选择的3只怪兽从墓地特殊召唤。这张卡发动的回合，自己不能把怪兽特殊召唤。
function c73199638.initial_effect(c)
	-- 选择自己墓地3只3星以下的海龙族怪兽才能发动。选择的3只怪兽从墓地特殊召唤。这张卡发动的回合，自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c73199638.cost)
	e1:SetTarget(c73199638.target)
	e1:SetOperation(c73199638.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价，检查并注册本回合不能特殊召唤的誓约效果
function c73199638.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己本回合是否进行过特殊召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能把怪兽特殊召唤。选择自己墓地3只3星以下的海龙族怪兽才能发动。选择的3只怪兽从墓地特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c73199638.sumlimit)
	-- 将不能特殊召唤的限制效果注册给发动玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制除了本效果以外的特殊召唤
function c73199638.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
-- 过滤出等级在3星以下、海龙族且可以特殊召唤的怪兽
function c73199638.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检测，包括检测青眼精灵龙的影响、怪兽区域空位数以及墓地是否存在3只符合条件的怪兽
function c73199638.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c73199638.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域空位数是否大于2个
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 检查自己墓地是否存在至少3只满足条件的可选择对象
		and Duel.IsExistingTarget(c73199638.filter,tp,LOCATION_GRAVE,0,3,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地3只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c73199638.filter,tp,LOCATION_GRAVE,0,3,3,nil,e,tp)
	-- 设置连锁信息，表明此效果的操作为特殊召唤这3张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,3,0,0)
end
-- 过滤出仍与效果相关联且可以特殊召唤的怪兽
function c73199638.rfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理，在满足青眼精灵龙、怪兽区域空位和对象卡片状态等条件时，将选择的3只怪兽特殊召唤
function c73199638.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取当前连锁中被选择为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=2 then return end
	if g:FilterCount(c73199638.rfilter,nil,e,tp)~=3 then return end
	-- 将选择的怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
