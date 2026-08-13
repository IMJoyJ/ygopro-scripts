--メンタルオーバー・デーモン
-- 效果：
-- 念动力族调整＋调整以外的念动力族怪兽2只以上
-- 1回合1次，可以选择自己墓地存在的1只念动力族怪兽从游戏中除外。这张卡从场上送去墓地时，这张卡的效果除外的怪兽尽可能在自己场上特殊召唤。
function c24221808.initial_effect(c)
	-- 为这张卡设置同调召唤手续：需要1只念动力族调整怪兽作为调整，加上2只以上调整以外的念动力族怪兽作为素材。
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
-- 定义“除外”效果的可选对象：选择自己墓地中种族为念动力族且可以除外的怪兽。
function c24221808.rmfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemove()
end
-- 处理“除外”效果发动时的取对象环节：确认自己墓地有1只符合条件的念动力族怪兽后，提示玩家选择1只，并设置除外操作信息。
function c24221808.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24221808.rmfilter(chkc) end
	-- 在效果发动合法性检查时，确认自己墓地是否存在至少1只符合条件的念动力族怪兽可作为对象；若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c24221808.rmfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示，用于引导选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足条件的念动力族怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c24221808.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为‘除外墓地1张卡’，供其他卡的效果检测（如星尘龙、王家长眠之谷等）参考。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- ‘除外’效果处理：从墓地除外选中怪兽；若除外成功且本卡仍与效果关联，则把该怪兽加入效果标签组，并为本卡设置标记曾发动过除外（flag 24221808），同时建立本卡与该怪兽的关联，供之后复活使用。
function c24221808.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的除外对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽仍与效果关联、仍为念动力族、确实已被除外且位于除外区，并且本卡仍与效果关联；满足条件才继续记录这次除外。
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
-- 触发特殊召唤的条件：本卡从场上被送去墓地，并且之前已通过自身效果除外过念动力族怪兽（持有标记24221808）。
function c24221808.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():GetFlagEffect(24221808)~=0
end
-- 特殊召唤效果的发动条件：效果发动合法，并设置操作信息为从除外区进行特殊召唤。
function c24221808.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为‘从除外区特殊召唤1只怪兽’，供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 从之前被本卡除外的怪兽中，筛选出仍与这张卡有关联且能够被正常特殊召唤的怪兽。
function c24221808.spfilter(c,rc,e,tp)
	return c:IsRelateToCard(rc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤的效果处理：从记录的被除外怪兽中取得可召目标，计算可用怪兽区空格；若无空格或无目标则结束；若青眼精灵龙效果适用（双方不能同时特殊召唤2只以上怪兽），则最多特召1只；选择相应数量的怪兽以表侧攻击表示特殊召唤到自己场上。
function c24221808.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	-- 计算自己场上可用的怪兽区空格数，决定本次特殊召唤的最大数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tg=g:Filter(c24221808.spfilter,nil,e:GetHandler(),e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家显示‘请选择要特殊召唤的卡’的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=tg:Select(tp,ft,ft,nil)
	-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上；此处不使用特殊召唤手续，且需正常检查召唤条件与苏生限制。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
