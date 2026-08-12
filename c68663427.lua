--リンカーネイト・アンヴェイル・メイル
-- 效果：
-- 这个卡名在规则上也当作「铠装超量」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：这张卡装备的超量怪兽得到以下效果。
-- ●这张卡不会被战斗破坏。
-- ●这张卡进行过战斗的自己·对方回合才能发动1次。这张卡1张装备卡回到手卡。那之后，进行1只水属性超量怪兽的超量召唤。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。这张卡给自己场上1只超量怪兽装备。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 注册装备魔法的标准发动效果，可以装备给场上表侧表示的怪兽。
	aux.AddEquipSpellEffect(c,true,true,Card.IsFaceup,nil)
	-- ●这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.ibcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ●这张卡进行过战斗的自己·对方回合才能发动1次。这张卡1张装备卡回到手卡。那之后，进行1只水属性超量怪兽的超量召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"超量召唤（转生显形铠）"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.xyzcon)
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	-- ①：这张卡装备的超量怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ①：这张卡装备的超量怪兽得到以下效果。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetCode(EFFECT_ADD_TYPE)
	e6:SetCondition(s.addcon)
	e6:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e6)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。这张卡给自己场上1只超量怪兽装备。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"装备效果"
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCondition(s.eqcon)
	e5:SetTarget(s.eqtg)
	e5:SetOperation(s.eqop)
	c:RegisterEffect(e5)
end
-- 战斗不可破坏效果的允许条件：装备怪兽是超量怪兽且未被无效。
function s.ibcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec:IsType(TYPE_XYZ) and not ec:IsDisabled()
end
-- 赋予效果怪兽种类的条件：装备怪兽原本不是效果怪兽。
function s.addcon(e)
	return not e:GetHandler():IsType(TYPE_EFFECT)
end
-- 赋予效果的发动条件：装备怪兽进行过战斗。
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 过滤可以回到手牌的装备卡：属于该装备怪兽的装备卡且可以回到手牌。
function s.thfilter(c,ec)
	return c:IsAbleToHand() and c:IsType(TYPE_EQUIP) and ec:GetEquipGroup():IsContains(c)
end
-- 过滤可以进行超量召唤的水属性超量怪兽。
function s.xyzfilter(c)
	return c:IsXyzSummonable(nil) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 赋予效果的发动准备与合法性检测。
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可以回到手牌的装备卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e:GetHandler())
		-- 检查额外卡组是否存在可以进行超量召唤的水属性超量怪兽。
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 获取场上所有可以回到手牌的装备卡组。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e:GetHandler())
	-- 向对方玩家提示发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁信息：包含将1张装备卡送回手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置连锁信息：包含从额外卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 赋予效果的执行逻辑：将装备卡送回手牌，并进行水属性超量召唤。
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择1张要回到手牌的装备卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e:GetHandler())
	local tc=g:GetFirst()
	-- 将选中的装备卡送回手牌，若成功送回手牌则继续处理。
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取额外卡组中所有可以进行超量召唤的水属性超量怪兽。
		local xg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
		if xg:GetCount()>0 then
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=xg:Select(tp,1,1,nil)
			-- 对选中的怪兽进行超量召唤。
			Duel.XyzSummon(tp,tg:GetFirst(),nil)
		end
	end
end
-- 过滤获得效果的对象：装备了这张卡的超量怪兽。
function s.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:GetEquipGroup():IsContains(e:GetHandler())
		and c:IsType(TYPE_XYZ)
end
-- 在送去墓地的回合注册一个持续到回合结束的标记。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 墓地装备效果的发动条件：本回合被送去过墓地。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 墓地装备效果的发动准备与合法性检测。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以装备此卡的超量怪兽。
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,nil,c,tp) end
	-- 设置连锁信息：包含装备此卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 设置连锁信息：包含此卡离开墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 过滤可以装备此卡的怪兽：自己场上表侧表示的超量怪兽，且此卡可以合法装备。
function s.eqfilter(c,ec,tp)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
		and ec:CheckEquipTarget(c) and ec:CheckUniqueOnField(tp,LOCATION_SZONE) and not ec:IsForbidden()
end
-- 墓地装备效果的执行逻辑：选择自己场上1只超量怪兽，将此卡作为装备卡装备。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler()
	-- 检查此卡是否仍存在于墓地（且不受王家之谷影响）以及魔陷区是否有空位。
	if ec:IsRelateToEffect(e) and aux.NecroValleyFilter()(ec) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否仍存在合法的装备目标。
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,nil,ec,tp) then
		-- 提示玩家选择要装备的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 玩家选择1只自己场上的超量怪兽。
		local tg=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil,ec,tp)
		-- 选中目标怪兽并显示选择动画。
		Duel.HintSelection(tg)
		-- 将此卡装备给选中的怪兽。
		Duel.Equip(tp,ec,tg:GetFirst())
	end
end
