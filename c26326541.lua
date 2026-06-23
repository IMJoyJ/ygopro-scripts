--業神－不知火
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己对「业神-不知火」1回合只能有1次特殊召唤，那个②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合，以场上1只怪兽为对象才能发动。那只怪兽的表示形式变更。
-- ②：这张卡被除外的场合才能发动。在自己场上把1只「不知火衍生物」（不死族·炎·1星·攻/守0）特殊召唤。
function c26326541.initial_effect(c)
	c:SetSPSummonOnce(26326541)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调召唤
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
	-- ②：这张卡被除外的场合才能发动。在自己场上把1只「不知火衍生物」（不死族·炎·1星·攻/守0）特殊召唤。
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
-- 设置效果目标为场上任意一只可以改变表示形式的怪兽
function c26326541.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsCanChangePosition() end
	-- 判断是否满足选择目标的条件，即场上是否存在可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择场上一只可以改变表示形式的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息，表示将改变目标怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理效果的发动，将目标怪兽变为守备表示
function c26326541.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 设置效果目标为是否可以特殊召唤衍生物
function c26326541.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有空位可以特殊召唤衍生物
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,26326542,0xd9,TYPES_TOKEN_MONSTER,0,0,1,RACE_ZOMBIE,ATTRIBUTE_FIRE) end
	-- 设置效果操作信息，表示将生成衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果操作信息，表示将特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 处理效果的发动，生成并特殊召唤不知火衍生物
function c26326541.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家场上是否有空位可以特殊召唤衍生物
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 判断玩家是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,26326542,0xd9,TYPES_TOKEN_MONSTER,0,0,1,RACE_ZOMBIE,ATTRIBUTE_FIRE) then return end
	-- 创建不知火衍生物
	local token=Duel.CreateToken(tp,26326542)
	-- 将不知火衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
