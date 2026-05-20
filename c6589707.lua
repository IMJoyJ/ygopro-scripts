--地中界の厄災
-- 效果：
-- ①：自己场上的里侧守备表示怪兽不会成为对方的效果的对象。
-- ②：只要这张卡在魔法与陷阱区域存在，让在这张卡表侧表示存在期间反转过的自己场上的怪兽的攻击力·守备力上升1500。
-- ③：魔法与陷阱区域的这张卡被对方的效果破坏的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含：①里侧怪兽对象抗性，②反转怪兽攻防上升，③魔陷区被破坏时墓地怪兽里侧特召。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：自己场上的里侧守备表示怪兽不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置抗性效果的影响对象为自己场上的里侧表示怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsFacedown))
	-- 设置不会成为对方卡的效果的对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，让在这张卡表侧表示存在期间反转过的自己场上的怪兽的攻击力·守备力上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.fliptg)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在魔法与陷阱区域存在，让在这张卡表侧表示存在期间反转过的自己场上的怪兽的攻击力·守备力上升1500。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FLIP)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetOperation(s.flipop)
	c:RegisterEffect(e4)
	local ng=Group.CreateGroup()
	ng:KeepAlive()
	e2:SetLabelObject(ng)
	e3:SetLabelObject(ng)
	e4:SetLabelObject(ng)
	-- ③：魔法与陷阱区域的这张卡被对方的效果破坏的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
-- 重置函数，若这张卡重新表侧表示存在，则清空之前记录的反转怪兽组，并重新注册标记。
function s.reset(e)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	if c:GetFlagEffectLabel(id)~=fid then
		e:GetLabelObject():Clear()
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	end
end
-- 反转事件的处理函数，将反转的怪兽加入记录组并添加标记。
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	s.reset(e)
	local ng=e:GetLabelObject()
	local tc=eg:GetFirst()
	while tc do
		ng:AddCard(tc)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		tc=eg:GetNext()
	end
end
-- 攻防上升效果的过滤函数，判断怪兽是否在当前这张卡表侧表示期间反转过。
function s.fliptg(e,c)
	s.reset(e)
	return c:GetFlagEffect(id)>0 and e:GetLabelObject():IsContains(c)
end
-- 判定效果③的发动条件：魔法与陷阱区域的这张卡被对方的效果破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE)
end
-- 过滤可以里侧守备表示特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果③的发动准备与目标选择（Target）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在可以里侧守备表示特殊召唤的怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息，包含特殊召唤分类和目标卡片。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的效果处理（将对象怪兽里侧守备表示特殊召唤，并向对方确认）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其里侧守备表示特殊召唤。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 让对方玩家确认被里侧特殊召唤的怪兽。
		Duel.ConfirmCards(1-tp,tc)
	end
end
