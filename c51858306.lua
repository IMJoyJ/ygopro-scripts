--エクリプス・ワイバーン
-- 效果：
-- ①：这张卡被送去墓地的场合发动。从卡组把1只光属性或者暗属性的龙族·7星以上的怪兽除外。
-- ②：墓地的这张卡被除外的场合才能发动。这张卡的①的效果除外的怪兽加入手卡。
function c51858306.initial_effect(c)
	-- 效果原文内容：①：这张卡被送去墓地的场合发动。从卡组把1只光属性或者暗属性的龙族·7星以上的怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51858306,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c51858306.target)
	e1:SetOperation(c51858306.operation)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：墓地的这张卡被除外的场合才能发动。这张卡的①的效果除外的怪兽加入手卡。
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
-- 效果作用：设置连锁操作信息，指定将要除外的卡片数量为1张，来自卡组。
function c51858306.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置当前处理的连锁的操作信息为除外效果，目标是玩家tp的卡组中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：定义过滤函数，用于筛选满足条件的怪兽（龙族、7星以上、光或暗属性且可除外）。
function c51858306.filter(c)
	return c:IsLevelAbove(7) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
		and c:IsAbleToRemove()
end
-- 效果作用：执行效果处理，选择并除外满足条件的1只怪兽，并记录该怪兽对象以供后续使用。
function c51858306.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：检查玩家是否可以除外卡片，若不可以则直接返回不执行效果。
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 效果作用：向玩家发送提示信息“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：从卡组中选择满足条件的1张怪兽卡作为除外目标。
	local g=Duel.SelectMatchingCard(tp,c51858306.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 效果作用：将选定的怪兽以正面表示的形式从游戏中除外，原因来自效果。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		e:SetLabelObject(tc)
		e:GetHandler():RegisterFlagEffect(51858306,RESET_EVENT+0x1e60000,0,1)
		tc:RegisterFlagEffect(51858306,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
-- 效果作用：判断是否满足发动条件（卡片在场且已执行过①的效果）。
function c51858306.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():GetFlagEffect(51858306)~=0
end
-- 效果作用：设置连锁操作信息，指定将要加入手卡的卡片为之前除外的那张怪兽。
function c51858306.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetLabelObject()
	if chk==0 then return tc and tc:GetFlagEffect(51858306)~=0 and tc:IsAbleToHand() end
	-- 效果作用：设置当前处理的连锁的操作信息为回手牌效果，目标是特定的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
-- 效果作用：执行效果处理，将之前除外的怪兽送入持有者的手卡，并确认对方可见。
function c51858306.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	-- 效果作用：检查该怪兽是否曾被①的效果除外过，并判断能否将其送入手卡。
	if tc:GetFlagEffect(51858306)~=0 and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 效果作用：向对方玩家展示被送入手卡的卡片内容
		Duel.ConfirmCards(1-tp,tc)
	end
end
