--Z－ジリオン・キャタピラー
-- 效果：
-- ①：这张卡特殊召唤的场合才能发动。自己的除外状态的1只机械族·光属性·4星怪兽当作装备魔法卡使用给这张卡装备。这个回合，自己不是光属性怪兽不能从额外卡组特殊召唤。
-- ②：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只机械族怪兽为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片的同盟怪兽效果，包括装备、装备限制、装备发动和装备状态特殊召唤等机制
function s.initial_effect(c)
	-- 为卡片赋予同盟怪兽机制，使其可以作为装备卡使用并具有相关效果
	aux.EnableUnionAttribute(c,s.filter)
	-- ①：这张卡特殊召唤的场合才能发动。自己的除外状态的1只机械族·光属性·4星怪兽当作装备魔法卡使用给这张卡装备。
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
-- 定义卡片可以装备的怪兽种族为机械族
function s.filter(c)
	return c:IsRace(RACE_MACHINE)
end
-- 筛选满足条件的除外状态的机械族光属性4星怪兽作为装备卡
function s.eqfilter(c,tc,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4) and c:IsFaceupEx()
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 设置装备效果的发动条件，判断是否能选择符合条件的除外怪兽并确保场上存在装备空间
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否能从除外区选择符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_REMOVED,0,1,nil,c,tp)
		-- 判断场上是否有足够的装备区域
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 设置装备效果的操作信息，指定将要装备的卡来自除外区
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_REMOVED)
end
-- 执行装备操作，选择并装备符合条件的除外怪兽到自身上，并设置装备限制效果
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断装备卡是否有效且场上存在装备空间
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从除外区选择一张符合条件的怪兽进行装备
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_REMOVED,0,1,1,nil,c,tp)
		local sc=g:GetFirst()
		-- 执行装备动作并将装备限制效果注册到被装备的怪兽上
		if sc and Duel.Equip(tp,sc,c) then
			-- 装备对象限制效果，确保只有装备卡自身可以装备到该怪兽上
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
	-- ①：这张卡特殊召唤的场合才能发动。自己的除外状态的1只机械族·光属性·4星怪兽当作装备魔法卡使用给这张卡装备。这个回合，自己不是光属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤的效果注册到玩家场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制非光属性怪兽从额外卡组特殊召唤
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLocation(LOCATION_EXTRA)
end
-- 装备对象限制函数，确保只有装备卡自身可以装备到该怪兽上
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
