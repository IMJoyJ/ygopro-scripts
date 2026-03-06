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
	-- 添加同调召唤手续，要求至少1只调整或光·暗属性怪兽作为素材，最多99只
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
-- 同调素材过滤器1：判断是否为调整或光·暗属性怪兽
function c22850702.matfilter1(c,syncard)
	return c:IsTuner(syncard) or c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 同调素材过滤器2：判断是否为非调整且光·暗属性怪兽
function c22850702.matfilter2(c,syncard)
	return c:IsNotTuner(syncard) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 效果处理时选择场上一张可除外的卡作为对象
function c22850702.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检查是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上一张可除外的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，记录将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行除外操作，将目标卡除外
function c22850702.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以正面表示形式除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 遍历同调素材，计算其原始属性的位或值并记录
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
-- 判断是否为同调召唤且有属性素材
function c22850702.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
		and e:GetLabelObject():GetLabel()~=0
end
-- 根据同调素材的属性，注册对应的效果
function c22850702.regop(e,tp,eg,ep,ev,re,r,rp)
	local att=e:GetLabelObject():GetLabel()
	local c=e:GetHandler()
	if bit.band(att,ATTRIBUTE_LIGHT)~=0 then
		-- 创建一个使己方同调怪兽不受对方怪兽效果影响的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		-- 设置该效果的目标为己方所有同调怪兽
		e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SYNCHRO))
		e1:SetValue(c22850702.efilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 刷新场上卡牌状态，使新注册的效果生效
		Duel.AdjustInstantly(c)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(22850702,0))  --"光属性怪兽为同调素材"
	end
	if bit.band(att,ATTRIBUTE_DARK)~=0 then
		-- 创建一个使己方怪兽不会被战斗破坏的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 刷新场上卡牌状态，使新注册的效果生效
		Duel.AdjustInstantly(c)
		c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(22850702,1))  --"暗属性怪兽为同调素材"
	end
end
-- 效果过滤器：判断是否为对方发动的怪兽效果
function c22850702.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer() and re:IsActivated()
		and re:IsActiveType(TYPE_MONSTER)
end
