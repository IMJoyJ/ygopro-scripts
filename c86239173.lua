--ヘルホーンドザウルス
-- 效果：
-- 「地狱猛禽翼龙」＋恐龙族·龙族怪兽
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。从自己的卡组·墓地把1张场地魔法卡在自己的场地区域表侧表示放置。
-- ②：这张卡在特殊召唤的回合可以直接攻击。
-- ③：自己主要阶段才能发动。进行1只恐龙族或龙族的怪兽的召唤。
function c86239173.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为「地狱猛禽翼龙」加上1只恐龙族或龙族怪兽
	aux.AddFusionProcCodeFun(c,50834074,c86239173.matfilter,1,true,true)
	-- ①：这张卡融合召唤的场合才能发动。从自己的卡组·墓地把1张场地魔法卡在自己的场地区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86239173,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,86239173)
	e1:SetCondition(c86239173.con)
	e1:SetTarget(c86239173.tg)
	e1:SetOperation(c86239173.op)
	c:RegisterEffect(e1)
	-- ②：这张卡在特殊召唤的回合可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(c86239173.pcon)
	c:RegisterEffect(e2)
	-- ③：自己主要阶段才能发动。进行1只恐龙族或龙族的怪兽的召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86239173,1))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,86239174)
	e3:SetTarget(c86239173.sumtg)
	e3:SetOperation(c86239173.sumop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤条件：龙族或恐龙族怪兽
function c86239173.matfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_DINOSAUR)
end
-- 效果①的发动条件：这张卡融合召唤成功
function c86239173.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 场地魔法卡过滤条件：非禁用、是场地魔法卡、且在场上唯一存在
function c86239173.pfilter(c,tp)
	return not c:IsForbidden() and c:IsType(TYPE_FIELD) and c:CheckUniqueOnField(tp)
end
-- 效果①的发动准备：检查卡组或墓地是否存在可放置的场地魔法卡
function c86239173.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地是否存在至少1张满足条件的场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c86239173.pfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
end
-- 效果①的效果处理：从卡组或墓地选择1张场地魔法卡，若己方场地区域已有卡则送去墓地，然后将选择的卡表侧表示放置到场地区域
function c86239173.op(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 玩家从卡组或墓地选择1张满足条件的场地魔法卡（受王家之谷影响）
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c86239173.pfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取自己场地区域当前的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 因规则原因将原本的场地卡送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果处理，使后续的放置动作与送墓不视为同时进行
			Duel.BreakEffect()
		end
		-- 将选择的场地魔法卡在自己的场地区域表侧表示放置
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
-- 效果②的适用条件：这张卡处于特殊召唤的回合
function c86239173.pcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler()
	return ec:IsStatus(STATUS_SPSUMMON_TURN)
end
-- 召唤怪兽过滤条件：手卡或怪兽区的龙族或恐龙族怪兽，且当前状态可以进行通常召唤
function c86239173.sumfilter(c)
	return c:IsRace(RACE_DRAGON+RACE_DINOSAUR) and c:IsSummonable(true,nil)
end
-- 效果③的发动准备：检查手卡或怪兽区是否存在可召唤的龙族或恐龙族怪兽，并设置召唤的操作信息
function c86239173.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或怪兽区是否存在至少1只可召唤的龙族或恐龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86239173.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置效果处理包含“召唤1只怪兽”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果③的效果处理：从手卡或怪兽区选择1只龙族或恐龙族怪兽进行通常召唤
function c86239173.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 玩家从手卡或怪兽区选择1只满足召唤条件的龙族或恐龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c86239173.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 玩家对选择的怪兽进行通常召唤（忽略每回合通常召唤次数限制）
		Duel.Summon(tp,tc,true,nil)
	end
end
