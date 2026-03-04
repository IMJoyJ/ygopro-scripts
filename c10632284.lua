--ミメシスエレファント
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡发动后变成效果怪兽（兽族·地·2星·攻0/守2000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ②：这张卡在怪兽区域存在的场合，自己·对方回合，宣言种族和属性各1个，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时变成宣言的种族·属性。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（兽族·地·2星·攻0/守2000）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的场合，自己·对方回合，宣言种族和属性各1个，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到回合结束时变成宣言的种族·属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetTarget(s.artg)
	e2:SetOperation(s.arop)
	c:RegisterEffect(e2)
end
-- 效果处理目标函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定参数的怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,2,RACE_BEAST,ATTRIBUTE_EARTH) end
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果发动处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查玩家是否可以特殊召唤指定参数的怪兽
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,0,2000,2,RACE_BEAST,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
-- 筛选目标函数
function s.filter(c,r,a)
	return c:IsFaceup() and not (c:IsRace(r) and c:IsAttribute(a))
end
-- 效果处理目标函数
function s.artg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,e:GetLabel()) end
	-- 检查是否存在满足条件的场上表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	-- 让玩家宣言一个种族
	local rac=Duel.AnnounceRace(tp,1,RACE_ALL)
	-- 提示玩家选择属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	-- 让玩家宣言一个属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(rac,att)
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择一个满足条件的场上表侧表示怪兽作为目标
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理发动函数
function s.arop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		local r,a=e:GetLabel()
		-- 使目标怪兽变成宣言的种族
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(r)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽变成宣言的属性
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(a)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
