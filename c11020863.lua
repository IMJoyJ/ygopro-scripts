--ロイヤル・ストレート・スラッシャー
-- 效果：
-- 这张卡不能通常召唤，用「同花大顺」的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己墓地有「王后骑士」「卫兵骑士」「国王骑士」全部存在的场合才能发动。1～5星的怪兽各1只从手卡·卡组送去墓地，对方场上的卡全部破坏。
-- ②：这张卡被战斗破坏时，以自己墓地最多3只战士族·光属性怪兽为对象才能发动。那些怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册所需卡名代码，启用特殊召唤限制，并创建①②效果
function s.initial_effect(c)
	-- 记录该卡与「王后骑士」「卫兵骑士」「国王骑士」的关联
	aux.AddCodeList(c,25652259,64788463,90876561)
	c:EnableReviveLimit()
	-- ①：自己墓地有「王后骑士」「卫兵骑士」「国王骑士」全部存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡不能通常召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏时，以自己墓地最多3只战士族·光属性怪兽为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ①：自己墓地有「王后骑士」「卫兵骑士」「国王骑士」全部存在的场合才能发动。1～5星的怪兽各1只从手卡·卡组送去墓地，对方场上的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 判断墓地是否同时存在「王后骑士」「卫兵骑士」「国王骑士」
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断墓地是否存在「王后骑士」
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,25652259)
		-- 判断墓地是否存在「卫兵骑士」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,64788463)
		-- 判断墓地是否存在「国王骑士」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,90876561)
end
-- 定义用于筛选1～5星怪兽的过滤器
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(5) and c:IsAbleToGrave()
end
-- ①效果的发动时点处理，检查是否满足发动条件并设置操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查对方场上是否存在至少1张卡
		if not Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) then return false end
		-- 获取手卡和卡组中满足条件的怪兽组
		local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		-- 检查所选怪兽组是否满足等级各不相同的条件
		return tg:CheckSubGroup(aux.dlvcheck,5,5)
	end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置将要送去墓地的卡数量为5
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,5,tp,LOCATION_HAND+LOCATION_DECK)
	-- 设置将要破坏的对方场上卡的数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ①效果的处理，选择并送去墓地的卡，并破坏对方场上所有卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡和卡组中满足条件的怪兽组
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从满足条件的怪兽组中选择5张等级各不相同的卡
	local sg=tg:SelectSubGroup(tp,aux.dlvcheck,false,5,5)
	if sg then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
		-- 获取对方场上的所有卡
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			-- 破坏对方场上所有卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 定义用于筛选战士族·光属性怪兽的过滤器
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动时点处理，检查是否满足发动条件并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否满足②效果发动条件
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft>3 then ft=3 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的最多3只怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置将要特殊召唤的卡数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
-- ②效果的处理，将选中的怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁中目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将选中的卡特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
