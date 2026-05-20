--TG レシプロ・ドラゴン・フライ
-- 效果：
-- 调整＋调整以外的怪兽1只
-- ①：1回合1次，以自己场上1只其他的「科技属」同调怪兽为对象才能发动。那只怪兽送去墓地。那之后，若作为送去墓地的那只怪兽的同调召唤的素材用过的一组怪兽全部是同调怪兽并在自己墓地齐集，可以把那一组特殊召唤。
function c62560742.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- ①：1回合1次，以自己场上1只其他的「科技属」同调怪兽为对象才能发动。那只怪兽送去墓地。那之后，若作为送去墓地的那只怪兽的同调召唤的素材用过的一组怪兽全部是同调怪兽并在自己墓地齐集，可以把那一组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62560742,0))  --"同调解除"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c62560742.target)
	e1:SetOperation(c62560742.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的「科技属」同调怪兽。
function c62560742.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x27) and c:IsType(TYPE_SYNCHRO)
end
-- 效果①的发动准备：检查并选择自己场上1只其他的「科技属」同调怪兽作为对象，并设置操作信息。
function c62560742.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c62560742.filter(chkc) end
	-- 检查自己场上是否存在除自身以外的、可以作为效果对象的表侧表示「科技属」同调怪兽。
	if chk==0 then return Duel.IsExistingTarget(c62560742.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择1只「科技属」同调怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(62560742,2))  --"请选择1只「科技属」同调怪兽"
	-- 选择自己场上1只其他的「科技属」同调怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c62560742.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置操作信息：将选中的怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 过滤条件：作为同调素材在墓地齐集、且全部是同调怪兽，并且可以被特殊召唤。
function c62560742.mgfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_SYNCHRO)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的效果处理：将对象怪兽送去墓地，若满足条件则可以把作为其同调素材的一组同调怪兽特殊召唤。
function c62560742.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local mg=tc:GetMaterial()
	local ct=mg:GetCount()
	local sumtype=tc:GetSummonType()
	-- 成功将对象怪兽送去墓地，且该怪兽是通过同调召唤方式特殊召唤的。
	if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and sumtype==SUMMON_TYPE_SYNCHRO
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and ct>0 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域空位数是否足够容纳那一组同调素材。
		and ct<=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 确认作为同调素材的一组怪兽是否全部是同调怪兽，且全部在自己墓地齐集（不受「王家长眠之谷」影响）并可以特殊召唤。
		and mg:FilterCount(aux.NecroValleyFilter(c62560742.mgfilter),nil,e,tp,tc)==ct
		-- 询问玩家是否选择将那一组同调素材特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(62560742,1)) then  --"是否要把素材特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤处理与送去墓地不视为同时进行（防止错时点）。
		Duel.BreakEffect()
		-- 将作为同调素材的一组怪兽在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	end
end
