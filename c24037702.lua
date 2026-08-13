--闇の進軍
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「光道」怪兽为对象才能发动。那只怪兽加入手卡。那之后，把加入手卡的那只怪兽的原本等级数量的卡从自己卡组上面除外。
function c24037702.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只「光道」怪兽为对象才能发动。那只怪兽加入手卡。那之后，把加入手卡的那只怪兽的原本等级数量的卡从自己卡组上面除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,24037702+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c24037702.target)
	e1:SetOperation(c24037702.activate)
	c:RegisterEffect(e1)
end
-- 该筛选函数用于判定墓地中的怪兽能否作为对象：必须是「光道」怪兽、原本等级大于0、可加入手卡，并且发动后需要从卡组顶除外的原等级数量的卡都满足可被除外，这样效果才能完整处理。
function c24037702.filter(c,tp)
	if not c:IsType(TYPE_MONSTER) or not c:IsSetCard(0x38) or c:GetOriginalLevel()<=0 or not c:IsAbleToHand() then return false end
	-- 以该怪兽的原本等级为数量，获取玩家tp卡组最上方对应张数的卡，用于后续判定和除外。
	local g=Duel.GetDecktopGroup(tp,c:GetOriginalLevel())
	return g:FilterCount(Card.IsAbleToRemove,nil)==c:GetOriginalLevel()
end
-- 发动时的目标选择与操作设定：从自己墓地选择1只满足条件的光道怪兽作为对象；预先取得卡组顶对应数量的卡，并设置回手牌、除外的连锁操作信息。
function c24037702.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c24037702.filter(chkc,tp) end
	-- 在效果发动合法性检查时，确认自己墓地中是否存在至少1只满足c24037702.filter条件的光道怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c24037702.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 向玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足条件的光道怪兽作为效果对象，并将该卡设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c24037702.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 取得所选怪兽的原本等级，并获取玩家卡组顶该数量的卡，作为之后要被除外的卡组。
	local rg=Duel.GetDecktopGroup(tp,g:GetFirst():GetOriginalLevel())
	-- 设置当前连锁的操作信息：将选择的对象怪兽加入手牌（CATEGORY_TOHAND），用于后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置当前连锁的操作信息：将卡组顶的这些卡除外（CATEGORY_REMOVE），并记录数量供后续效果检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,rg:GetCount(),0,0)
end
-- 效果处理阶段：若对象怪兽仍与效果关联，则先将其加入手牌；成功加入手牌后中断效果处理，再将卡组顶与该怪兽原本等级相同数量的卡除外。
function c24037702.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个（也是唯一一个）对象卡，即之前选择的墓地光道怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡仍然与效果关联（未被移除或转移），并且将其加入持有者手牌的操作成功。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) then
		-- 中断当前效果处理，使“加入手牌”与“除外卡组”两部分效果视为不同时处理，以符合“那之后”的时序并避免错过时点。
		Duel.BreakEffect()
		local ol=tc:GetOriginalLevel()
		-- 以加入手牌的那只怪兽的原本等级为数量，获取玩家卡组顶对应张数的卡。
		local rg=Duel.GetDecktopGroup(tp,ol)
		-- 禁用紧接着的除外操作后的自动洗牌检查，因为从卡组顶端除外不涉及卡组洗切。
		Duel.DisableShuffleCheck()
		-- 将卡组顶的这些卡以表侧表示除外，除外原因为效果（REASON_EFFECT）。
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
