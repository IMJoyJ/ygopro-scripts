--ボーン・デーモン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，从自己的手卡·场上把这张卡以外的1张卡送去墓地才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤。
-- ②：以自己场上1只表侧表示怪兽为对象才能发动。从手卡·卡组把1只恶魔族调整送去墓地，作为对象的怪兽的等级上升或下降1星。
local s,id,o=GetID()
-- 创建两个效果，分别对应①②效果
function s.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，从自己的手卡·场上把这张卡以外的1张卡送去墓地才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是龙族·暗属性同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只表侧表示怪兽为对象才能发动。从手卡·卡组把1只恶魔族调整送去墓地，作为对象的怪兽的等级上升或下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 定义costfilter函数，用于检查是否满足送去墓地的条件（能送去墓地且场上还有怪兽区）
function s.costfilter(c,tp)
	-- 返回卡能送去墓地且场上还有怪兽区
	return c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的费用处理函数，检查是否有满足条件的卡并选择送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否有满足costfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡并将其送去墓地
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的发动后处理函数，检查是否能特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的发动处理函数，执行特殊召唤并设置限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建并注册限制效果，禁止在回合结束前特殊召唤非龙族·暗属性同调怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册限制效果到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判断函数，禁止特殊召唤非龙族·暗属性同调怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
		and not (c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_SYNCHRO))
end
-- 定义filter函数，用于检查是否为表侧表示且等级大于等于1的怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 定义tgfilter函数，用于检查是否为恶魔族调整且能送去墓地
function s.tgfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER) and c:IsAbleToGrave()
end
-- ②效果的目标选择函数，检查是否有满足条件的怪兽和恶魔族调整
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查是否有满足filter条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否有满足tgfilter条件的恶魔族调整
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示将要送去墓地恶魔族调整
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果的发动处理函数，选择恶魔族调整送去墓地并调整目标怪兽等级
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取满足tgfilter条件的恶魔族调整
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if #g==0 then return end
	-- 提示玩家选择要送去墓地的恶魔族调整
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tg=g:Select(tp,1,1,nil):GetFirst()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断是否成功将恶魔族调整送去墓地
	if Duel.SendtoGrave(tg,REASON_EFFECT)>0 and tg:IsLocation(LOCATION_GRAVE)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local sel=0
		local lvl=1
		if tc:IsLevel(1) then
			-- 选择等级上升
			sel=Duel.SelectOption(tp,aux.Stringid(id,1))  --"等级上升"
		else
			-- 选择等级上升或下降
			sel=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"等级上升/等级下降"
		end
		if sel==1 then
			lvl=-1
		end
		-- 创建并注册等级调整效果到目标怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
