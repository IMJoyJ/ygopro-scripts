--超重禽属コカトリウム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把自己场上1只兽族·兽战士族·鸟兽族怪兽解放才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：从卡组把1只4星以下的兽族·兽战士族·鸟兽族怪兽除外才能发动。直到结束阶段，这张卡当作和除外的怪兽同名卡使用，变成相同种族·属性·等级。
function c94395649.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，把自己场上1只兽族·兽战士族·鸟兽族怪兽解放才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94395649,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,94395649)
	e1:SetCost(c94395649.spcost)
	e1:SetTarget(c94395649.sptg)
	e1:SetOperation(c94395649.spop)
	c:RegisterEffect(e1)
	-- ②：从卡组把1只4星以下的兽族·兽战士族·鸟兽族怪兽除外才能发动。直到结束阶段，这张卡当作和除外的怪兽同名卡使用，变成相同种族·属性·等级。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94395649,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,94395650)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c94395649.cost)
	e2:SetOperation(c94395649.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己场上可解放的兽族、兽战士族或鸟兽族怪兽，并确保解放后有空余怪兽区域
function c94395649.cfilter(c,tp)
	-- 检查怪兽是否为兽族、兽战士族或鸟兽族，且解放该怪兽后能留出可用于特殊召唤的怪兽区域
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and Duel.GetMZoneCount(tp,c)>0
		and (c:IsFaceup() or c:IsControler(tp))
end
-- 效果①的发动代价：解放自己场上1只兽族·兽战士族·鸟兽族怪兽
function c94395649.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查场上是否存在可解放的满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c94395649.cfilter,1,nil,tp) end
	-- 让玩家选择1只满足条件的怪兽解放
	local g=Duel.SelectReleaseGroup(tp,c94395649.cfilter,1,1,nil,tp)
	-- 解放选中的怪兽
	Duel.Release(g,REASON_COST)
end
-- 效果①的靶向/发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c94395649.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：将这张卡特殊召唤，并添加离场时除外的效果
function c94395649.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果关联，则将其特殊召唤，若特殊召唤成功则执行后续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：从卡组把1只4星以下的兽族·兽战士族·鸟兽族怪兽除外才能发动。直到结束阶段，这张卡当作和除外的怪兽同名卡使用，变成相同种族·属性·等级。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤函数：筛选卡组中4星以下的兽族·兽战士族·鸟兽族怪兽，且该怪兽可以被除外
function c94395649.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价：从卡组将1只4星以下的兽族·兽战士族·鸟兽族怪兽除外
function c94395649.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94395649.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c94395649.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
-- 效果②的效果处理：直到结束阶段，这张卡当作和除外的怪兽同名卡使用，变成相同种族·属性·等级
function c94395649.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 直到结束阶段，这张卡当作和除外的怪兽同名卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(tc:GetOriginalCode())
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RACE)
		e2:SetValue(tc:GetOriginalRace())
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetValue(tc:GetOriginalAttribute())
		c:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_LEVEL)
		e4:SetValue(tc:GetOriginalLevel())
		c:RegisterEffect(e4)
	end
end
