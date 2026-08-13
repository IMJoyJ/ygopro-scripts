--B・F－決戦のビッグ・バリスタ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡特殊召唤成功的场合，把自己墓地的昆虫族怪兽全部除外才能发动。对方场上的全部怪兽的攻击力·守备力下降除外中的自己的昆虫族怪兽数量×500。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：同调召唤的这张卡被对方破坏的场合才能发动。选除外的3只自己的11星以下的昆虫族怪兽特殊召唤。
function c26443791.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（任意）＋1只以上调整以外的怪兽（任意）。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 效果①：这张卡特殊召唤成功的场合，把自己墓地的昆虫族怪兽全部除外才能发动。对方场上的全部怪兽的攻击力·守备力下降除外中的自己的昆虫族怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCost(c26443791.atkcost)
	e1:SetTarget(c26443791.atktg)
	e1:SetOperation(c26443791.atkop)
	c:RegisterEffect(e1)
	-- 效果②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 效果③：同调召唤的这张卡被对方破坏的场合才能发动。选除外的3只自己的11星以下的昆虫族怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c26443791.spcon)
	e3:SetTarget(c26443791.sptg)
	e3:SetOperation(c26443791.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断一张卡是否为可用于①cost的昆虫族怪兽，即属于昆虫族且能够作为cost除外。
function c26443791.cfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost()
end
-- ①的cost处理：获取自己墓地中符合条件的昆虫族怪兽组，如果存在则将其全部表侧除外作为发动代价。
function c26443791.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中所有昆虫族且可作除外的卡（不取对象，全部选出）。
	local g=Duel.GetMatchingGroup(c26443791.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 将选出的昆虫族怪兽组全部表侧表示除外并计入REASON_COST，作为①的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①的发动目标判定：需要对方场上有至少1只表侧表示怪兽才能发动（因为要下降对方场上全部怪兽的能力值）。
function c26443791.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：对方怪兽区是否存在至少1张表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 过滤函数：用于统计除外区中自己的表侧昆虫族怪兽数量，作为①的能力下降数值来源。
function c26443791.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- ①效果处理：取得对方场上全部表侧表示怪兽，统计除外区昆虫族数量ct，给每只对象怪兽注册攻击力/守备力下降ct×500的永续效果（离场等标准重置）。
function c26443791.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上全部表侧表示怪兽，作为①效果影响的对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	-- 统计除外区中自己的表侧昆虫族怪兽数量ct，用于计算攻击力/守备力的下降值。
	local ct=Duel.GetMatchingGroupCount(c26443791.atkfilter,tp,LOCATION_REMOVED,0,nil)
	while tc do
		-- 对方场上的全部怪兽的攻击力·守备力下降除外中的自己的昆虫族怪兽数量×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*-500)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- ③的发动条件：这张卡是被对方破坏的场合才能发动，且需要是同调召唤的这张卡、破坏前由我方控制并存在于怪兽区。
function c26443791.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤函数：用于选择③特殊召唤的卡，要求是表侧表示的昆虫族怪兽、等级11以下且可以被特殊召唤。
function c26443791.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsLevelBelow(11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③的发动目标判定：当前没有青眼精灵龙的‘不能同时特殊召唤2只以上怪兽’限制、自己场上可用怪兽区大于2，且除外区存在至少3只满足条件的昆虫族怪兽。
function c26443791.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 追加条件：自己场上的可用怪兽区空格数必须大于2，确保能放下3只特殊召唤的怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		-- 追加条件：除外区中存在至少3只自己的昆虫族且符合特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c26443791.spfilter,tp,LOCATION_REMOVED,0,3,nil,e,tp) end
	-- 设置操作信息：该连锁将进行特殊召唤处理，预计从除外区特殊召唤3只怪兽（处理时确定对象），供其他卡的效果联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_REMOVED)
end
-- ③效果处理：再次确认青眼精灵龙限制和怪兽区空格数，然后从除外区选择3只符合条件的昆虫族怪兽，以表侧表示特殊召唤到自己场上。
function c26443791.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 处理时防御检查：自己场上可用怪兽区少于3个则无法特殊召唤3只，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	-- 给玩家弹出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从除外区选择3张满足spfilter条件的自己的昆虫族怪兽（必须有恰好3张）。
	local g=Duel.SelectMatchingCard(tp,c26443791.spfilter,tp,LOCATION_REMOVED,0,3,3,nil,e,tp)
	if #g>0 then
		-- 将选择的3只怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
