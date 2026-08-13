--幻獣機コンコルーダ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 只要这张卡在场上表侧表示存在，自己场上的衍生物不会被战斗以及效果破坏。场上的这张卡被对方破坏送去墓地的场合，把自己场上的衍生物全部解放才能发动。从自己墓地选择1只4星以下的名字带有「幻兽机」的怪兽特殊召唤。
function c53451824.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整怪兽为任意1只（nil表示不限制），调整以外的怪兽为任意1只（aux.NonTuner(nil)表示调整以外无其他限制），合计至少1只调整以外的怪兽，作为同调素材使用。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，自己场上的衍生物不会被战斗以及效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置这个保护效果的作用对象：仅适用于自己场上的衍生物（Token）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_TOKEN))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- 场上的这张卡被对方破坏送去墓地的场合，把自己场上的衍生物全部解放才能发动。从自己墓地选择1只4星以下的名字带有「幻兽机」的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53451824,0))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c53451824.spcon)
	e3:SetCost(c53451824.spcost)
	e3:SetTarget(c53451824.sptg)
	e3:SetOperation(c53451824.spop)
	c:RegisterEffect(e3)
end
-- 诱发条件判定：这张卡之前位于场上，是被对方（1-tp）用破坏的原因送去墓地，且之前控制者是这张卡的效果发动者tp；满足这些条件时效果才能发动。
function c53451824.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 效果发动代价处理：收集自己场上所有衍生物，记录数量用于后续空位检查；若存在衍生物且全部可解放，则将它们全部解放作为代价。
function c53451824.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有衍生物（类型为Token）的集合。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_TOKEN)
	e:SetLabel(g:GetCount())
	if chk==0 then return g:GetCount()>0 and g:FilterCount(Card.IsReleasable,nil)==g:GetCount() end
	-- 将当前自己场上所有衍生物全部解放，作为发动效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 定义可选择特殊召唤的怪兽的过滤条件：必须是名字带有「幻兽机」的怪兽、等级4以下，并且可以被玩家tp特殊召唤。
function c53451824.spfilter(c,e,tp)
	return c:IsSetCard(0x101b) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标的选择与合法性检查：若是在确认选择对象阶段（chkc），检查该卡是否位于自己墓地且满足幻兽机特殊召唤条件；若是效果发动确认阶段（chk==0），则检查解放衍生物后场上是否有足够空位，以及自己墓地是否存在至少1只符合条件的幻兽机。
function c53451824.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c53451824.spfilter(chkc,e,tp) end
	-- 检查解放衍生物后是否还有足够的怪兽区域空位来特殊召唤怪兽（用之前记录的衍生物数量e:GetLabel()计算解放后腾出的格子数）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-e:GetLabel()+1
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的名字带有「幻兽机」的怪兽，可作为效果对象。
		and Duel.IsExistingTarget(c53451824.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择卡片的提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的满足条件的幻兽机中选择1只作为效果对象。
	local g=Duel.SelectTarget(tp,c53451824.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本连锁的操作信息，声明这个效果将进行特殊召唤，并登记对象卡及数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理：取得效果对象，若对象仍然与效果相关，则将其以表侧表示特殊召唤到持有者（tp）的场上。
function c53451824.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将选择的那只「幻兽机」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
