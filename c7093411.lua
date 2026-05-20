--宝玉獣 サファイア・ペガサス
-- 效果：
-- ①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从自己的手卡·卡组·墓地选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c7093411.initial_effect(c)
	-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(c7093411.repcon)
	e1:SetOperation(c7093411.repop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从自己的手卡·卡组·墓地选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7093411,1))  --"放置魔法陷阱区"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetTarget(c7093411.target)
	e2:SetOperation(c7093411.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 检查自身是否在怪兽区域表侧表示被破坏
function c7093411.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 在被破坏送去墓地时，将自身作为永续魔法卡在自己的魔法与陷阱区域表侧表示放置
function c7093411.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end
-- 过滤自己手卡、卡组、墓地中可以放置的「宝玉兽」怪兽卡
function c7093411.filter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 确认自己手卡、卡组、墓地是否存在「宝玉兽」怪兽，且自己的魔法与陷阱区域有空位
function c7093411.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡、卡组、墓地是否存在可以放置的「宝玉兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c7093411.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
		-- 检查自己的魔法与陷阱区域是否有可用的空格
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 从自己的手卡、卡组、墓地选择1只「宝玉兽」怪兽，作为永续魔法卡在自己的魔法与陷阱区域表侧表示放置
function c7093411.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己的魔法与陷阱区域没有空位，则效果不适用
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向玩家发送提示，要求选择要放置到场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从自己的手卡、卡组、墓地中选择1张满足条件的「宝玉兽」怪兽（适用墓地相关效果的无效化检测）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c7093411.filter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡片表侧表示移动到自己的魔法与陷阱区域
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续魔法卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
