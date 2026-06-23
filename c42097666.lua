--青き眼の精霊
-- 效果：
-- 4星以下的龙族·魔法师族怪兽1只
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组选1张「光之灵堂」加入手卡或送去墓地。
-- ②：只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤。
-- ③：把这张卡解放才能发动。从自己的手卡·墓地把1只「青眼」怪兽特殊召唤。这个效果从墓地特殊召唤的效果怪兽不能攻击，效果无效化。
local s,id,o=GetID()
-- 初始化效果，注册连接召唤手续，设置连接召唤限制，创建三个效果
function s.initial_effect(c)
	-- 注册卡片效果中包含「光之灵堂」（24382602）
	aux.AddCodeList(c,24382602)
	-- 设置连接召唤所需素材为1~1个4星以下的龙族或魔法师族怪兽
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从卡组选1张「光之灵堂」加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己不是龙族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	-- ③：把这张卡解放才能发动。从自己的手卡·墓地把1只「青眼」怪兽特殊召唤。这个效果从墓地特殊召唤的效果怪兽不能攻击，效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 连接召唤所需素材的过滤条件：龙族或魔法师族且等级4以下
function s.mfilter(c)
	return (c:IsLinkRace(RACE_DRAGON) or c:IsLinkRace(RACE_SPELLCASTER)) and c:IsLevelBelow(4)
end
-- 效果发动条件：此卡为连接召唤成功
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索卡的过滤条件：卡号为24382602且可加入手卡或送去墓地
function s.cfilter(c)
	return c:IsCode(24382602) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 设置检索效果的目标信息：从卡组检索1张「光之灵堂」加入手卡或送去墓地
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件：卡组中是否存在满足条件的「光之灵堂」
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的回手牌操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置检索效果的送去墓地操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果：选择1张「光之灵堂」加入手卡或送去墓地
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择满足条件的「光之灵堂」
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		-- 判断选择的卡是否可加入手卡且可送去墓地，若不可则由玩家选择操作
		if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
			-- 将选择的卡加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的卡
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选择的卡送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end
-- 限制非龙族怪兽不能特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_DRAGON)
end
-- 设置效果发动所需费用：解放此卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 执行解放此卡的费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤的过滤条件：青眼系列且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xdd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标信息：从手卡或墓地特殊召唤1只青眼怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 判断手卡或墓地中是否存在满足条件的青眼怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 执行特殊召唤效果：从手卡或墓地特殊召唤1只青眼怪兽并使其不能攻击、效果无效
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断手卡或墓地中是否存在满足条件的青眼怪兽
	if Duel.GetMatchingGroupCount(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,nil,e,tp)==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local c=e:GetHandler()
	-- 从手卡或墓地中选择满足条件的青眼怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤并判断是否满足附加效果条件
	if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) and tc:IsSummonLocation(LOCATION_GRAVE) and tc:IsType(TYPE_EFFECT) then
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 使特殊召唤的怪兽不能攻击
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
