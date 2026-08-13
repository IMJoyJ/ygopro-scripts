--カオス・アンヘル－混沌の双翼－
-- 效果：
-- 调整＋调整以外的光·暗属性怪兽1只以上
-- 这张卡同调召唤的场合，可以把自己场上1只光·暗属性怪兽当作调整使用。
-- ①：这张卡特殊召唤的场合，以场上1张卡为对象才能发动。那张卡除外。
-- ②：这张卡得到作为这张卡的同调素材的怪兽的原本属性的以下效果。
-- ●光：自己场上的同调怪兽不受对方发动的怪兽的效果影响。
-- ●暗：自己怪兽不会被战斗破坏。
function c22850702.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加同调召唤手续：调整素材可以是调整怪兽，也可以是光·暗属性怪兽（即把光暗属性怪兽当作调整使用），并配合1~99只调整以外的光·暗属性怪兽作为非调整素材进行同调召唤。
	aux.AddSynchroMixProcedure(c,c22850702.matfilter1,nil,nil,c22850702.matfilter2,1,99)
	-- ①：这张卡特殊召唤的场合，以场上1张卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22850702,2))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c22850702.rmtg)
	e1:SetOperation(c22850702.rmop)
	c:RegisterEffect(e1)
	-- ②：这张卡得到作为这张卡的同调素材的怪兽的原本属性的以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c22850702.valcheck)
	c:RegisterEffect(e2)
	-- ●光：自己场上的同调怪兽不受对方发动的怪兽的效果影响。●暗：自己怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(c22850702.regcon)
	e3:SetOperation(c22850702.regop)
	c:RegisterEffect(e3)
	e3:SetLabelObject(e2)
end
-- 同调素材过滤器1：判定素材可以是调整怪兽，或者是光·暗属性怪兽（用于让光暗属性怪兽也能当作调整使用）。
function c22850702.matfilter1(c,syncard)
	return c:IsTuner(syncard) or c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 同调素材过滤器2：判定素材必须是调整以外的光·暗属性怪兽，即同调召唤中的非调整素材。
function c22850702.matfilter2(c,syncard)
	return c:IsNotTuner(syncard) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- ①效果的发动条件与选对象处理：选发、取对象，从场上选择1张可以除外的卡作为对象；若没有可除外的卡则不能发动。
function c22850702.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 效果发动的合法性检查：确认场上存在至少1张可以被除外的卡时，效果才能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从双方场上选择1张可以除外的卡，将其设为这个效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果将除外1张卡，供连锁处理与相关效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理时，取得对象卡，若对象仍与此效果关联，则将其除外。
function c22850702.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 收集这张卡同调召唤时使用的所有素材的原本属性，按位或合并后存入效果标签，用于后续判断是否拥有光/暗属性效果。
function c22850702.valcheck(e,c)
	local g=c:GetMaterial()
	local att=0
	local tc=g:GetFirst()
	while tc do
		att=bit.bor(att,tc:GetOriginalAttribute())
		tc=g:GetNext()
	end
	e:SetLabel(att)
end
-- 判定条件：这张卡是以同调召唤方式特殊召唤成功，且素材属性记录不为0（即使用了光或暗属性素材）。
function c22850702.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and e:GetLabelObject():GetLabel()~=0
end
-- 根据记录的素材属性注册对应保护效果：光属性让己方场上同调怪兽免疫对方发动的怪兽效果；暗属性让己方怪兽不被战斗破坏；并分别登记客户端提示。
function c22850702.regop(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if bit.band(att,ATTRIBUTE_LIGHT)~=0 then
		-- ●光：自己场上的同调怪兽不受对方发动的怪兽的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		-- 设定免疫效果仅对自己场上的同调怪兽适用。
		e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SYNCHRO))
		e1:SetValue(c22850702.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 手动刷新这张卡影响下的怪兽的状态，使新注册的光属性免疫效果立即实际生效。
		Duel.AdjustInstantly(c)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(22850702,0))  --"光属性怪兽为同调素材"
	end
	if bit.band(att,ATTRIBUTE_DARK)~=0 then
		-- ●暗：自己怪兽不会被战斗破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 手动刷新这张卡影响下的怪兽的状态，使新注册的暗属性战斗破坏免疫效果立即实际生效。
		Duel.AdjustInstantly(c)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(22850702,1))  --"暗属性怪兽为同调素材"
	end
end
-- 免疫效果的过滤条件：只免疫由对方发动的、已激活的怪兽卡效果。
function c22850702.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_MONSTER)
end
