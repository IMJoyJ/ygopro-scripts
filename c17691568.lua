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
	-- ①：自己的「朋克」怪兽为对象的效果由对方发动的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
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
-- 过滤函数，用于判断是否为己方的「朋克」怪兽（正面表示）
function c17691568.acfilter(c,tp)
	return c:IsSetCard(0x171) and c:IsControler(tp) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 效果发动条件判断函数，判断是否为对方发动的、以己方「朋克」怪兽为对象的效果
function c17691568.discon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return rp==1-tp and tg and tg:IsExists(c17691568.acfilter,1,nil,tp)
end
-- 效果发动时的处理函数，选择对方场上的1张卡作为破坏对象
function c17691568.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断是否满足发动条件，即对方场上是否存在可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，将选中的卡破坏
function c17691568.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断是否为「朋克」怪兽（正面表示）
function c17691568.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x171)
end
-- 效果发动条件判断函数，判断是否为对方破坏此卡的场合
function c17691568.limcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE)
		-- 判断己方场上是否存在「朋克」怪兽
		and Duel.GetMatchingGroupCount(c17691568.cfilter,tp,LOCATION_MZONE,0,nil)>0
end
-- 效果处理函数，使己方场上的「朋克」怪兽在本回合内不会成为对方效果的对象，也不会被对方效果破坏
function c17691568.limop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取己方场上的所有「朋克」怪兽
	local g=Duel.GetMatchingGroup(c17691568.cfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 给己方场上的「朋克」怪兽添加效果，使其不能成为对方效果的对象
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c17691568.tgval)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1,true)
		-- 给己方场上的「朋克」怪兽添加效果，使其不会被对方效果破坏
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
-- 返回值函数，用于判断效果是否生效
function c17691568.tgval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
