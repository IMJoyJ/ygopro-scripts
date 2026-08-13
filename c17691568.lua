--Ga－P.U.N.K.クラッシュ・ビート
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己的「朋克」怪兽为对象的效果由对方发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。自己场上的全部「朋克」怪兽在这个回合不会成为对方的效果的对象，不会被对方的效果破坏。
function c17691568.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己的「朋克」怪兽为对象的效果由对方发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17691568,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,17691568)
	e2:SetCondition(c17691568.discon)
	e2:SetTarget(c17691568.distg)
	e2:SetOperation(c17691568.disop)
	c:RegisterEffect(e2)
	-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。自己场上的全部「朋克」怪兽在这个回合不会成为对方的效果的对象，不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17691568,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c17691568.limcon)
	e3:SetOperation(c17691568.limop)
	c:RegisterEffect(e3)
end
-- 判断卡片是否满足“自己的表侧表示的「朋克」怪兽”（用于检查对方效果的对象中是否存在己方朋克怪兽）。
function c17691568.acfilter(c,tp)
	return c:IsSetCard(0x171) and c:IsControler(tp) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- ①效果的发动条件：对方发动了以自己场上表侧「朋克」怪兽为对象的取对象效果，且该效果的对象中存在满足条件的怪兽时才可发动。
function c17691568.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取对方发动的连锁效果所选的对象卡片组，用于判断其中是否包含自己的朋克怪兽。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return rp==1-tp and tg and tg:IsExists(c17691568.acfilter,1,nil,tp)
end
-- ①效果发动时：选择对方场上1张卡作为对象（取对象），并设置破坏的操作信息；选择提示为“请选择要破坏的卡”。
function c17691568.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 效果发动前确认对方场上存在至少1张可作为对象的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示选择提示消息，内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息：本效果为破坏效果，对象为所选卡g，数量1，供其他卡（如星尘龙）检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理阶段：取得对象卡，若对象仍与效果关联（未离场/未被无效）则将其破坏。
function c17691568.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的第一个对象卡，即之前选择的对方场上的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果为原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断卡片是否为表侧表示的「朋克」怪兽，用于筛选自己场上的「朋克」怪兽。
function c17691568.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x171)
end
-- ②效果的发动条件：这张卡在魔法与陷阱区域被对方的效果破坏，并且自己场上有表侧「朋克」怪兽。
function c17691568.limcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE)
		-- 确认自己场上存在至少1张表侧「朋克」怪兽，作为②效果发动的附加条件。
		and Duel.GetMatchingGroupCount(c17691568.cfilter,tp,LOCATION_MZONE,0,nil)>0
end
-- ②效果处理：给自己场上所有表侧「朋克」怪兽赋予“不会成为对方效果对象”和“不会被对方效果破坏”的保护，持续到回合结束。
function c17691568.limop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有表侧「朋克」怪兽，作为②效果的保护对象。
	local g=Duel.GetMatchingGroup(c17691568.cfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部「朋克」怪兽在这个回合不会成为对方的效果的对象
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c17691568.tgval)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1,true)
		-- 不会被对方的效果破坏
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(17691568,2))  --"「雅乐朋克粉碎拍子」效果适用中"
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(c17691568.tgval)
		e2:SetOwnerPlayer(tp)
		tc:RegisterEffect(e2,true)
		tc=g:GetNext()
	end
end
-- 判断尝试生效/以怪兽为对象的效果是否来自对方（rp与效果所有者不同）；若来自对方则返回真，使“不能成为对象/不被效果破坏”的保护适用。
function c17691568.tgval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
