--沈黙のサイコウィザード
-- 效果：
-- 这张卡召唤成功时，可以选择自己墓地存在的1只念动力族怪兽从游戏中除外。这张卡从场上送去墓地时，这张卡的效果除外的怪兽特殊召唤。
function c62950604.initial_effect(c)
	-- 这张卡召唤成功时，可以选择自己墓地存在的1只念动力族怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62950604,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c62950604.rmtg)
	e1:SetOperation(c62950604.rmop)
	c:RegisterEffect(e1)
	-- 这张卡从场上送去墓地时，这张卡的效果除外的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62950604,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c62950604.spcon)
	e2:SetTarget(c62950604.sptg)
	e2:SetOperation(c62950604.spop)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 过滤自己墓地中可以除外的念动力族怪兽
function c62950604.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemove()
end
-- 召唤成功时除外效果的发动准备（Target）
function c62950604.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c62950604.filter(chkc) end
	-- 检查自己墓地是否存在可以除外的念动力族怪兽
	if chk==0 then return Duel.IsExistingTarget(c62950604.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只念动力族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c62950604.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为：将选中的墓地卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 召唤成功时除外效果的执行（Operation），并为自身和除外怪兽添加标记以建立关联
function c62950604.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 若对象怪兽合法则将其表侧表示除外，并在自身也存在时为双方注册标记以建立关联
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_PSYCHO) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(62950604,RESET_EVENT+0x1680000,0,0)
		tc:RegisterFlagEffect(62950604,RESET_EVENT+RESETS_STANDARD,0,0)
		e:GetLabelObject():SetLabelObject(tc)
		e:GetLabelObject():SetLabel(1)
	end
end
-- 特殊召唤效果的发动条件：检查被除外的怪兽、标记状态，且自身是从场上送去墓地
function c62950604.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	local act=e:GetLabel()
	local c=e:GetHandler()
	e:SetLabel(0)
	return tc and act==1 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and c:GetFlagEffect(62950604)~=0
end
-- 特殊召唤效果的发动准备（Target）
function c62950604.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc:GetFlagEffect(62950604)~=0 end
	tc:CreateEffectRelation(e)
	-- 设置操作信息为：将该被除外的怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 特殊召唤效果的执行（Operation）
function c62950604.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) then
		-- 将该被除外的怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
