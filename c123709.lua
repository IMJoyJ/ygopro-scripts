--ラヴァル・ランスロッド
-- 效果：
-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡在结束阶段时送去墓地。场上存在的这张卡被破坏送去墓地时，可以选择从游戏中除外的1只自己的炎属性怪兽加入手卡。
function c123709.initial_effect(c)
	-- 这张卡可以不用解放作召唤。这个方法召唤的这张卡在结束阶段时送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(123709,0))  --"不用解放召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c123709.ntcon)
	e1:SetOperation(c123709.ntop)
	c:RegisterEffect(e1)
	-- 场上存在的这张卡被破坏送去墓地时，可以选择从游戏中除外的1只自己的炎属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(123709,2))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c123709.condition)
	e2:SetTarget(c123709.target)
	e2:SetOperation(c123709.operation)
	c:RegisterEffect(e2)
end
-- 无解放召唤规则的条件函数：c为nil时表示可以提交该召唤方式；实际召唤时要求无需解放（minc==0）、这张卡等级在5以上且其控制者场上主要怪兽区有空位。
function c123709.ntcon(e,c,minc)
	if c==nil then return true end
	-- 返回只需满足无解放（minc==0）、该怪兽等级为5星以上且其控制者主要怪兽区有空位即可进行无解放召唤。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 无解放召唤成功时执行的操作：为这张卡在场上注册一个结束阶段必定触发的效果，使其在结束阶段被送去墓地。
function c123709.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法召唤的这张卡在结束阶段时送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(123709,1))  --"这张卡送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(c123709.tgcon)
	e1:SetTarget(c123709.tgtg)
	e1:SetOperation(c123709.tgop)
	e1:SetReset(RESET_EVENT+0xee0000)
	c:RegisterEffect(e1)
end
-- 送墓效果触发条件：仅当当前回合玩家是这张卡效果的控制者（即这张卡无解放召唤的同一回合的结束阶段）时才生效。
function c123709.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为效果控制者，以限定结束阶段送墓效果只在该回合结束阶段处理。
	return tp==Duel.GetTurnPlayer()
end
-- 送墓效果的目标设定：该效果不需要选择对象，发动时直接返回true，并登记效果处理时的送墓操作信息。
function c123709.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将这张卡自身以“送去墓地”的效果分类（CATEGORY_TOGRAVE）写入连锁，便于相关卡响应。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
-- 送墓效果的实际处理：若这张卡仍与效果关联且表侧表示，则将其送去墓地。
function c123709.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 以效果原因（REASON_EFFECT）将这张卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end
-- 诱发效果发动条件：这张卡被破坏后送去墓地，且被破坏前位于场上（之前位置为场上区域）。
function c123709.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 选择对象的过滤条件：选择除外区中表侧表示、炎属性、并且能够加入手卡的怪兽。
function c123709.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
-- 诱发效果的目标选择处理：发动时从自己除外区选取1张符合条件的炎属性怪兽作为对象，并登记加入手卡的操作信息；若没选对象时检查是否存在可对应的目标，连锁时校验对象是否合法。
function c123709.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c123709.filter(chkc) end
	-- 发动时判断：自己的除外区是否存在至少1张符合条件的炎属性怪兽，作为能否发动的依据。
	if chk==0 then return Duel.IsExistingTarget(c123709.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向控制者显示“请选择要加入手牌的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让控制者从自己的除外区选择1张符合条件的炎属性怪兽作为效果对象，并把它登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c123709.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 登记操作信息：将选中的目标卡以“加入手卡”的效果分类（CATEGORY_TOHAND）写入连锁，便于相关卡响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取出效果对象，确认它仍与效果关联且仍表侧表示、炎属性后，将其加入手卡，并向对方揭示。
function c123709.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的第一个对象卡（本效果只选择1张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_FIRE) then
		-- 将对象卡加入其持有者的手卡，加入原因视为效果（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认这张加入手卡的卡，公开其信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
