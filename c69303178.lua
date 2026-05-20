--光神機－桜火
-- 效果：
-- 这张卡可以不用祭品作召唤。这个方法召唤的场合，这张卡在结束阶段时送去墓地。
function c69303178.initial_effect(c)
	-- 这张卡可以不用祭品作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69303178,0))  --"不用祭品召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c69303178.ntcon)
	e1:SetOperation(c69303178.ntop)
	c:RegisterEffect(e1)
end
-- 不用祭品召唤的条件判断函数
function c69303178.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足不用祭品召唤的条件（等级5以上、怪兽区域有空位）
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 不用祭品召唤成功时的操作函数，在此处注册结束阶段送去墓地的效果
function c69303178.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法召唤的场合，这张卡在结束阶段时送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69303178,1))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetTarget(c69303178.tgtg)
	e1:SetOperation(c69303178.tgop)
	e1:SetReset(RESET_EVENT+0xc6e0000)
	c:RegisterEffect(e1)
end
-- 结束阶段送去墓地效果的发动准备与目标确认
function c69303178.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，将自身送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 结束阶段送去墓地效果的执行逻辑
function c69303178.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身因效果送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
