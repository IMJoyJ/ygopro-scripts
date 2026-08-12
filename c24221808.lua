--メンタルオーバー・デーモン
-- 效果：
-- 念动力族调整＋调整以外的念动力族怪兽2只以上
-- 1回合1次，可以选择自己墓地存在的1只念动力族怪兽从游戏中除外。这张卡从场上送去墓地时，这张卡的效果除外的怪兽尽可能在自己场上特殊召唤。
function c24221808.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整且为念动力族，以及2只以上调整以外的念动力族怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PSYCHO),aux.NonTuner(Card.IsRace,RACE_PSYCHO),2)
	c:EnableReviveLimit()
	-- 1回合1次，可以选择自己墓地存在的1只念动力族怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24221808,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c24221808.rmtg)
	e1:SetOperation(c24221808.rmop)
	c:RegisterEffect(e1)
	local sg=Group.CreateGroup()
	sg:KeepAlive()
	e1:SetLabelObject(sg)
	-- 这张卡从场上送去墓地时，这张卡的效果除外的怪兽尽可能在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24221808,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c24221808.spcon)
	e2:SetTarget(c24221808.sptg)
	e2:SetOperation(c24221808.spop)
	e2:SetLabelObject(sg)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的念动力族怪兽且可以除外的卡片
function c24221808.rmfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemove()
end
-- 设置除外效果的取对象处理，选择满足条件的墓地怪兽作为除外对象
function c24221808.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24221808.rmfilter(chkc) end
	-- 判断是否满足除外效果的发动条件，即场上存在满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c24221808.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的墓地怪兽作为除外对象
	local g=Duel.SelectTarget(tp,c24221808.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，记录将要除外的卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 执行除外操作，将目标怪兽除外并记录到效果对象组中
function c24221808.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且满足除外条件，执行除外操作
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_PSYCHO) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		if c:IsRelateToEffect(e) then
			local sg=e:GetLabelObject()
			if c:GetFlagEffect(24221808)==0 then
				sg:Clear()
				c:RegisterFlagEffect(24221808,RESET_EVENT+0x1680000,0,1)
			end
			sg:AddCard(tc)
			tc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD)
		end
	end
end
-- 判断该卡是否从场上送去墓地且拥有除外记录
function c24221808.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():GetFlagEffect(24221808)~=0
end
-- 设置特殊召唤效果的处理信息，准备召唤除外的怪兽
function c24221808.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，记录将要特殊召唤的卡片数量和来源
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 过滤满足特殊召唤条件的除外怪兽
function c24221808.spfilter(c,rc,e,tp)
	return c:IsRelateToCard(rc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行特殊召唤操作，将符合条件的除外怪兽特殊召唤到场上
function c24221808.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=g:Filter(c24221808.spfilter,nil,e:GetHandler(),e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=tg:Select(tp,ft,ft,nil)
	-- 将选择的卡片以特殊召唤方式送入场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
