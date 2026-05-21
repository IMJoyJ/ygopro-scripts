--魔導召喚士 テンペル
-- 效果：
-- 自己把名字带有「魔导书」的魔法卡发动的自己回合的主要阶段时，把这张卡解放才能发动。从卡组把1只光属性或者暗属性的魔法师族·5星以上的怪兽特殊召唤。这个效果发动的回合，自己不能把其他的5星以上的怪兽特殊召唤。
function c87608852.initial_effect(c)
	-- 自己把名字带有「魔导书」的魔法卡发动的自己回合的主要阶段时，把这张卡解放才能发动。从卡组把1只光属性或者暗属性的魔法师族·5星以上的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87608852,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c87608852.spcost)
	e1:SetTarget(c87608852.sptg)
	e1:SetOperation(c87608852.spop)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测本回合玩家特殊召唤5星以上怪兽的次数
	Duel.AddCustomActivityCounter(87608852,ACTIVITY_SPSUMMON,c87608852.counterfilter)
	-- 注册一个自定义活动计数器，用于检测本回合玩家是否发动过「魔导书」魔法卡
	Duel.AddCustomActivityCounter(87608852,ACTIVITY_CHAIN,c87608852.chainfilter)
end
-- 计数器过滤函数：非5星以上的怪兽（即召唤了5星以上怪兽时计数器增加）
function c87608852.counterfilter(c)
	return not c:IsLevelAbove(5)
end
-- 连锁过滤函数：过滤出不是「魔导书」魔法卡发动的连锁（即发动了「魔导书」魔法卡时计数器增加）
function c87608852.chainfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0x106e))
end
-- 效果发动代价与条件判断：检查自身是否可解放、本回合是否未特殊召唤过其他5星以上怪兽、以及是否发动过「魔导书」魔法卡
function c87608852.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 检查本回合玩家是否没有特殊召唤过5星以上的怪兽
		and Duel.GetCustomActivityCount(87608852,tp,ACTIVITY_SPSUMMON)==0
		-- 检查本回合玩家是否发动过「魔导书」魔法卡
		and Duel.GetCustomActivityCount(87608852,tp,ACTIVITY_CHAIN)>0 end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
	-- 这个效果发动的回合，自己不能把其他的5星以上的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c87608852.splimit)
	e1:SetLabelObject(e)
	-- 给玩家注册不能特殊召唤其他5星以上怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：除本效果外，不能特殊召唤5星以上的怪兽
function c87608852.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se and c:IsLevelAbove(5)
end
-- 过滤卡组中满足条件的怪兽：5星以上、魔法师族、光属性或暗属性，且可以特殊召唤
function c87608852.spfilter(c,e,tp)
	return c:IsLevelAbove(5) and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(0x30)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标：检查怪兽区域是否有空位，以及卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c87608852.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否有可用位置（因为自身作为代价解放，所以可用位置数需大于-1）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1只符合条件的怪兽
		and Duel.IsExistingMatchingCard(c87608852.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前处理的连锁的操作信息为：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
end
-- 效果处理：从卡组中选择1只符合条件的怪兽特殊召唤
function c87608852.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否还有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c87608852.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
