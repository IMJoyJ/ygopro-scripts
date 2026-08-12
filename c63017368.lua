--石版の神殿
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。那之后，把1只「千年」怪兽从卡组当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：自己场上的表侧表示的「千年」怪兽被战斗·效果破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 初始化效果：注册卡片发动、主要阶段放置怪兽效果，以及赋予场上「千年」怪兽被破坏时转为永续魔法放置的效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己主要阶段才能发动。从手卡把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。那之后，把1只「千年」怪兽从卡组当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"放置怪兽"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- 可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(s.repcon)
	e3:SetOperation(s.repop)
	-- ②：自己场上的表侧表示的「千年」怪兽被战斗·效果破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.eftg)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
-- 过滤条件：手卡中的怪兽卡且未被限制放置
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 过滤条件：卡组中的「千年」怪兽卡且未被限制放置
function s.setfilter(c)
	return c:IsSetCard(0x1ae) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ①效果的发动准备：检查手卡和卡组中是否存在符合条件的怪兽，且魔法与陷阱区域有2个以上的空位
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在怪兽，以及卡组中是否存在「千年」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查魔法与陷阱区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>1 end
end
-- ①效果的处理：先从手卡将1只怪兽作为永续魔法放置，然后从卡组将1只「千年」怪兽作为永续魔法放置
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若魔法与陷阱区域没有空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从手卡选择1只怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	if #g==0 then return end
	local tc=g:GetFirst()
	if tc then
		-- 将选择的手卡怪兽表侧表示移动到魔法与陷阱区域
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续魔法卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
		tc:SetStatus(STATUS_EFFECT_ENABLED,true)
	end
	-- 若魔法与陷阱区域没有空位，则不处理后续效果
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 中断当前效果，使之后的效果处理视为不同时处理
	Duel.BreakEffect()
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组选择1只「千年」怪兽
	local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local stc=sg:GetFirst()
	if stc then
		-- 将选择的卡组怪兽表侧表示移动到魔法与陷阱区域
		Duel.MoveToField(stc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续魔法卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		stc:RegisterEffect(e1)
		stc:SetStatus(STATUS_EFFECT_ENABLED,true)
	end
end
-- 代替破坏的条件：自己场上的表侧表示怪兽因破坏而送去墓地
function s.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 代替破坏的处理：将该怪兽作为永续魔法卡在魔法与陷阱区域表侧表示放置
function s.repop(e,tp,eg,ep,ev,re,r,rp)
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
-- 过滤条件：适用于自己场上的「千年」怪兽
function s.eftg(e,c)
	return c:IsSetCard(0x1ae)
end
