--武器庫整理
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把最多2张装备魔法卡送去墓地（同名卡最多1张）。
-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。把最多2张那只怪兽可以装备的装备魔法卡从自己的手卡·墓地给那只怪兽装备（同名卡最多1张）。只要这个效果把装备魔法卡装备中，那只怪兽给与对方的战斗伤害变成一半。
local s,id,o=GetID()
-- 注册两个效果，①为发动效果，②为装备效果
function s.initial_effect(c)
	-- ①：从卡组把最多2张装备魔法卡送去墓地（同名卡最多1张）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。把最多2张那只怪兽可以装备的装备魔法卡从自己的手卡·墓地给那只怪兽装备（同名卡最多1张）。只要这个效果把装备魔法卡装备中，那只怪兽给与对方的战斗伤害变成一半
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 过滤函数：装备魔法卡且能送去墓地
function s.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToGrave()
end
-- 发动效果的处理函数，设置操作信息为从卡组送1张装备魔法卡到墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：自己卡组存在至少1张装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组送1张装备魔法卡到墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 发动效果的处理函数，选择并送入墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取所有可送入墓地的装备魔法卡
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 选择最多2张不同名称的装备魔法卡
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
		-- 将选中的卡送入墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
-- 过滤函数：装备魔法卡且能装备给目标怪兽
function s.eqfilter(c,tc,tp)
	return c:IsAllTypes(TYPE_EQUIP+TYPE_SPELL) and c:CheckEquipTarget(tc) and not c:IsForbidden()
		and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 过滤函数：场上表侧表示的怪兽且其可以装备装备魔法卡
function s.mfilter(c,tp)
	-- 场上表侧表示的怪兽且其可以装备装备魔法卡
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,c:GetControler(),LOCATION_GRAVE+LOCATION_HAND,0,1,nil,c,tp)
end
-- 装备效果的目标选择处理函数，设置操作信息为装备魔法卡
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.mfilter(chkc) end
	-- 检查是否满足条件：自己场上有至少1只表侧表示的怪兽且有空余装备区
	if chk==0 then return Duel.IsExistingTarget(s.mfilter,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.mfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息为装备魔法卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 装备效果的处理函数，选择并装备装备魔法卡
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取目标怪兽所在玩家的装备区空位数
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ct>2 then ct=2 end
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and ct>0 then
		-- 获取所有可装备给目标怪兽的装备魔法卡（排除王家长眠之谷影响）
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,nil,tc,tp)
		-- 选择最多2张不同名称的装备魔法卡
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
		if not sg or sg:GetCount()==0 then return end
		-- 遍历选中的装备魔法卡
		for ec in aux.Next(sg) do
			-- 尝试将装备魔法卡装备给目标怪兽
			if Duel.Equip(tp,ec,tc,true,true) then
				-- ②：把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。把最多2张那只怪兽可以装备的装备魔法卡从自己的手卡·墓地给那只怪兽装备（同名卡最多1张）。只要这个效果把装备魔法卡装备中，那只怪兽给与对方的战斗伤害变成一半
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_EQUIP)
				e1:SetDescription(aux.Stringid(id,2))  --"装备怪兽战斗伤害变成一半"
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
				-- 设置战斗伤害为一半
				e1:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				ec:RegisterEffect(e1,true)
			end
		end
		-- 完成装备过程
		Duel.EquipComplete()
	end
end
