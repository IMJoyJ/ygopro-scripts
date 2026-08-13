--ヘル・ブラスト
-- 效果：
-- 自己场上表侧表示存在的怪兽破坏送去墓地时发动。场上表侧表示攻击力最低的1只怪兽破坏，双方受到那个攻击力一半的数值的伤害。
function c18271561.initial_effect(c)
	-- 自己场上表侧表示存在的怪兽破坏送去墓地时发动。场上表侧表示攻击力最低的1只怪兽破坏，双方受到那个攻击力一半的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(c18271561.condition)
	e1:SetTarget(c18271561.target)
	e1:SetOperation(c18271561.operation)
	c:RegisterEffect(e1)
end
-- 筛选满足“自己场上表侧表示存在的怪兽因破坏而送去墓地”这一条件的怪兽，用于确认诱发时机。
function c18271561.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousControler(tp) and c:IsReason(REASON_DESTROY)
end
-- 检查送去墓地的怪兽组中是否存在至少1只满足上述条件的怪兽，作为发动条件。
function c18271561.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c18271561.filter,1,nil,tp)
end
-- 发动时的合法性检查与操作信息设置：确认场上存在表侧表示怪兽，将攻击力最低的表侧怪兽预设为破坏对象，并设置伤害操作信息。
function c18271561.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若场上不存在表侧表示怪兽，则效果无法发动（合法性检查）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local dg=g:GetMinGroup(Card.GetAttack)
	-- 设置破坏效果的操作信息：预定破坏1只攻击力最低的表侧怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
	-- 设置伤害效果的操作信息：预定对双方玩家造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 效果处理：从场上表侧怪兽中选出攻击力最低的1只（若并列则选择1只），将其破坏；破坏成功时双方受到其攻击力一半数值的伤害。
function c18271561.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时场上所有表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local dg=g:GetMinGroup(Card.GetAttack)
	if dg:GetCount()>1 then
		-- 当攻击力最低的怪兽不止1只时，提示发动者选择其中1只作为破坏对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		dg=dg:Select(tp,1,1,nil)
	end
	local atk=math.floor(dg:GetFirst():GetAttack()/2)
	-- 以效果原因破坏选定的怪兽，并判定是否破坏成功。
	if Duel.Destroy(dg,REASON_EFFECT)>0 then
		-- 给与发动者相当于攻击力一半数值的伤害（作为伤害处理的一步）。
		Duel.Damage(tp,atk,REASON_EFFECT,true)
		-- 给与对方玩家相当于攻击力一半数值的伤害（作为伤害处理的一步）。
		Duel.Damage(1-tp,atk,REASON_EFFECT,true)
		-- 完成本次伤害处理，触发“受到伤害时”等后续时点。
		Duel.RDComplete()
	end
end
