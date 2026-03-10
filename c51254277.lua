--ビッグ・ジョーズ
-- 效果：
-- 这张卡攻击的场合，战斗阶段结束时从游戏中除外。
function c51254277.initial_effect(c)
	-- 这张卡攻击的场合，战斗阶段结束时从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(c51254277.regop)
	c:RegisterEffect(e1)
end
-- 在攻击宣言时发动，将一个战斗阶段结束时除外的效果注册到自己身上。
function c51254277.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 战斗阶段结束时发动，将自己除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(51254277,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetCountLimit(1)
	e1:SetTarget(c51254277.rmtg)
	e1:SetOperation(c51254277.rmop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	e:GetHandler():RegisterEffect(e1)
end
-- 设置效果处理时需要确定要除外的卡。
function c51254277.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息为除外效果。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 执行除外操作，将该卡从游戏中除外。
function c51254277.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 以效果为原因，正面表示除外该卡。
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	end
end
