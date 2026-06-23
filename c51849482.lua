--屍界塔フィニステラ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有10星怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合，以场上1张表侧表示卡为对象才能发动。这个回合，那张卡不会被效果破坏。
local s,id,o=GetID()
-- 注册两个效果，分别为①特殊召唤条件和②墓地触发效果
function s.initial_effect(c)
	-- ①：自己场上有10星怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以场上1张表侧表示卡为对象才能发动。这个回合，那张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(s.indestg)
	e2:SetOperation(s.indesop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于判断场上是否存在表侧表示的10星怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsLevel(10)
end
-- 判断特殊召唤条件是否满足：有空场且己方场上存在10星怪兽
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方主要怪兽区是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方场上是否存在至少1只10星的表侧表示怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义效果目标选择函数，用于选择场上一张表侧表示卡
function s.indestg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 判断是否满足选择目标的条件：场上存在至少1张表侧表示卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上一张表侧表示卡作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 定义效果处理函数，使目标卡在本回合内不会被效果破坏
function s.indesop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 设置目标卡获得不会被效果破坏的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
