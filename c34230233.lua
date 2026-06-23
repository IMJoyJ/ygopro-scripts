--暗黒界の龍神 グラファ
-- 效果：
-- ①：这张卡可以让「暗黑界的龙神 格拉法」以外的自己场上1只「暗黑界」怪兽回到持有者手卡，从墓地特殊召唤。
-- ②：这张卡被效果从手卡丢弃去墓地的场合，以对方场上1张卡为对象发动。那张对方的卡破坏。被对方的效果丢弃的场合，再把对方手卡随机选1张确认。那是怪兽的场合，可以把那只怪兽在自己场上特殊召唤。
function c34230233.initial_effect(c)
	-- ①：这张卡可以让「暗黑界的龙神 格拉法」以外的自己场上1只「暗黑界」怪兽回到持有者手卡，从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c34230233.spcon)
	e1:SetTarget(c34230233.sptg)
	e1:SetOperation(c34230233.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果从手卡丢弃去墓地的场合，以对方场上1张卡为对象发动。那张对方的卡破坏。被对方的效果丢弃的场合，再把对方手卡随机选1张确认。那是怪兽的场合，可以把那只怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34230233,0))  --"对方场上存在的1张卡破坏"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c34230233.descon)
	e2:SetTarget(c34230233.destg)
	e2:SetOperation(c34230233.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的「暗黑界」怪兽（非格拉法且可送入手牌作为费用）
function c34230233.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x6) and not c:IsCode(34230233) and c:IsAbleToHandAsCost()
		-- 检查目标怪兽所在玩家场上是否有足够的怪兽区域（用于特殊召唤）
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤的条件函数，检查是否有满足条件的怪兽可以送入手牌
function c34230233.spcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查场上是否存在满足条件的怪兽（用于特殊召唤）
	return Duel.IsExistingMatchingCard(c34230233.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤的目标选择函数，选择要送入手牌的怪兽
function c34230233.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的怪兽组（用于特殊召唤）
	local g=Duel.GetMatchingGroup(c34230233.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 提示玩家选择要送入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤的操作函数，将选中的怪兽送入手牌
function c34230233.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将目标怪兽送入手牌（作为特殊召唤的代价）
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 破坏效果的触发条件函数，判断是否为从手牌丢弃至墓地
function c34230233.descon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- 破坏效果的目标选择函数，选择对方场上的卡作为破坏对象
function c34230233.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，确定破坏效果影响的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if rp==1-tp and tp==e:GetLabel() then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	else
		e:SetCategory(CATEGORY_DESTROY)
	end
end
-- 破坏效果的操作函数，执行破坏并可能触发后续特殊召唤
function c34230233.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效并执行破坏操作
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and rp==1-tp and tp==e:GetLabel() then
		-- 中断当前效果，使后续处理错开时点
		Duel.BreakEffect()
		-- 获取对方手牌组
		local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if hg:GetCount()>0 then
			local cg=hg:RandomSelect(tp,1)
			local cc=cg:GetFirst()
			-- 确认对方手牌中的一张卡
			Duel.ConfirmCards(tp,cc)
			-- 检查是否有足够的怪兽区域用于特殊召唤
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and cc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 询问玩家是否要特殊召唤该怪兽
				and Duel.SelectYesNo(tp,aux.Stringid(34230233,1)) then  --"是否要特殊召唤？"
				-- 将确认的怪兽特殊召唤到场上
				Duel.SpecialSummon(cc,0,tp,tp,false,false,POS_FACEUP)
			-- 若不选择特殊召唤，则洗切对方手牌
			else Duel.ShuffleHand(1-tp) end
		end
	end
end
