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
-- 作为特殊召唤COST的候选怪兽过滤器：要求该怪兽表侧表示、属于「暗黑界」字段、不是格拉法自身、可作为COST返回手牌，并且该卡离开后自己场上仍有空余怪兽区。
function c34230233.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x6) and not c:IsCode(34230233) and c:IsAbleToHandAsCost()
		-- 额外要求：将候选怪兽返回手牌后，自己场上仍有足够的怪兽区空格用于格拉法的特殊召唤。
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件判定：若格拉法受王家长眠之谷影响则不能从墓地特殊召唤；否则检查自己场上是否存在至少1只满足spfilter条件的「暗黑界」怪兽可作为返回手牌的COST。
function c34230233.spcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足spfilter条件的「暗黑界」怪兽（表侧、可作为COST回手、非格拉法、回手后有空位），作为从墓地特殊召唤的代价。
	return Duel.IsExistingMatchingCard(c34230233.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤手续的目标选择：从自己场上满足条件的「暗黑界」怪兽中，由玩家选择1只作为返回手牌的COST；选中后存入效果标签并返回true，否则返回false。
function c34230233.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足spfilter过滤条件的「暗黑界」怪兽，作为可选的返回手牌候选组。
	local g=Duel.GetMatchingGroup(c34230233.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 向玩家显示选择提示，要求其选择1只要返回手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的实际处理：将目标选择阶段保存的那只怪兽返回持有者手卡，以此作为格拉法从墓地特殊召唤的代价。
function c34230233.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽返回持有者手卡（nil表示返回其持有者手卡），此操作作为格拉法特殊召唤手续的一部分。
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- ②效果的发动条件：格拉法从手卡被效果丢弃去墓地（丢弃原因为效果且含丢弃标志），同时记录其丢弃前的控制者到标签，用于后续判断是否由对方的效果丢弃。
function c34230233.descon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetPreviousControler())
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040
end
-- ②效果的目标选择与类别设定：选择对方场上1张卡为对象；若本次丢弃是由对方的效果引起（rp为对方且原控制者为tp），则效果类别为破坏+特殊召唤，否则仅为破坏。
function c34230233.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 向玩家显示选择提示，要求选择1张要破坏的对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡作为效果对象（取对象），并自动登记为当前连锁的处理目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 向系统登记操作信息：将破坏所选择的对象卡，数量为1，用于连锁判定和后续效果互动。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if rp==1-tp and tp==e:GetLabel() then
		e:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	else
		e:SetCategory(CATEGORY_DESTROY)
	end
end
-- ②效果的处理：破坏取对象的那张卡；若破坏成功且本次丢弃是由对方的效果引起，则随机确认对方1张手牌：若是可特殊召唤的怪兽且我方怪兽区有空位，则询问玩家是否特殊召唤，否则洗切对方手牌。
function c34230233.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对方场上对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断并执行破坏：对象卡仍与此效果关联且确实被效果破坏成功，同时满足“被对方的效果丢弃”条件时，才进入后续追加处理。
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and rp==1-tp and tp==e:GetLabel() then
		-- 中断效果处理，使破坏完成的时点与后续的特殊召唤等处理错开，避免错过时点。
		Duel.BreakEffect()
		-- 获取对方手牌的所有卡（以tp视角看对方手牌），用于后续随机选择1张确认。
		local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if hg:GetCount()>0 then
			local cg=hg:RandomSelect(tp,1)
			local cc=cg:GetFirst()
			-- 将随机选中的对方手牌展示给tp玩家确认。
			Duel.ConfirmCards(tp,cc)
			-- 确认tp方怪兽区仍有空位，且该对方手牌的怪兽可以特殊召唤到tp方场上。
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and cc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 询问tp玩家是否愿意将确认的怪兽特殊召唤到自己场上。
				and Duel.SelectYesNo(tp,aux.Stringid(34230233,1)) then  --"是否要特殊召唤？"
				-- 将对方手牌中被确认的那只怪兽以表侧表示特殊召唤到tp方场上。
				Duel.SpecialSummon(cc,0,tp,tp,false,false,POS_FACEUP)
			-- 若玩家选择不特殊召唤或无法特殊召唤，则洗切对方手牌，避免暴露多余手牌信息。
			else Duel.ShuffleHand(1-tp) end
		end
	end
end
