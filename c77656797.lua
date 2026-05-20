--焔聖騎士帝－シャルル
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的怪兽有装备卡被装备的场合才能发动（伤害步骤也能发动）。场上1张卡破坏。
-- ②：自己·对方的结束阶段才能发动。这张卡把1张可以装备的装备魔法卡从自己的手卡·墓地装备。那之后，可以从卡组把1只战士族·炎属性怪兽当作攻击力上升500的装备魔法卡使用给这张卡装备。
function c77656797.initial_effect(c)
	-- 设置同调召唤的手续为：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：场上的怪兽有装备卡被装备的场合才能发动（伤害步骤也能发动）。场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77656797,0))  --"选场上1张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_EQUIP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,77656797)
	e1:SetTarget(c77656797.destg)
	e1:SetOperation(c77656797.desop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段才能发动。这张卡把1张可以装备的装备魔法卡从自己的手卡·墓地装备。那之后，可以从卡组把1只战士族·炎属性怪兽当作攻击力上升500的装备魔法卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77656797,1))  --"装备卡给这张卡装备"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,77656798)
	e2:SetTarget(c77656797.eqtg)
	e2:SetOperation(c77656797.eqop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件与靶向检查函数：检查场上是否存在可以破坏的卡，并设置破坏的操作信息
function c77656797.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上（双方魔陷区和怪兽区）是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上（双方魔陷区和怪兽区）所有的卡
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁信息，表示该效果的处理为破坏场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的执行函数：让玩家选择场上1张卡并将其破坏
function c77656797.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上（双方魔陷区和怪兽区）的1张卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 闪烁显示被选择的卡片
		Duel.HintSelection(g)
		-- 因效果破坏被选择的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤函数：筛选手卡或墓地中可以装备给该怪兽、且在场上唯一的装备魔法卡
function c77656797.eqfilter(c,ec,tp)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- 过滤函数：筛选卡组中可以作为装备卡使用且在场上唯一的战士族·炎属性怪兽
function c77656797.eqfilter2(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- 效果②的发动条件与靶向检查函数：检查魔法与陷阱区域是否有空位，以及手卡或墓地中是否存在可装备的装备魔法卡
function c77656797.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且检查自己的手卡或墓地中是否存在满足装备条件的装备魔法卡
		and Duel.IsExistingMatchingCard(c77656797.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c,tp) end
end
-- 效果②的执行函数：将手卡或墓地的装备魔法卡装备给这张卡，之后可选择将卡组的战士族·炎属性怪兽作为上升500攻击力的装备卡装备给这张卡
function c77656797.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查魔法与陷阱区域是否有空位，以及自身是否仍表侧表示存在于场上，若不满足则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家从手卡或墓地（受王家长眠之谷影响）选择1张满足条件的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c77656797.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的卡作为装备卡装备给这张卡，若装备失败则结束效果处理
		if not Duel.Equip(tp,tc,c) then return end
		-- 检查卡组中是否存在可装备的战士族·炎属性怪兽
		if Duel.IsExistingMatchingCard(c77656797.eqfilter2,tp,LOCATION_DECK,0,1,nil,tp)
			-- 并且魔法与陷阱区域有空位，且玩家选择发动后续效果
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(77656797,2)) then  --"是否选怪兽装备？"
			-- 中断当前效果处理，使后续的装备处理与前一次装备不视为同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要装备的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 玩家从卡组选择1只满足条件的战士族·炎属性怪兽
			local g=Duel.SelectMatchingCard(tp,c77656797.eqfilter2,tp,LOCATION_DECK,0,1,1,nil,tp)
			local tc=g:GetFirst()
			-- 将选择的怪兽作为装备卡装备给这张卡，若装备失败则结束效果处理
			if not Duel.Equip(tp,tc,c) then return end
			-- 当作……装备魔法卡使用给这张卡装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(c)
			e1:SetValue(c77656797.eqlimit)
			tc:RegisterEffect(e1)
			-- 攻击力上升500
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(500)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
-- 装备限制函数：限制该装备卡只能装备给这张卡（焰圣骑士帝-查理）
function c77656797.eqlimit(e,c)
	return c==e:GetLabelObject()
end
