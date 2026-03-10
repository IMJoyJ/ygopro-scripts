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
	-- 这个方法特殊召唤成功时，宣言从3到5的任意等级才能发动。自己场上的全部怪兽的等级变成宣言的等级。这个效果发动过的回合，水属性以外的自己怪兽不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50074392,0))  --"等级变化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c50074392.lvcon)
	e2:SetTarget(c50074392.lvtg)
	e2:SetOperation(c50074392.lvop)
	c:RegisterEffect(e2)
end
-- 用于判断场上是否存在指定种族的表侧表示怪兽。
function c50074392.cfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
-- 检查自己场上是否同时存在鱼族和鸟兽族怪兽，并且有空场。
function c50074392.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只鱼族表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c50074392.cfilter,tp,LOCATION_MZONE,0,1,nil,RACE_FISH)
		-- 检查自己场上是否存在至少1只鸟兽族表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c50074392.cfilter,tp,LOCATION_MZONE,0,1,nil,RACE_WINDBEAST)
end
-- 确认该卡是通过特殊召唤方式出场的。
function c50074392.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 用于筛选场上所有表侧表示且等级大于0的怪兽。
function c50074392.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 选择并宣言一个3到5之间的等级作为目标等级。
function c50074392.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即自己场上存在至少1只表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c50074392.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家进行等级宣言。
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	-- 让玩家从3到5中宣言一个等级。
	local lv=Duel.AnnounceLevel(tp,3,5)
	e:SetLabel(lv)
end
-- 将场上所有怪兽的等级设置为宣言的等级，并禁止水属性以外的自己怪兽发动效果。
function c50074392.lvop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 获取场上所有满足条件的怪兽组成一个组。
	local g=Duel.GetMatchingGroup(c50074392.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 将目标怪兽的等级修改为宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 禁止水属性以外的自己怪兽在该回合发动效果。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	e2:SetTarget(c50074392.actfilter)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使水属性以外的自己怪兽不能发动效果。
	Duel.RegisterEffect(e2,tp)
end
-- 用于判断是否为水属性以外的自己怪兽。
function c50074392.actfilter(e,c)
	return c:GetControler()==e:GetHandlerPlayer() and c:IsType(TYPE_MONSTER) and c:IsNonAttribute(ATTRIBUTE_WATER)
end
