--雷仙人
-- 效果：
-- 反转：基本分回复3000。这张卡从场上送去墓地的时候，基本分失去5000分。
function c84926738.initial_effect(c)
	-- 反转：基本分回复3000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84926738,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c84926738.flipop)
	c:RegisterEffect(e1)
	-- 这张卡从场上送去墓地的时候，基本分失去5000分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84926738,1))  --"LP失去"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetTarget(c84926738.lptg)
	e2:SetOperation(c84926738.lpop)
	c:RegisterEffect(e2)
end
-- 反转效果处理：回复3000基本分，并在该卡处于怪兽区域或墓地时为其注册一个标识效果，用于后续判定是否是从场上送去墓地。
function c84926738.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 回复玩家3000基本分。
	Duel.Recover(tp,3000,REASON_EFFECT)
	if c:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) then
		c:RegisterFlagEffect(84926738,RESET_EVENT+0x57a0000,0,0)
	end
end
-- 送去墓地效果的发动条件判定：确认该卡是否带有反转时注册的标识效果（即是否曾反转过且从场上送去墓地）。
function c84926738.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(84926738)~=0 end
end
-- 送去墓地效果处理：使玩家的基本分减少5000。
function c84926738.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 将玩家的当前基本分减少5000。
	Duel.SetLP(tp,Duel.GetLP(tp)-5000)
end
