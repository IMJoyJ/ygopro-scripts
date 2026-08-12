--幻獣機コンコルーダ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 只要这张卡在场上表侧表示存在，自己场上的衍生物不会被战斗以及效果破坏。场上的这张卡被对方破坏送去墓地的场合，把自己场上的衍生物全部解放才能发动。从自己墓地选择1只4星以下的名字带有「幻兽机」的怪兽特殊召唤。
function c53451824.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，自己场上的衍生物不会被战斗以及效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置效果影响的目标为衍生物（TYPE_TOKEN）
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
-- 检查发动条件：这张卡之前在场地上且因破坏送去墓地，且被对方玩家破坏
function c53451824.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
-- 效果代价处理：获取自己场上所有衍生物并全部解放作为发动代价
function c53451824.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有衍生物（TYPE_TOKEN）组成的卡片组
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_TOKEN)
	e:SetLabel(g:GetCount())
	if chk==0 then return g:GetCount()>0 and g:FilterCount(Card.IsReleasable,nil)==g:GetCount() end
	-- 将获取的衍生物全部解放作为效果发动的代价（REASON_COST）
	Duel.Release(g,REASON_COST)
end
-- 定义过滤函数：检查卡片是否为「幻兽机」系列、4星以下且可以被特殊召唤
function c53451824.spfilter(c,e,tp)
	return c:IsSetCard(0x101b) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标处理：检查场地空间及墓地是否存在符合条件的「幻兽机」怪兽
function c53451824.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c53451824.spfilter(chkc,e,tp) end
	-- 检查特殊召唤前场地空间：计算解放衍生物后剩余的可用怪兽区域数量
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-e:GetLabel()+1
		-- 检查自己墓地是否存在符合条件的「幻兽机」怪兽作为效果对象
		and Duel.IsExistingTarget(c53451824.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示信息：请选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1只符合条件的「幻兽机」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c53451824.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：特殊召唤分类，对象为目标卡片，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的墓地怪兽特殊召唤到自己场上
function c53451824.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（之前选择的目标卡片）
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示形式特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
