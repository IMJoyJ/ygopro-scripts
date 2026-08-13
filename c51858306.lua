--エクリプス・ワイバーン
-- 效果：
-- ①：这张卡被送去墓地的场合发动。从卡组把1只光属性或者暗属性的龙族·7星以上的怪兽除外。
-- ②：墓地的这张卡被除外的场合才能发动。这张卡的①的效果除外的怪兽加入手卡。
function c51858306.initial_effect(c)
	-- ①：这张卡被送去墓地的场合发动。从卡组把1只光属性或者暗属性的龙族·7星以上的怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51858306,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c51858306.target)
	e1:SetOperation(c51858306.operation)
	c:RegisterEffect(e1)
	-- ②：墓地的这张卡被除外的场合才能发动。这张卡的①的效果除外的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51858306,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCondition(c51858306.thcon)
	e2:SetTarget(c51858306.thtg)
	e2:SetOperation(c51858306.thop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 效果发动条件判定：无发动条件限制（chk==0 时返回 true），并设置操作信息为从卡组除外1张卡。
function c51858306.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：从卡组除外1张卡，目标对象在效果处理时选择，因此 targets 设为 nil，目标持有者为 tp，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 定义可被①效果除外的怪兽的过滤条件：7星以上、龙族、光属性或暗属性、且可以被除外。
function c51858306.filter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsAbleToRemove()
end
-- ①效果实际处理：若玩家可以除外，则提示选择要除外的卡，从卡组中选出1只符合条件的怪兽，正面表示除外；随后将该怪兽记录到效果 e 的 LabelObject 中，并给日食翼龙自身和该怪兽各注册一个标识标记，用于②效果追踪这只怪兽。
function c51858306.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前玩家不能除外卡片，则效果处理直接中止。
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 给玩家显示选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己的卡组中选出1张满足 c51858306.filter 条件的怪兽（7星以上光/暗龙族），作为效果处理时除外的对象。
	local g=Duel.SelectMatchingCard(tp,c51858306.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧表示除外（由于是效果除外，reason 为 REASON_EFFECT）。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		e:SetLabelObject(tc)
		e:GetHandler():RegisterFlagEffect(51858306,RESET_EVENT+0x1e60000,0,1)
		tc:RegisterFlagEffect(51858306,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- ②效果的发动条件：这张卡（日食翼龙）当前表侧表示，且自身带有已用①效果除外过怪兽的标记。
function c51858306.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():GetFlagEffect(51858306)~=0
end
-- ②效果的发动判定：取得①效果记录的被除外怪兽 tc，若该怪兽仍带有标记且可以被加入手卡，则返回 true；然后在发动时设置操作信息为将 tc 加入手卡。
function c51858306.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetLabelObject()
	if chk==0 then return tc and tc:GetFlagEffect(51858306)~=0 and tc:IsAbleToHand() end
	-- 设置连锁操作信息：将对象怪兽 tc 加入手卡（目标确定，目标持有者暂填 0）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
-- ②效果处理：取得①效果记录的被除外怪兽，若该怪兽仍带有标记且成功返回手卡，则向对方玩家展示该怪兽。
function c51858306.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	-- 若该怪兽仍带有标记，并且通过效果成功加入手卡（返回数量不为0），则继续执行确认展示。
	if tc:GetFlagEffect(51858306)~=0 and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 将该怪兽展示给对方玩家确认（即公开手卡信息）。
		Duel.ConfirmCards(1-tp,tc)
	end
end
