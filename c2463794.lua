--刻まれし魔の鎮魂棺
-- 效果：
-- 恶魔族·光属性怪兽1只
-- 自己对「刻魔的镇魂棺」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，把这张卡解放才能发动。从手卡·卡组把1只「刻魔」怪兽特殊召唤。
-- ②：以连接怪兽以外的自己场上1只恶魔族·光属性怪兽为对象才能发动。从自己的场上·墓地把这张卡当作攻击力上升600的装备魔法卡使用给那只自己怪兽装备。
local s,id,o=GetID()
-- 初始化效果，设置该卡的特殊召唤限制、连接召唤手续、启用复活限制，并注册两个效果
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- 为该卡添加连接召唤手续，要求使用1~1个满足过滤条件的恶魔族·光属性怪兽作为连接素材
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	c:EnableReviveLimit()
	-- ①：自己·对方的主要阶段，把这张卡解放才能发动。从手卡·卡组把1只「刻魔」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以连接怪兽以外的自己场上1只恶魔族·光属性怪兽为对象才能发动。从自己的场上·墓地把这张卡当作攻击力上升600的装备魔法卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 连接召唤的过滤函数，筛选满足恶魔族且光属性的怪兽
function s.mfilter(c)
	return c:IsLinkRace(RACE_FIEND) and c:IsLinkAttribute(ATTRIBUTE_LIGHT)
end
-- 判断是否处于主要阶段1或主要阶段2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 特殊召唤效果的费用处理，检查是否可以解放此卡并确保场上存在空位
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以解放此卡并确保场上存在空位
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 执行解放操作
	Duel.Release(c,REASON_COST)
end
-- 特殊召唤目标的过滤函数，筛选「刻魔」怪兽且可特殊召唤
function s.filter(c,e,tp)
	return c:IsSetCard(0x1b0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标设定，检查是否存在满足条件的「刻魔」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「刻魔」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤1只「刻魔」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 特殊召唤效果的处理，选择并特殊召唤符合条件的怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「刻魔」怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 装备效果的目标过滤函数，筛选场上正面表示的恶魔族·光属性非连接怪兽
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsType(TYPE_LINK)
end
-- 装备效果的目标设定，检查场上是否存在满足条件的怪兽
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	-- 检查场上是否有足够的魔法区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的怪兽作为装备对象
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示将装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息，表示将此卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 装备效果的处理，将此卡装备给目标怪兽并设置装备限制和攻击力加成
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp) then
		-- 检查装备条件是否满足，包括魔法区域是否足够、目标怪兽是否正面表示、是否为己方控制、是否在怪兽区
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or not tc:IsLocation(LOCATION_MZONE) then
			-- 若装备条件不满足则将此卡送入墓地
			Duel.SendtoGrave(c,REASON_EFFECT)
			return
		end
		-- 尝试将此卡装备给目标怪兽
		if not Duel.Equip(tp,c,tc) then return end
		-- 设置装备限制效果，确保此卡只能装备给指定怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置装备后攻击力上升600的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(600)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制的判断函数，确保只能装备给指定目标怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
