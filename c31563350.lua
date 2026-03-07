--ズババジェネラル
-- 效果：
-- 4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。从手卡把1只战士族怪兽当作装备卡使用给这张卡装备。这张卡的攻击力上升这个效果装备的怪兽的攻击力数值。
function c31563350.initial_effect(c)
	-- 为卡片添加等级为4、需要2个超量素材的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。从手卡把1只战士族怪兽当作装备卡使用给这张卡装备。这张卡的攻击力上升这个效果装备的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31563350,0))  --"装备怪兽"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c31563350.eqcost)
	e1:SetTarget(c31563350.eqtg)
	e1:SetOperation(c31563350.eqop)
	c:RegisterEffect(e1)
end
-- 检查并移除1个超量素材作为发动代价
function c31563350.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，筛选手牌中满足战士族、唯一性且未被禁止的怪兽
function c31563350.filter(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 判断是否满足发动条件：魔法陷阱区有空位且手牌中有符合条件的战士族怪兽
function c31563350.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断魔法陷阱区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断手牌中是否存在符合条件的战士族怪兽
		and Duel.IsExistingMatchingCard(c31563350.filter,tp,LOCATION_HAND,0,1,nil,tp) end
end
-- 处理装备效果的主函数，包括选择装备怪兽、装备、设置装备限制和攻击力加成
function c31563350.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若魔法陷阱区无空位则返回
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从手牌中选择1只符合条件的战士族怪兽
	local g=Duel.SelectMatchingCard(tp,c31563350.filter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将选中的怪兽装备给自身，若失败则返回
		if not Duel.Equip(tp,tc,c) then return end
		-- 为装备怪兽设置装备对象限制，确保只能被此怪兽装备
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c31563350.eqlimit)
		tc:RegisterEffect(e1)
		local atk=tc:GetTextAttack()
		if atk>0 then
			-- 为装备怪兽添加攻击力提升效果，提升值等于装备怪兽的攻击力
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
	end
end
-- 装备对象限制的判断函数，确保只能装备给自身
function c31563350.eqlimit(e,c)
	return e:GetOwner()==c
end
