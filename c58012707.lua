--G・ボールパーク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：伤害计算时才能发动。那次战斗发生的双方的战斗伤害变成0，从自己卡组把1只4星以下的昆虫族怪兽送去墓地。这个效果让通常怪兽被送去墓地的场合，可以再从自己的手卡·卡组·墓地选那些同名怪兽任意数量特殊召唤。
-- ②：自己场上的怪兽被对方的效果送去墓地的场合才能发动。从自己墓地选1只昆虫族通常怪兽特殊召唤。
function c58012707.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：伤害计算时才能发动。那次战斗发生的双方的战斗伤害变成0，从自己卡组把1只4星以下的昆虫族怪兽送去墓地。这个效果让通常怪兽被送去墓地的场合，可以再从自己的手卡·卡组·墓地选那些同名怪兽任意数量特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58012707,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,58012707)
	e2:SetCondition(c58012707.dmcon)
	e2:SetTarget(c58012707.dmtg)
	e2:SetOperation(c58012707.dmop)
	c:RegisterEffect(e2)
	-- ②：自己场上的怪兽被对方的效果送去墓地的场合才能发动。从自己墓地选1只昆虫族通常怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58012707,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,58012708)
	e3:SetCondition(c58012707.spcon)
	e3:SetTarget(c58012707.sptg)
	e3:SetOperation(c58012707.spop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数
function c58012707.dmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己或对方在本次战斗中受到的战斗伤害是否大于0
	return Duel.GetBattleDamage(tp)>0 or Duel.GetBattleDamage(1-tp)>0
end
-- 过滤条件：卡组中4星以下的昆虫族怪兽且能送去墓地
function c58012707.tgfilter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_INSECT) and c:IsAbleToGrave()
end
-- 效果①的发动准备（Target）函数
function c58012707.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只4星以下的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58012707.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：从手卡、卡组、墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 过滤条件：与送去墓地的怪兽同名且可以特殊召唤
function c58012707.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的效果处理（Operation）函数
function c58012707.dmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：伤害计算时才能发动。那次战斗发生的双方的战斗伤害变成0，从自己卡组把1只4星以下的昆虫族怪兽送去墓地。这个效果让通常怪兽被送去墓地的场合，可以再从自己的手卡·卡组·墓地选那些同名怪兽任意数量特殊召唤。②：自己场上的怪兽被对方的效果送去墓地的场合才能发动。从自己墓地选1只昆虫族通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册使双方战斗伤害变成0的全局效果
	Duel.RegisterEffect(e1,tp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的昆虫族怪兽
	local tc=Duel.SelectMatchingCard(tp,c58012707.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	-- 将选中的怪兽送去墓地，并检查该怪兽是否成功送去墓地且为通常怪兽
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) and tc:IsType(TYPE_NORMAL) then
		-- 获取手卡、卡组、墓地中不受王家长眠之谷影响的同名怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c58012707.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp,tc:GetCode())
		-- 获取自己场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 若存在可特召的同名怪兽且场上有空位，询问玩家是否特殊召唤
		if g:GetCount()>0 and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(58012707,1)) then  --"是否特殊召唤同名怪兽？"
			-- 中断当前效果处理，使后续的特殊召唤处理与送去墓地不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,ft,nil)
			-- 将选中的同名怪兽特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤条件：自己场上的怪兽因效果送去墓地
function c58012707.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 效果②的发动条件判定函数
function c58012707.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c58012707.cfilter,1,nil,tp)
end
-- 过滤条件：墓地的昆虫族通常怪兽且可以特殊召唤
function c58012707.spfilter2(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（Target）函数
function c58012707.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的昆虫族通常怪兽
		and Duel.IsExistingMatchingCard(c58012707.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：从自己墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理（Operation）函数
function c58012707.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此卡是否仍在场上，且自己场上是否有可用的怪兽区域，若不满足则不处理
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只不受王家长眠之谷影响的昆虫族通常怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c58012707.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
