--十二獣ライカ
-- 效果：
-- 4星怪兽×2只以上
-- 「十二兽 狗环」1回合1次也能在同名卡以外的自己场上的「十二兽」怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「十二兽」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能作为超量召唤的素材。
function c41375811.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,2,c41375811.ovfilter,aux.Stringid(41375811,0),99,c41375811.xyzop)  --"是否在「十二兽」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c41375811.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c41375811.defval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「十二兽」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合效果无效化，不能作为超量召唤的素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41375811,1))  --"自己墓地「十二兽」怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c41375811.spcost)
	e3:SetTarget(c41375811.sptg)
	e3:SetOperation(c41375811.spop)
	c:RegisterEffect(e3)
end
-- 判断可作为重叠对象的怪兽：必须是表侧表示、属于「十二兽」字段，且卡名不是「十二兽 狗环」，即满足『同名卡以外的自己场上的「十二兽」怪兽』的条件。
function c41375811.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and not c:IsCode(41375811)
end
-- 「十二兽 狗环」在「十二兽」怪兽上重叠进行超量召唤的特殊手续：先检查本回合是否已使用过该召唤方式，若未使用则执行并注册1回合1次的誓约标记。
function c41375811.xyzop(e,tp,chk)
	-- 发动时检查：当前玩家tp本回合尚未使用过「十二兽 狗环」在「十二兽」怪兽上重叠超量召唤的次数（誓约标记为0）。
	if chk==0 then return Duel.GetFlagEffect(tp,41375811)==0 end
	-- 登记本回合已使用过『在「十二兽」怪兽上重叠超量召唤』的誓约标记，该标记在结束阶段重置，用于限制1回合1次。
	Duel.RegisterFlagEffect(tp,41375811,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 筛选超量素材中属于「十二兽」字段且攻击力数值有效（>=0）的怪兽，用于计算攻击力上升值。
function c41375811.atkfilter(c)
	return c:IsSetCard(0xf1) and c:GetAttack()>=0
end
-- 计算这张卡的攻击力上升数值：取这张卡作为超量素材中的所有「十二兽」怪兽的攻击力合计值。
function c41375811.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c41375811.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
-- 筛选超量素材中属于「十二兽」字段且守备力数值有效（>=0）的怪兽，用于计算守备力上升值。
function c41375811.deffilter(c)
	return c:IsSetCard(0xf1) and c:GetDefense()>=0
end
-- 计算这张卡的守备力上升数值：取这张卡作为超量素材中的所有「十二兽」怪兽的守备力合计值。
function c41375811.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c41375811.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end
-- ②效果的发动代价：从这张卡取除1个超量素材（chk=0时只检查能否取除，chk=1时实际取除）。
function c41375811.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 筛选可作为②效果对象的墓地怪兽：属于「十二兽」字段且能够被特殊召唤（即满足苏生限制）。
function c41375811.spfilter(c,e,tp)
	return c:IsSetCard(0xf1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件判定与对象选择：检查自己主要怪兽区有空位且墓地存在符合条件的「十二兽」怪兽；发动时向对方提示效果，并选择自己墓地1只「十二兽」怪兽作为对象，同时设置本次操作信息为特殊召唤。
function c41375811.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41375811.spfilter(chkc,e,tp) end
	-- 发动时检查：自己主要怪兽区存在空位，且自己墓地存在至少1只符合条件的「十二兽」怪兽，才能发动②。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c41375811.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向对方玩家提示已发动/选择了这个效果（显示效果描述），以便对方确认。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 给发动玩家显示『请选择要特殊召唤的卡』的选择提示框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家从自己墓地选择1只符合条件的「十二兽」怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c41375811.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息为特殊召唤1只怪兽（供后续发动检测如星尘龙、王家长眠之谷等使用）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将对象怪兽以表侧表示特殊召唤；若成功，则给那只怪兽赋予『效果无效化』和『不能作为超量召唤素材』的状态。
function c41375811.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。若对象已不存在或与效果失去关联，则后续特殊召唤不进行。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联后，将其以表侧表示特殊召唤（作为连续特殊召唤的一步），只有召唤成功才继续附加无效化等效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽在这个回合效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
	end
	-- 完成连续特殊召唤处理，确认特殊召唤成功，触发特殊召唤成功时点。
	Duel.SpecialSummonComplete()
end
