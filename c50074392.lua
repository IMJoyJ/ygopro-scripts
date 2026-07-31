--霊水鳥シレーヌ・オルカ
-- 效果：
-- 自己场上有鱼族以及鸟兽族怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功时，宣言从3到5的任意等级才能发动。自己场上的全部怪兽的等级变成宣言的等级。这个效果发动过的回合，水属性以外的自己怪兽不能把效果发动。
function c50074392.initial_effect(c)
	-- 自己场上有鱼族以及鸟兽族怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c50074392.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 这个方法特殊召唤成功时，宣言从3到5的任意等级才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50074392,0))  --"等级变化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c50074392.lvcon)
	e2:SetTarget(c50074392.lvtg)
	e2:SetOperation(c50074392.lvop)
	c:RegisterEffect(e2)
end
-- 检查场上是否存在指定种族的表侧表示怪兽。
function c50074392.cfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
-- 判断特殊召唤条件是否满足：手牌玩家场上存在鱼族和鸟兽族怪兽且有空场。
function c50074392.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断手牌玩家场上是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌玩家场上是否存在至少1只鱼族表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c50074392.cfilter,tp,LOCATION_MZONE,0,1,nil,RACE_FISH)
		-- 判断手牌玩家场上是否存在至少1只鸟兽族表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c50074392.cfilter,tp,LOCATION_MZONE,0,1,nil,RACE_WINDBEAST)
end
-- 确认该卡是通过特殊召唤方式出场的。
function c50074392.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 筛选场上所有表侧表示且等级大于0的怪兽。
function c50074392.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 选择并宣言一个3到5之间的等级作为目标等级。
function c50074392.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：场上存在至少1只表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c50074392.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家进行等级选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家从3到5中宣言一个等级。
	local lv=Duel.AnnounceLevel(tp,3,5)
	e:SetLabel(lv)
end
-- 将场上所有怪兽的等级调整为宣言的等级，并设置水属性以外的自己怪兽不能发动效果。
function c50074392.lvop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 获取场上所有满足条件的表侧表示怪兽组成一组。
	local g=Duel.GetMatchingGroup(c50074392.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为每个怪兽设置等级变更效果，使其等级变为宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 设置一个区域效果，使水属性以外的自己怪兽不能发动效果。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	e2:SetTarget(c50074392.actfilter)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册给对应玩家。
	Duel.RegisterEffect(e2,tp)
end
-- 判断目标怪兽是否为水属性以外的自己怪兽。
function c50074392.actfilter(e,c)
	return c:GetControler()==e:GetHandlerPlayer() and c:IsType(TYPE_MONSTER) and c:IsNonAttribute(ATTRIBUTE_WATER)
end
