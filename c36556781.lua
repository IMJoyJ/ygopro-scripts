--ドラグニティナイト－ゴルムファバル
-- 效果：
-- 「龙骑兵团」调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功时，以自己墓地1只「龙骑兵团」调整为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
-- ②：把给这张卡装备的自己场上1张装备卡送去墓地，以对方墓地最多2张卡为对象才能发动。那些卡除外。这个效果在对方回合也能发动。
function c36556781.initial_effect(c)
	-- 为这张卡添加同调召唤手续，要求素材为「龙骑兵团」调整1只＋调整以外的怪兽1只以上（即记载的召素材条件）。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x29),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡同调召唤成功时，以自己墓地1只「龙骑兵团」调整为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36556781,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,36556781)
	e1:SetCondition(c36556781.eqcon)
	e1:SetTarget(c36556781.eqtg)
	e1:SetOperation(c36556781.eqop)
	c:RegisterEffect(e1)
	-- ②：把给这张卡装备的自己场上1张装备卡送去墓地，以对方墓地最多2张卡为对象才能发动。那些卡除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36556781,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,36556782)
	e2:SetCost(c36556781.rmcost)
	e2:SetTarget(c36556781.rmtg)
	e2:SetOperation(c36556781.rmop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：只有这张卡以同调召唤方式成功上场时，该触发效果才满足发动时机。
function c36556781.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果的目标筛选条件：选择自己墓地的「龙骑兵团」调整怪兽，且该卡不是禁止卡，才能作为装备对象。
function c36556781.eqfilter(c)
	return c:IsSetCard(0x29) and c:IsType(TYPE_TUNER) and not c:IsForbidden()
end
-- ①效果的目标选择处理：先确认自己魔陷区存在空位，且自己墓地存在至少1只符合条件的「龙骑兵团」调整；若有指定对象则校验该对象位于自己墓地且符合筛选条件，为后续发动请求做准备。
function c36556781.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c36556781.eqfilter(chkc) end
	-- 发动合法性检查：自己的魔法与陷阱区域必须有可用空位，否则无法把墓地怪兽装备给这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动合法性检查：自己墓地存在1张以上可作为对象的「龙骑兵团」调整怪兽（且能被取对象），二者同时满足才可发动①效果。
		and Duel.IsExistingTarget(c36556781.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家展示选择提示“请选择要装备的卡”，用于选择装备对象时的界面消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己墓地选择1只符合条件的「龙骑兵团」调整作为①效果的对象，并将该对象与当前连锁关联。
	local g=Duel.SelectTarget(tp,c36556781.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end
-- ①效果处理：取得选择的调整怪兽，确认它仍与效果关联且本卡仍在场上表侧表示后，将其作为装备卡装备给自己，并添加装备对象限制，使该装备卡只能装备给本卡。
function c36556781.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果发动时选择的对象卡（自己墓地的那只「龙骑兵团」调整）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将选择的怪兽作为装备卡装备给这张卡；若装备失败（如格子被占或限制）则终止处理，false表示保持装备卡原表示形式。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c36556781.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制判定：只有效果的所有者（即这张碧枪龙骑士）才能装备该装备卡，防止其被转移到其他怪兽身上。
function c36556781.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果代价的过滤条件：作为代价的卡必须是自己场上由这张卡装备的装备卡，且可以被送去墓地。
function c36556781.costfilter(c,tp)
	return c:IsControler(tp) and c:IsAbleToGraveAsCost()
end
-- ②效果的代价处理：检查这张卡装备中的卡是否存在可送去墓地的装备卡；若存在，由玩家选择1张装备卡送去墓地作为发动代价。
function c36556781.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(c36556781.costfilter,1,nil,tp) end
	-- 向玩家展示提示“请选择要送去墓地的卡”，用于选择作为代价的装备卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,c36556781.costfilter,1,1,nil,tp)
	-- 将选择的装备卡作为②效果的代价送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的发动条件与目标选择：确认对方墓地存在可除外的卡，然后选择对方墓地1～2张卡作为对象，并登记除外操作信息。
function c36556781.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chk:IsAbleToRemove() end
	-- ②效果发动合法性检查：对方墓地是否存在至少1张可以被除外的卡，且该卡能成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向玩家展示提示“请选择要除外的卡”，用于选择除外对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1～2张可以除外的卡作为②效果的对象（取对象），并将选择结果与当前连锁关联。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
	-- 设置操作信息：本次连锁处理将进行除外，对象为g中的卡，数量为g的数量，供其他效果或判定查询。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- ②效果处理：从当前连锁中取得对象卡组，过滤掉已与效果失去联系的卡，将仍相关的对象卡以表侧表示除外。
function c36556781.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理时记录的②效果对象卡组（即对方墓地被选择的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选后仍然相关的对象卡以表侧表示除外，完成②效果的除外处理。
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
