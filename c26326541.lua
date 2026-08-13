--業神－不知火
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己对「业神-不知火」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
-- ②：这张卡被除外的场合才能发动。在自己场上把1只「不知火衍生物」（不死族·炎·1星·攻/守0）特殊召唤。
function c26326541.initial_effect(c)
	c:SetSPSummonOnce(26326541)
	-- 为这张卡添加同调召唤手续：将1只任意调整 + 1只以上任意调整以外的怪兽作为素材进行同调召唤。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26326541,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c26326541.postg)
	e1:SetOperation(c26326541.posop)
	c:RegisterEffect(e1)
	-- 那个②的效果1回合只能使用1次。②：这张卡被除外的场合才能发动。在自己场上把1只「不知火衍生物」（不死族·炎·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26326541,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,26326541)
	e2:SetTarget(c26326541.tktg)
	e2:SetOperation(c26326541.tkop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件与取对象处理：检查场上是否存在可改变表示形式的怪兽，若存在则让玩家选择1只作为对象，并设置操作信息。
function c26326541.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	-- 发动时点判定：场上是否存在至少1只可以改变表示形式的怪兽，用于确定①效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示：请选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从双方场上的怪兽中选取1只可以改变表示形式的怪兽，并将其设为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果处理涉及改变1只怪兽的表示形式（CATEGORY_POSITION）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ①效果处理：获取对象怪兽，确认其仍与效果关联后，变更其表示形式。
function c26326541.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽（当前连锁中记录的第一张对象卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 变更对象怪兽的表示形式：原表侧攻击表示变为表侧守备表示，原其他表示形式变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- ②效果发动条件判定：自己场上有空余的主要怪兽区，且玩家能够特殊召唤「不知火衍生物」。
function c26326541.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：自己场上是否有空余的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且玩家能够特殊召唤「不知火衍生物」（不死族·炎·1星·攻/守0）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,26326542,0xd9,TYPES_TOKEN_MONSTER,0,0,1,RACE_ZOMBIE,ATTRIBUTE_FIRE) end
	-- 设置操作信息：本次处理将生成1只衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：本次处理包含1只怪兽的特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果处理：再次确认场上空位与特殊召唤许可后，创建「不知火衍生物」并以表侧表示特殊召唤到自己场上。
function c26326541.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认：若自己场上没有空余的主要怪兽区，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时再次确认：若玩家现在不能特殊召唤该衍生物，则终止处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,26326542,0xd9,TYPES_TOKEN_MONSTER,0,0,1,RACE_ZOMBIE,ATTRIBUTE_FIRE) then return end
	-- 创建1只「不知火衍生物」（token，卡号26326542）。
	local token=Duel.CreateToken(tp,26326542)
	-- 将衍生物以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
