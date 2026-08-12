--彷徨える幽霊船
-- 效果：
-- 不死族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己的墓地·除外状态的1只5星以上的不死族怪兽为对象才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置，作为对象的怪兽特殊召唤。
-- ②：这张卡是当作永续魔法卡使用的场合，以自己场上1只5星以上的不死族怪兽为对象才能发动。持有那只怪兽的攻击力以下的攻击力的对方场上1只怪兽破坏。
local s,id,o=GetID()
-- 初始化效果，注册连接召唤手续、①效果（特殊召唤/放置魔陷区）和②效果（破坏怪兽）
function s.initial_effect(c)
	-- 添加连接召唤手续：不死族怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),2,2)
	c:EnableReviveLimit()
	-- ①：以自己的墓地·除外状态的1只5星以上的不死族怪兽为对象才能发动。这张卡当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置，作为对象的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
	-- ②：这张卡是当作永续魔法卡使用的场合，以自己场上1只5星以上的不死族怪兽为对象才能发动。持有那只怪兽的攻击力以下的攻击力的对方场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏怪兽"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地或除外状态的5星以上且可以特殊召唤的不死族怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsLevelAbove(5) and c:IsRace(RACE_ZOMBIE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与合法性检测（检查是否存在合法的对象、怪兽区域和魔陷区域是否有空位）
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	-- 检查自己的墓地或除外状态是否存在至少1只满足条件的5星以上不死族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
		-- 检查在这张卡离开场上后，自己场上是否有可用的怪兽区域用于特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查自己的魔法与陷阱区域是否有空位用于放置这张卡
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地或除外状态的1只5星以上的不死族怪兽作为对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁信息，表示该效果包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理：将这张卡作为永续魔法卡在魔陷区表侧表示放置，并将作为对象的怪兽特殊召唤
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为特殊召唤对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查这张卡是否仍与效果相关，并将其表侧表示移动到自己的魔法与陷阱区域
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		and c:IsLocation(LOCATION_SZONE) then
		-- 这张卡当作永续魔法卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
		-- 检查作为对象的怪兽是否仍与效果相关，且不受王家长眠之谷的影响
		if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
			-- 将作为对象的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- ②效果的发动条件：这张卡是当作永续魔法卡使用的场合
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end
-- 过滤自己场上表侧表示的5星以上不死族怪兽，且对方场上存在攻击力在其数值以下的怪兽
function s.tgfilter(c,tp)
	return c:IsFaceup() and c:IsLevelAbove(5) and c:IsRace(RACE_ZOMBIE)
		-- 检查对方场上是否存在攻击力在选定怪兽攻击力以下的怪兽
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 过滤对方场上表侧表示且攻击力在指定数值以下的怪兽
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- ②效果的发动准备与合法性检测（选择自己场上1只5星以上的不死族怪兽作为对象，并设置破坏信息）
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,tp) end
	-- 检查自己场上是否存在符合条件的5星以上不死族怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择作为效果对象的自己场上的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只5星以上的不死族怪兽作为对象
	local tg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	if tg then
		-- 获取对方场上所有攻击力在作为对象的怪兽攻击力以下的怪兽组
		local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,tg:GetAttack())
		-- 设置连锁信息，表示该效果包含破坏对方场上1只怪兽的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	end
end
-- ②效果的处理：选择并破坏持有作为对象的怪兽攻击力以下的攻击力的对方场上1只怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的自己场上的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上1只持有作为对象的怪兽攻击力以下攻击力的怪兽
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
		if #g>0 then
			-- 选中要破坏的怪兽并显示选择动画
			Duel.HintSelection(g)
			-- 破坏选择的对方怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
