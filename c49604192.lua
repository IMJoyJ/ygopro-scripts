--八雲断巳剣
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己墓地有「巳剑」仪式魔法卡存在的场合，把原本卡名是「天丛云之巳剑」「布都御魂之巳剑」「天羽羽斩之巳剑」的自己场上的怪兽各1只解放才能发动。对方必须从自身的手卡·额外卡组·场上·墓地把合计8张卡除外。
local s,id,o=GetID()
-- 创建卡牌效果，设置为发动时可除外卡片，且只能发动一次
function s.initial_effect(c)
	-- 注册该卡的代码列表，包含「天丛云之巳剑」「布都御魂之巳剑」「天羽羽斩之巳剑」三张卡的编号
	aux.AddCodeList(c,13332685,19899073,55397172)
	-- 创建效果对象，设置为魔法卡发动效果，无限制次数，需要满足条件、支付费用、指定目标并执行效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 创建一个检查函数数组，用于验证是否能解放符合条件的怪兽
s.spchecks=aux.CreateChecks(Card.IsOriginalCodeRule,{13332685,19899073,55397172})
-- 过滤函数，用于判断墓地中的卡片是否为「巳剑」系列的仪式魔法卡
function s.cfilter(c)
	return c:IsSetCard(0x1c3) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_SPELL)
end
-- 判断条件函数，检查自己墓地是否存在「巳剑」系列的仪式魔法卡
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地是否存在至少1张「巳剑」系列的仪式魔法卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
-- 过滤函数，用于筛选自己场上的特定编号怪兽（即「天丛云之巳剑」「布都御魂之巳剑」「天羽羽斩之巳剑」）
function s.rlfilter(c,tp)
	return c:IsOriginalCodeRule(13332685,19899073,55397172) and (c:IsControler(tp) or c:IsFaceup())
end
-- 支付费用函数，检查是否能解放符合条件的怪兽并进行解放操作
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家可解放的卡片组，并筛选出符合条件的怪兽
	local g=Duel.GetReleaseGroup(tp,false):Filter(s.rlfilter,c,tp)
	if chk==0 then return g:CheckSubGroupEach(s.spchecks) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:SelectSubGroupEach(tp,s.spchecks,false)
	-- 使用额外解放次数，处理特殊解放效果
	aux.UseExtraReleaseCount(rg,tp)
	-- 执行解放操作，将选中的卡片从场上解放
	Duel.Release(rg,REASON_COST)
end
-- 目标设定函数，检查对方是否能除外至少8张卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上的所有卡片（手牌、额外、场上、墓地）
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA)
	-- 检查对方是否可以除外卡片
	if chk==0 then return Duel.IsPlayerCanRemove(1-tp)
		and g:IsExists(Card.IsAbleToRemove,8,nil,1-tp,POS_FACEUP,REASON_RULE) end
	-- 设置连锁操作信息，指定将要除外的卡片数量和位置
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND+LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果发动函数，处理对方除外卡片的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查对方是否能除外卡片，若不能则返回
	if not Duel.IsPlayerCanRemove(1-tp) then return end
	-- 获取所有可除外的卡片组（手牌、额外、场上、墓地）
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND+LOCATION_EXTRA,nil,1-tp,POS_FACEUP,REASON_RULE)
	if g:GetCount()>7 then
		-- 提示对方选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(1-tp,8,8,nil)
		if sg:GetCount()>7 then
			-- 执行除外操作，将选中的卡片从指定位置除外
			Duel.Remove(sg,POS_FACEUP,REASON_RULE,1-tp)
		end
	end
end
