--A宝玉獣 サファイア・ペガサス
-- 效果：
-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
-- ②：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组·墓地的怪兽以及除外的自己怪兽之中选1只「高等宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ③：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c71620241.initial_effect(c)
	-- 注册卡片关联密码，表示这张卡的效果中记有「高等暗黑结界」的卡号。
	aux.AddCodeList(c,12644061)
	-- 开启全局标记，以支持不入连锁的自我送墓效果。
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	-- ①：场地区域没有「高等暗黑结界」存在的场合这只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SELF_TOGRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(c71620241.tgcon)
	c:RegisterEffect(e1)
	-- ③：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(c71620241.repcon)
	e2:SetOperation(c71620241.repop)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。从自己的手卡·卡组·墓地的怪兽以及除外的自己怪兽之中选1只「高等宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(c71620241.target)
	e3:SetOperation(c71620241.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 自我送墓效果的条件函数。
function c71620241.tgcon(e)
	-- 检查场地区域是否存在「高等暗黑结界」，若不存在则满足送墓条件。
	return not Duel.IsEnvironment(12644061)
end
-- 替代送墓（当作永续魔法放置）效果的条件函数，检查是否在怪兽区域表侧表示被破坏。
function c71620241.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 替代送墓（当作永续魔法放置）效果的操作函数，将自身当作永续魔法卡使用。
function c71620241.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当作永续魔法卡使用
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择「高等宝玉兽」怪兽，且不能是禁止放置的卡，若在除外区则必须是表侧表示。
function c71620241.filter(c)
	return c:IsSetCard(0x5034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
-- 召唤·反转召唤·特殊召唤成功时发动效果的靶向/发动条件检查函数。
function c71620241.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否在怪兽区域，且自己的魔法与陷阱区域是否有空位。
	if chk==0 then return e:GetHandler():IsLocation(LOCATION_MZONE) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己的手卡、卡组、墓地、除外状态中是否存在至少1只满足条件的「高等宝玉兽」怪兽。
		and Duel.IsExistingMatchingCard(c71620241.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,1,nil) end
end
-- 召唤·反转召唤·特殊召唤成功时发动效果的操作函数。
function c71620241.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法与陷阱区域是否有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从手卡、卡组、墓地（受王家之谷影响）、除外状态中选择1只满足条件的「高等宝玉兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c71620241.filter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽表侧表示移动到自己的魔法与陷阱区域。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
