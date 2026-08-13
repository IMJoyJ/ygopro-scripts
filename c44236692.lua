--ネクロ・リンカー
-- 效果：
-- 把这张卡解放，选择自己墓地存在的1只名字带有「同调士」的调整发动。选择的怪兽特殊召唤。这个效果特殊召唤的怪兽这个回合不能作为同调素材。
function c44236692.initial_effect(c)
	-- 把这张卡解放，选择自己墓地存在的1只名字带有「同调士」的调整发动。选择的怪兽特殊召唤。这个效果特殊召唤的怪兽这个回合不能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44236692,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c44236692.spcost)
	e1:SetTarget(c44236692.sptg)
	e1:SetOperation(c44236692.spop)
	c:RegisterEffect(e1)
end
-- 该函数处理发动代价：先检查这张卡能否被解放；若可以，则将其解放作为效果发动的代价。
function c44236692.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价解放（REASON_COST）将这张卡自身解放，作为发动效果的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 怪兽筛选条件：必须是名字带有「同调士」的调整怪兽，且能够通过此效果被特殊召唤。
function c44236692.filter(c,e,tp)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标判定：若指定对象则校验是否为自己墓地的符合条件的同调士调整；若为发动条件检查，则确认自己有空余主怪兽区（考虑解放自身后）且墓地存在至少1只符合条件的对象。
function c44236692.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c44236692.filter(chkc,e,tp) end
	-- 因为代价会解放这张卡并空出主怪兽区，所以当前主怪兽区空格数只要大于-1（即解放后至少有一个空位）即可满足发动条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己墓地是否存在1只满足c44236692.filter条件的同调士调整，且该卡可成为此效果的对象。
		and Duel.IsExistingTarget(c44236692.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示，等待选择特殊召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地中满足条件的同调士调整中选择1张，并将其登记为本效果的对象。
	local g=Duel.SelectTarget(tp,c44236692.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向连锁系统登记本次效果将对已选对象进行特殊召唤，供其他卡的效果判定参照。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：取得对象并确认仍与效果关联，将其表侧表示特殊召唤；若成功则给该怪兽附加这回合不能作为同调素材的负面影响。
function c44236692.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡片仍然与此效果关联（未中途离场等），然后将其表侧表示特殊召唤到己方场上；若特殊召唤成功则继续执行后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽这个回合不能作为同调素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
