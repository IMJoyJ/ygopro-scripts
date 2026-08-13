--ビッグ・ジョーズ
-- 效果：
-- 这张卡攻击的场合，战斗阶段结束时从游戏中除外。
function c51254277.initial_effect(c)
	-- 这张卡攻击的场合。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(c51254277.regop)
	c:RegisterEffect(e1)
end
-- 攻击宣言时，为这张卡注册一个战斗阶段结束时发动的强制除外效果：创建效果对象并设置其种类、事件代码和操作函数，最后注册到这张卡上。
function c51254277.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 战斗阶段结束时从游戏中除外。
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
-- 除外效果的发动条件处理：无条件允许发动，并初步设定除外对象为本卡（该卡在伤害步骤后战斗阶段结束时仍需要在场且表侧表示才实际除外）。
function c51254277.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次除外的操作信息：将除外分类、对象（本卡）和数量写入连锁信息，用于后续效果处理及部分卡片对除外效果的响应判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 除外效果的实际处理：检查本卡仍与该效果关联且为表侧表示时，将其从游戏中除外。
function c51254277.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 以表侧表示形式、效果原因将本卡从游戏中除外。
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	end
end
