--インフェルノクインサーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组·墓地选1只鱼族通常怪兽特殊召唤。
-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。在自己场上把「地狱兵卒鲑衍生物」（鱼族·水·1星·攻/守0）任意数量特殊召唤。
function c27882993.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组·墓地选1只鱼族通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27882993,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,27882993)
	e1:SetTarget(c27882993.sptg)
	e1:SetOperation(c27882993.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗或者对方的效果破坏的场合才能发动。在自己场上把「地狱兵卒鲑衍生物」（鱼族·水·1星·攻/守0）任意数量特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(27882993,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,27882994)
	e3:SetCondition(c27882993.tokcon)
	e3:SetTarget(c27882993.toktg)
	e3:SetOperation(c27882993.tokop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的鱼族通常怪兽
function c27882993.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 效果发动时的处理函数，用于判断是否可以发动效果
function c27882993.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌·卡组·墓地是否存在满足条件的鱼族通常怪兽
		and Duel.IsExistingMatchingCard(c27882993.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息，确定要特殊召唤的卡的来源
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果发动时的处理函数，用于执行效果
function c27882993.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的鱼族通常怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27882993.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断该卡是否因战斗或对方效果被破坏
function c27882993.tokcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end
-- 效果发动时的处理函数，用于判断是否可以发动效果
function c27882993.toktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,27882994,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FISH,ATTRIBUTE_WATER) end
	-- 设置效果发动时的操作信息，确定要召唤的衍生物数量
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果发动时的操作信息，确定要特殊召唤的卡数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果发动时的处理函数，用于执行效果
function c27882993.tokop(e,tp,eg,ep,ev,re,r,rp)
	local ft=5
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 计算可特殊召唤的衍生物数量
	ft=math.min(ft,(Duel.GetLocationCount(tp,LOCATION_MZONE)))
	-- 判断是否满足特殊召唤衍生物的条件
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,27882994,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FISH,ATTRIBUTE_WATER) then return end
	repeat
		-- 创建一张衍生物
		local token=Duel.CreateToken(tp,27882994)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		ft=ft-1
	-- 询问玩家是否继续特殊召唤衍生物
	until ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(27882993,2))  --"是否继续特殊召唤？"
	-- 完成所有特殊召唤操作
	Duel.SpecialSummonComplete()
end
