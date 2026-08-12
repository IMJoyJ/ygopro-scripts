--白き森にはいるべからず
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有6星以上的幻想魔族或魔法师族的怪兽存在的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡牌的两个效果：①破坏对方场上一张卡；②被送去墓地时可盖放
function s.initial_effect(c)
	-- ①：自己场上有6星以上的幻想魔族或魔法师族的怪兽存在的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在6星以上且种族为魔法师族或幻想魔族的怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(6) and c:IsRace(RACE_SPELLCASTER+RACE_ILLUSION)
end
-- 判断是否满足效果①的发动条件：自己场上有6星以上的幻想魔族或魔法师族的怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动时点处理函数，设置目标选择和操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查是否满足效果①的目标选择条件：对方场上存在至少一张可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的一张卡作为破坏目标
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将要破坏目标卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的处理函数，执行破坏操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②的发动条件判断函数，判断是否因支付代價而被送去墓地且是怪兽效果发动
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- 效果②的发动时点处理函数，设置操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息，表示将要盖放此卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 效果②的处理函数，执行盖放操作
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否仍存在于场上（未被其他效果移除）并执行盖放
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
