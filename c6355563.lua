--Y－ドラゴン・イアヘッド
-- 效果：
-- ①：这张卡特殊召唤的场合才能发动。从自己的手卡·墓地把1只机械族·光属性·4星怪兽当作装备魔法卡使用给这张卡装备。这个回合，自己不是光属性怪兽不能从额外卡组特殊召唤。
-- ②：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只机械族怪兽为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：启用同盟怪兽属性，并注册特殊召唤成功时发动的装备效果。
function s.initial_effect(c)
	-- 启用同盟怪兽的标准机制，并设置可装备的怪兽过滤条件。
	aux.EnableUnionAttribute(c,s.filter)
	-- ①：这张卡特殊召唤的场合才能发动。从自己的手卡·墓地把1只机械族·光属性·4星怪兽当作装备魔法卡使用给这张卡装备。这个回合，自己不是光属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"装备效果"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上的机械族怪兽（用于同盟装备限制）。
function s.filter(c)
	return c:IsRace(RACE_MACHINE)
end
-- 过滤条件：手卡·墓地中满足等级4、光属性、机械族，且可以当作装备卡装备的怪兽。
function s.eqfilter(c,tc,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4)
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 效果①的发动准备与合法性检测（检查手卡·墓地是否有符合条件的怪兽，以及魔法与陷阱区域是否有空位）。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡或墓地是否存在至少1只满足装备条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c,tp)
		-- 检查自己的魔法与陷阱区域是否有可用的空位。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 设置连锁处理的操作信息：从手卡或墓地将1张卡装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的效果处理：将手卡·墓地的怪兽装备给这张卡，并适用本回合不能从额外卡组特殊召唤光属性以外怪兽的限制。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍在场上表侧表示存在，且魔法与陷阱区域是否有空位。
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 玩家从手卡或墓地选择1只满足条件的怪兽（适用王家长眠之谷的过滤）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c,tp)
		local sc=g:GetFirst()
		-- 若成功选出怪兽，则将其作为装备卡装备给这张卡。
		if sc and Duel.Equip(tp,sc,c) then
			-- 当作装备魔法卡使用给这张卡装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(c)
			e1:SetValue(s.eqlimit)
			sc:RegisterEffect(e1)
		end
	end
	-- 这个回合，自己不是光属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该玩家的特殊召唤限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤光属性以外的怪兽。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLocation(LOCATION_EXTRA)
end
-- 装备限制：只能装备给作为装备对象的这张卡。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
