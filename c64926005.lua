--氷結界の武士
-- 效果：
-- ①：表侧攻击表示的这张卡变成守备表示的场合发动。这张卡破坏，自己抽1张。
function c64926005.initial_effect(c)
	-- ①：表侧攻击表示的这张卡变成守备表示的场合发动。这张卡破坏，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64926005,0))  --"破坏并抽卡"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCondition(c64926005.condition)
	e1:SetTarget(c64926005.target)
	e1:SetOperation(c64926005.operation)
	c:RegisterEffect(e1)
end
-- 检查此卡是否由表侧攻击表示变为了表侧守备表示
function c64926005.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP_ATTACK) and c:IsPosition(POS_FACEUP_DEFENSE)
end
-- 效果发动的靶向处理，由于是必发效果直接返回true，并设置破坏与抽卡的操作信息
function c64926005.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置抽1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理的执行函数，若此卡仍与效果有关联则将其破坏，破坏成功则让玩家抽1张卡
function c64926005.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否与效果有关联，并尝试以效果原因破坏此卡，若成功破坏则执行后续处理
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 让发动效果的玩家因效果抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
