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
-- 过滤函数：判断卡片是否表侧表示且为指定种族（鱼族或鸟兽族）。
function c50074392.cfilter(c,rc)
	return c:IsFaceup() and c:IsRace(rc)
end
-- 特殊召唤的召唤条件：自己怪兽区有空格，且自己场上同时存在表侧表示的鱼族怪兽和鸟兽族怪兽时才能从手卡特殊召唤。
function c50074392.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否有可用的空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的鱼族怪兽。
		and Duel.IsExistingMatchingCard(c50074392.cfilter,tp,LOCATION_MZONE,0,1,nil,RACE_FISH)
		-- 检查自己场上是否存在表侧表示的鸟兽族怪兽。
		and Duel.IsExistingMatchingCard(c50074392.cfilter,tp,LOCATION_MZONE,0,1,nil,RACE_WINDBEAST)
end
-- 发动条件：确认这张卡是以自身效果从手卡特殊召唤的（特殊召唤成功时才能发动）。
function c50074392.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数：筛选表侧表示且持有等级的怪兽（作为等级变更的对象）。
function c50074392.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果的对象选择与等级宣言：确认自己场上存在持有等级的表侧表示怪兽后，让玩家宣言3到5的任意等级并记录。
function c50074392.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果能否发动的检查：自己场上存在至少1只表侧表示且持有等级的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c50074392.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择等级的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言从3到5的任意等级。
	local lv=Duel.AnnounceLevel(tp,3,5)
	e:SetLabel(lv)
end
-- 效果处理：把自己场上全部持有等级的表侧表示怪兽的等级变成宣言的等级，并注册本回合水属性以外的自己怪兽不能把效果发动的限制。
function c50074392.lvop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 取得自己场上全部表侧表示且持有等级的怪兽。
	local g=Duel.GetMatchingGroup(c50074392.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部怪兽的等级变成宣言的等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
	-- 这个效果发动过的回合，水属性以外的自己怪兽不能把效果发动。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	e2:SetTarget(c50074392.actfilter)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 把「水属性以外的自己怪兽不能把效果发动」的限制效果注册给该玩家，直到回合结束阶段。
	Duel.RegisterEffect(e2,tp)
end
-- 限制对象过滤：自己场上的水属性以外的怪兽。
function c50074392.actfilter(e,c)
	return c:GetControler()==e:GetHandlerPlayer() and c:IsType(TYPE_MONSTER) and c:IsNonAttribute(ATTRIBUTE_WATER)
end
