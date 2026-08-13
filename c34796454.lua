--三連星のトリオン
-- 效果：
-- 这张卡作为上级召唤的解放送去墓地的回合的结束阶段时，这张卡可以从墓地特殊召唤。
function c34796454.initial_effect(c)
	-- 这张卡作为上级召唤的解放送去墓地的
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetOperation(c34796454.regop)
	c:RegisterEffect(e1)
end
-- 当此卡被送去墓地时，检查其送墓原因是否同时包含召唤和素材相关原因（即作为上级召唤的解放），若满足则在墓地内为这张卡注册一个在结束阶段发动的特殊召唤效果
function c34796454.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_SUMMON) and c:IsReason(REASON_MATERIAL) then
		-- 回合的结束阶段时，这张卡可以从墓地特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(34796454,0))  --"特殊召唤"
		e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c34796454.sptg)
		e1:SetOperation(c34796454.spop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤效果的发动条件：检查自己主要怪兽区是否有空位，以及此卡是否满足特殊召唤条件
function c34796454.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己主要怪兽区是否存在可用空格，若没有空格则效果不能发动
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次效果处理将进行的特殊召唤操作，以便后续处理与其他效果连锁时参考
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，确认该卡仍与当前效果关联后执行特殊召唤；若已不关联则中止处理
function c34796454.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 无视召唤条件和苏生限制，将该卡以表侧表示特殊召唤到其持有者（tp）的场上
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end
